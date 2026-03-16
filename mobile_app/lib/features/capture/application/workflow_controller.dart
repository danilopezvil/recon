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

class WorkflowState {
  const WorkflowState({
    this.imagePath,
    this.imageBytes,
    this.analyzedItem,
    this.isLoading = false,
    this.error,
  });

  final String? imagePath;
  final int? imageBytes;
  final AnalyzedItem? analyzedItem;
  final bool isLoading;
  final String? error;

  WorkflowState copyWith({
    String? imagePath,
    int? imageBytes,
    AnalyzedItem? analyzedItem,
    bool? isLoading,
    String? error,
  }) {
    return WorkflowState(
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
      analyzedItem: analyzedItem ?? this.analyzedItem,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
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
      state = state.copyWith(isLoading: true, error: null);
      final picked = await _picker.pickImage(source: source, imageQuality: 100);
      if (picked == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }
      final compressed = await _optimizer.compressToTarget(File(picked.path));
      state = state.copyWith(
        imagePath: compressed.path,
        imageBytes: await compressed.length(),
        analyzedItem: null,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'No se pudo procesar la imagen.');
      return false;
    }
  }

  Future<bool> analyze() async {
    if (state.imagePath == null) return false;
    try {
      state = state.copyWith(isLoading: true, error: null);
      final result = await _service.analyzeItem(state.imagePath!);
      state = state.copyWith(analyzedItem: result, isLoading: false);
      return true;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Falló el análisis simulado.');
      return false;
    }
  }

  void updateAnalyzedItem(AnalyzedItem item) {
    state = state.copyWith(analyzedItem: item, error: null);
  }

  Future<bool> publish() async {
    final item = state.analyzedItem;
    final path = state.imagePath;
    if (item == null || path == null) return false;

    try {
      state = state.copyWith(isLoading: true, error: null);
      final payload = PublishPayload(
        item: item,
        localImagePath: path,
        createdAt: DateTime.now(),
      );
      final ok = await _service.publishItem(payload);
      if (ok) {
        await _history.save(
          ProcessResult(
            id: const Uuid().v4(),
            item: item,
            imagePath: path,
            imageBytes: state.imageBytes ?? 0,
            published: true,
            createdAt: DateTime.now(),
            message: 'Publicado (simulado)',
          ),
        );
      }
      state = state.copyWith(isLoading: false);
      return ok;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'No se pudo simular la publicación.');
      return false;
    }
  }

  void resetFlow() {
    state = const WorkflowState();
  }
}
