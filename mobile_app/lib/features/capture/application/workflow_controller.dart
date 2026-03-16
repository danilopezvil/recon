import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/image_optimizer.dart';
import '../../../domain/models/analyzed_item.dart';
import '../../../domain/models/process_result.dart';
import '../../../domain/models/publish_payload.dart';
import '../../../domain/repositories/history_repository.dart';
import '../../../domain/services/item_processing_service.dart';

enum WorkflowStep {
  idle,
  imageReady,
  analyzed,
  edited,
  published,
}

enum WorkflowStatus {
  initial,
  loading,
  success,
  error,
}

class WorkflowState {
  const WorkflowState({
    this.step = WorkflowStep.idle,
    this.status = WorkflowStatus.initial,
    this.imagePath,
    this.optimization,
    this.analyzedItem,
    this.lastPublished,
    this.error,
  });

  final WorkflowStep step;
  final WorkflowStatus status;
  final String? imagePath;
  final ImageOptimizationResult? optimization;
  final AnalyzedItem? analyzedItem;
  final ProcessResult? lastPublished;
  final String? error;

  bool get hasImage => imagePath != null;
  bool get isLoading => status == WorkflowStatus.loading;

  WorkflowState copyWith({
    WorkflowStep? step,
    WorkflowStatus? status,
    String? imagePath,
    ImageOptimizationResult? optimization,
    AnalyzedItem? analyzedItem,
    ProcessResult? lastPublished,
    String? error,
    bool clearError = false,
    bool clearPublished = false,
  }) {
    return WorkflowState(
      step: step ?? this.step,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      optimization: optimization ?? this.optimization,
      analyzedItem: analyzedItem ?? this.analyzedItem,
      lastPublished: clearPublished ? null : (lastPublished ?? this.lastPublished),
      error: clearError ? null : (error ?? this.error),
    );
  }

  WorkflowState toLoading() => copyWith(
        status: WorkflowStatus.loading,
        clearError: true,
      );

  WorkflowState toError(String message) => copyWith(
        status: WorkflowStatus.error,
        error: message,
      );
}

class WorkflowController extends StateNotifier<WorkflowState> {
  WorkflowController(this._service, this._history)
      : _picker = ImagePicker(),
        _optimizer = ImageOptimizer(),
        super(const WorkflowState());

  final ItemProcessingService _service;
  final HistoryRepository _history;
  final ImagePicker _picker;
  final ImageOptimizer _optimizer;

  Future<bool> pickFromCamera() => _pick(ImageSource.camera);

  Future<bool> pickFromGallery() => _pick(ImageSource.gallery);

  Future<bool> _pick(ImageSource source) async {
    try {
      state = state.toLoading();
      final picked = await _picker.pickImage(source: source, imageQuality: 100);
      if (picked == null) {
        state = state.copyWith(status: WorkflowStatus.initial, clearError: true);
        return false;
      }

      final optimization = await _optimizer.compressToTarget(File(picked.path));
      state = state.copyWith(
        step: WorkflowStep.imageReady,
        status: WorkflowStatus.success,
        imagePath: optimization.file.path,
        optimization: optimization,
        analyzedItem: null,
        clearPublished: true,
        clearError: true,
      );
      return true;
    } catch (_) {
      state = state.toError('No se pudo procesar la imagen.');
      return false;
    }
  }


  void setPreparedImage({
    required String imagePath,
    required ImageOptimizationResult optimization,
  }) {
    state = state.copyWith(
      step: WorkflowStep.imageReady,
      status: WorkflowStatus.success,
      imagePath: imagePath,
      optimization: optimization,
      analyzedItem: null,
      clearPublished: true,
      clearError: true,
    );
  }

  Future<bool> analyze() async {
    if (!state.hasImage || state.imagePath == null) {
      state = state.toError('Selecciona una imagen antes de analizar.');
      return false;
    }

    try {
      state = state.toLoading();
      final result = await _service.analyzeItem(state.imagePath!);
      state = state.copyWith(
        step: WorkflowStep.analyzed,
        status: WorkflowStatus.success,
        analyzedItem: result,
        clearError: true,
      );
      return true;
    } catch (_) {
      state = state.toError('Falló el análisis simulado.');
      return false;
    }
  }

  void updateAnalyzedItem(AnalyzedItem item) {
    state = state.copyWith(
      step: WorkflowStep.edited,
      status: WorkflowStatus.success,
      analyzedItem: item,
      clearError: true,
    );
  }

  Future<bool> publish() async {
    final item = state.analyzedItem;
    final path = state.imagePath;
    final optimization = state.optimization;

    if (item == null || path == null) {
      state = state.toError('No hay datos listos para publicar.');
      return false;
    }

    try {
      state = state.toLoading();
      final payload = PublishPayload(
        item: item,
        localImagePath: path,
        createdAt: DateTime.now(),
      );
      final ok = await _service.publishItem(payload);

      if (!ok) {
        state = state.toError('Publicación simulada rechazada.');
        return false;
      }

      final record = ProcessResult(
        id: const Uuid().v4(),
        item: item,
        imagePath: path,
        imageBytes: optimization?.finalBytes ?? 0,
        published: true,
        createdAt: DateTime.now(),
        message: 'Publicado (simulado)',
      );
      await _history.save(record);

      state = state.copyWith(
        step: WorkflowStep.published,
        status: WorkflowStatus.success,
        lastPublished: record,
        clearError: true,
      );
      return true;
    } catch (_) {
      state = state.toError('No se pudo simular la publicación.');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void resetFlow() {
    state = const WorkflowState();
  }
}
