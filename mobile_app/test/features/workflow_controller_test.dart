import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recon_mobile_app/app/providers.dart';
import 'package:recon_mobile_app/core/network/api_error.dart';
import 'package:recon_mobile_app/core/utils/image_optimizer.dart';
import 'package:recon_mobile_app/domain/models/analyze_draft_result.dart';
import 'package:recon_mobile_app/domain/models/analyzed_item.dart';
import 'package:recon_mobile_app/domain/models/confirm_draft_payload.dart';
import 'package:recon_mobile_app/domain/models/process_result.dart';
import 'package:recon_mobile_app/domain/models/publish_payload.dart';
import 'package:recon_mobile_app/domain/models/published_item.dart';
import 'package:recon_mobile_app/domain/repositories/history_repository.dart';
import 'package:recon_mobile_app/domain/services/item_processing_service.dart';
import 'package:recon_mobile_app/features/capture/application/workflow_controller.dart';

class _FakeService implements ItemProcessingService {
  _FakeService({this.throwOnAnalyze, this.throwOnConfirm});

  final Exception? throwOnAnalyze;
  final Exception? throwOnConfirm;

  @override
  Future<AnalyzeDraftResult> analyzeItem(String imagePath) async {
    if (throwOnAnalyze != null) throw throwOnAnalyze!;
    return const AnalyzeDraftResult(
      draftId: 'd1',
      imageUrl: 'https://img',
      suggestion: AnalyzedItem(
        title: 'Mock item',
        price: 22,
        category: 'home',
        condition: 'good',
        pickupArea: '',
        description: 'desc',
      ),
    );
  }

  @override
  Future<PublishedItem> confirmDraft(ConfirmDraftPayload payload) async {
    if (throwOnConfirm != null) throw throwOnConfirm!;
    return PublishedItem(
      id: 'p1',
      title: payload.item.title,
      description: payload.item.description,
      price: payload.item.price,
      category: payload.item.category,
      condition: payload.item.condition,
      pickupArea: payload.item.pickupArea,
      status: 'available',
      createdAt: DateTime.now(),
      images: const [],
    );
  }

  @override
  Future<PublishedItem> createItem(PublishPayload payload) {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> uploadItemImages({required String itemId, required List<String> imagePaths}) {
    throw UnimplementedError();
  }
}

class _MemoryHistoryRepository implements HistoryRepository {
  final List<ProcessResult> items = [];

  @override
  Future<List<ProcessResult>> getAll() async => items;

  @override
  Future<void> save(ProcessResult result) async {
    items.add(result);
  }
}

Future<File> _createTempImage(String name, {int bytes = 48 * 1024}) async {
  final tmp = await Directory.systemTemp.createTemp('recon_workflow_');
  final file = File('${tmp.path}/$name.jpg');
  await file.writeAsBytes(List<int>.filled(bytes, 1));
  return file;
}

ProviderContainer _makeContainer({
  ItemProcessingService? service,
  HistoryRepository? history,
}) {
  return ProviderContainer(
    overrides: [
      if (service != null) itemProcessingServiceProvider.overrideWithValue(service),
      if (history != null) historyRepositoryProvider.overrideWithValue(history),
    ],
  );
}

void main() {
  test('workflow transitions compressed -> draftReady -> publishedSuccess', () async {
    final history = _MemoryHistoryRepository();
    final container = _makeContainer(service: _FakeService(), history: history);
    addTearDown(container.dispose);

    final controller = container.read(workflowControllerProvider.notifier);
    final image = await _createTempImage('ok');

    controller.setPreparedImage(
      imagePath: image.path,
      optimization: ImageOptimizationResult(
        file: image,
        originalBytes: 120000,
        finalBytes: 48000,
        finalWidth: 1024,
        finalHeight: 1024,
        targetReached: true,
        attempts: 3,
      ),
    );

    expect(controller.state.step, WorkflowStep.imageCompressed);

    final analyzed = await controller.analyze();
    expect(analyzed, isTrue);
    expect(controller.state.step, WorkflowStep.draftReady);

    controller.updateAnalyzedItem(controller.state.analyzedItem!.copyWith(pickupArea: 'Downtown'));
    final published = await controller.publish();
    expect(published, isTrue);
    expect(controller.state.step, WorkflowStep.publishedSuccess);
    expect(history.items.length, 1);
  });

  test('publish blocks retry window when API returns rate limit', () async {
    final history = _MemoryHistoryRepository();
    final container = _makeContainer(
      service: _FakeService(
        throwOnConfirm: const ApiException(
          'Demasiadas solicitudes. Reintenta en 30s.',
          kind: ApiErrorKind.rateLimited,
          rateLimit: RateLimitInfo(retryAfter: Duration(seconds: 30)),
        ),
      ),
      history: history,
    );
    addTearDown(container.dispose);

    final controller = container.read(workflowControllerProvider.notifier);
    final image = await _createTempImage('retry');

    controller.setPreparedImage(
      imagePath: image.path,
      optimization: ImageOptimizationResult(
        file: image,
        originalBytes: 120000,
        finalBytes: 48000,
        finalWidth: 1024,
        finalHeight: 1024,
        targetReached: true,
        attempts: 3,
      ),
    );
    await controller.analyze();
    controller.updateAnalyzedItem(controller.state.analyzedItem!.copyWith(pickupArea: 'Downtown'));

    final result = await controller.publish();
    expect(result, isFalse);
    expect(controller.state.isConfirmRetryBlocked, isTrue);
  });

  test('analyze returns connectivity message on network error', () async {
    final container = _makeContainer(
      service: _FakeService(
        throwOnAnalyze: const ApiException(
          'Sin conexión o red inestable. Verifica internet e intenta de nuevo.',
          kind: ApiErrorKind.network,
        ),
      ),
      history: _MemoryHistoryRepository(),
    );
    addTearDown(container.dispose);

    final controller = container.read(workflowControllerProvider.notifier);
    final image = await _createTempImage('network');

    controller.setPreparedImage(
      imagePath: image.path,
      optimization: ImageOptimizationResult(
        file: image,
        originalBytes: 120000,
        finalBytes: 48000,
        finalWidth: 1024,
        finalHeight: 1024,
        targetReached: true,
        attempts: 3,
      ),
    );

    final analyzed = await controller.analyze();
    expect(analyzed, isFalse);
    expect(controller.state.error, contains('Sin conexión'));
  });

  test('analyze fails before request when image does not exist', () async {
    final container = _makeContainer(
      service: _FakeService(),
      history: _MemoryHistoryRepository(),
    );
    addTearDown(container.dispose);

    final controller = container.read(workflowControllerProvider.notifier);
    final missing = File('${Directory.systemTemp.path}/missing-${DateTime.now().microsecondsSinceEpoch}.jpg');

    controller.setPreparedImage(
      imagePath: missing.path,
      optimization: ImageOptimizationResult(
        file: missing,
        originalBytes: 120000,
        finalBytes: 48000,
        finalWidth: 1024,
        finalHeight: 1024,
        targetReached: true,
        attempts: 3,
      ),
    );

    final analyzed = await controller.analyze();
    expect(analyzed, isFalse);
    expect(controller.state.error, contains('no existe'));
  });
}
