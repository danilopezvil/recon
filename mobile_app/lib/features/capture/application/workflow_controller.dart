import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_error.dart';
import '../../../core/utils/image_optimizer.dart';
import '../../../domain/models/analyze_draft_result.dart';
import '../../../domain/models/analyzed_item.dart';
import '../../../domain/models/confirm_draft_payload.dart';
import '../../../domain/models/process_result.dart';
import '../../../domain/models/published_item.dart';
import '../../../domain/repositories/history_repository.dart';
import '../../../domain/services/item_processing_service.dart';

const _noValue = Object();

enum WorkflowStep {
  idle,
  imageSelected,
  imageCompressed,
  analyzingRemote,
  draftReady,
  editingDraft,
  confirmingDraft,
  publishedSuccess,
  failure,
}

class WorkflowState {
  const WorkflowState({
    this.step = WorkflowStep.idle,
    this.imagePath,
    this.optimization,
    this.draftId,
    this.imageUrl,
    this.analyzedItem,
    this.publishedItem,
    this.isLoading = false,
    this.error,
    this.confirmRetryBlockedUntil,
  });

  final WorkflowStep step;
  final String? imagePath;
  final ImageOptimizationResult? optimization;
  final String? draftId;
  final String? imageUrl;
  final AnalyzedItem? analyzedItem;
  final PublishedItem? publishedItem;
  final bool isLoading;
  final String? error;
  final DateTime? confirmRetryBlockedUntil;

  int? get imageBytes => optimization?.finalBytes;

  bool get isConfirmRetryBlocked =>
      confirmRetryBlockedUntil != null && DateTime.now().isBefore(confirmRetryBlockedUntil!);

  Duration? get confirmRetryRemaining {
    if (!isConfirmRetryBlocked) return null;
    return confirmRetryBlockedUntil!.difference(DateTime.now());
  }

  WorkflowState copyWith({
    WorkflowStep? step,
    String? imagePath,
    ImageOptimizationResult? optimization,
    String? draftId,
    String? imageUrl,
    AnalyzedItem? analyzedItem,
    PublishedItem? publishedItem,
    bool? isLoading,
    String? error,
    Object? confirmRetryBlockedUntil = _noValue,
  }) {
    return WorkflowState(
      step: step ?? this.step,
      imagePath: imagePath ?? this.imagePath,
      optimization: optimization ?? this.optimization,
      draftId: draftId ?? this.draftId,
      imageUrl: imageUrl ?? this.imageUrl,
      analyzedItem: analyzedItem ?? this.analyzedItem,
      publishedItem: publishedItem ?? this.publishedItem,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      confirmRetryBlockedUntil: confirmRetryBlockedUntil == _noValue
          ? this.confirmRetryBlockedUntil
          : confirmRetryBlockedUntil as DateTime?,
    );
  }
}

class WorkflowController extends StateNotifier<WorkflowState> {
  WorkflowController(this._service, this._history)
      : _picker = ImagePicker(),
        _optimizer = ImageOptimizer(),
        super(const WorkflowState());

  static const int analyzeEndpointMaxBytes = 100 * 1024;
  static const validCategories = <String>{'kitchen', 'books', 'home', 'electronics', 'other'};
  static const validConditions = <String>{'new', 'like_new', 'good', 'fair', 'parts'};

  final ItemProcessingService _service;
  final HistoryRepository _history;
  final ImagePicker _picker;
  final ImageOptimizer _optimizer;

  Future<bool> pickFromCamera() => _pick(ImageSource.camera);
  Future<bool> pickFromGallery() => _pick(ImageSource.gallery);

  void setPreparedImage({required String imagePath, required ImageOptimizationResult optimization}) {
    state = state.copyWith(
      step: WorkflowStep.imageCompressed,
      imagePath: imagePath,
      optimization: optimization,
      analyzedItem: null,
      draftId: null,
      imageUrl: null,
      publishedItem: null,
      error: null,
      isLoading: false,
      confirmRetryBlockedUntil: null,
    );
  }

  Future<bool> _pick(ImageSource source) async {
    try {
      state = state.copyWith(step: WorkflowStep.imageSelected, isLoading: true, error: null, confirmRetryBlockedUntil: null);
      final picked = await _picker.pickImage(source: source, imageQuality: 100);
      if (picked == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      AppLogger.info('Compression started path=${picked.path}', tag: 'WORKFLOW');
      final optimized = await _optimizer.compressToTarget(File(picked.path));
      AppLogger.info(
        'Compression finished attempts=${optimized.attempts} bytes=${optimized.finalBytes} reached=${optimized.targetReached}',
        tag: 'WORKFLOW',
      );
      setPreparedImage(imagePath: optimized.file.path, optimization: optimized);
      return true;
    } catch (e, st) {
      AppLogger.error('Compression/pick failed', error: e, stackTrace: st, tag: 'WORKFLOW');
      state = state.copyWith(step: WorkflowStep.failure, isLoading: false, error: 'No se pudo procesar la imagen.');
      return false;
    }
  }

  Future<bool> analyze() async {
    if (state.imagePath == null || state.optimization == null) return false;
    if (state.optimization!.finalBytes > analyzeEndpointMaxBytes) {
      state = state.copyWith(step: WorkflowStep.failure, error: 'La imagen final supera 100 KB.');
      return false;
    }

    try {
      state = state.copyWith(step: WorkflowStep.analyzingRemote, isLoading: true, error: null, confirmRetryBlockedUntil: null);
      final AnalyzeDraftResult result = await _service.analyzeItem(state.imagePath!);
      state = state.copyWith(
        step: WorkflowStep.draftReady,
        draftId: result.draftId,
        imageUrl: result.imageUrl,
        analyzedItem: result.suggestion,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(step: WorkflowStep.failure, isLoading: false, error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(step: WorkflowStep.failure, isLoading: false, error: 'Falló el análisis remoto.');
      return false;
    }
  }

  void updateAnalyzedItem(AnalyzedItem item) {
    state = state.copyWith(step: WorkflowStep.editingDraft, analyzedItem: item, error: null);
  }

  String? _validateForConfirm(AnalyzedItem item) {
    if (item.title.trim().isEmpty) return 'El título es obligatorio.';
    if (item.title.trim().length < 3) return 'El título es demasiado corto.';
    if (item.price < 0) return 'El precio debe ser mayor o igual a 0.';
    if (item.price > 100000) return 'El precio supera el máximo permitido.';
    if (!validCategories.contains(item.category.trim())) return 'La categoría no es válida.';
    if (!validConditions.contains(item.condition.trim())) return 'La condición no es válida.';
    if (item.pickupArea.trim().isEmpty) return 'La zona de recogida es obligatoria.';
    if (item.description.trim().length > 2000) return 'La descripción es demasiado larga.';
    return null;
  }

  Future<bool> publish() async {
    final item = state.analyzedItem;
    final draftId = state.draftId;
    final imageUrl = state.imageUrl;
    if (item == null || draftId == null || imageUrl == null) {
      state = state.copyWith(step: WorkflowStep.failure, error: 'Faltan datos para confirmar el borrador.');
      return false;
    }

    if (state.isConfirmRetryBlocked) {
      final remaining = state.confirmRetryRemaining?.inSeconds ?? 0;
      state = state.copyWith(step: WorkflowStep.failure, error: 'Reintento bloqueado temporalmente (${remaining}s).');
      return false;
    }

    final validationError = _validateForConfirm(item);
    if (validationError != null) {
      state = state.copyWith(step: WorkflowStep.failure, error: validationError);
      return false;
    }

    try {
      state = state.copyWith(step: WorkflowStep.confirmingDraft, isLoading: true, error: null);
      final published = await _service.confirmDraft(
        ConfirmDraftPayload(draftId: draftId, imageUrl: imageUrl, item: item),
      );

      await _history.save(
        ProcessResult(
          id: const Uuid().v4(),
          flowType: 'ai_assisted',
          draftId: draftId,
          publishedItemId: published.id,
          imageUrl: imageUrl,
          title: published.title,
          category: published.category,
          condition: published.condition,
          price: published.price,
          pickupArea: published.pickupArea,
          publishedAt: DateTime.now(),
          success: true,
          message: 'Publicado',
        ),
      );

      state = state.copyWith(
        step: WorkflowStep.publishedSuccess,
        isLoading: false,
        publishedItem: published,
        confirmRetryBlockedUntil: null,
      );
      return true;
    } on ApiException catch (e) {
      DateTime? blockedUntil;
      if (e.kind == ApiErrorKind.rateLimited) {
        final retryAfter = e.rateLimit?.retryAfter;
        if (retryAfter != null && retryAfter.inSeconds > 0) {
          blockedUntil = DateTime.now().add(retryAfter);
        }
      }
      state = state.copyWith(
        step: WorkflowStep.failure,
        isLoading: false,
        error: e.message,
        confirmRetryBlockedUntil: blockedUntil,
      );
      return false;
    } catch (_) {
      state = state.copyWith(step: WorkflowStep.failure, isLoading: false, error: 'No se pudo confirmar la publicación.');
      return false;
    }
  }

  Future<void> startNextItem() async {
    final previousPath = state.imagePath;
    state = const WorkflowState();

    if (previousPath == null) return;
    try {
      final f = File(previousPath);
      if (await f.exists()) {
        await f.delete();
      }
    } catch (_) {
      // No-op en limpieza temporal.
    }
  }

  void resetFlow() => state = const WorkflowState();
}
