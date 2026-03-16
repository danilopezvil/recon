import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:recon_mobile_app/core/utils/image_optimizer.dart';
import 'package:recon_mobile_app/domain/models/analyzed_item.dart';
import 'package:recon_mobile_app/domain/models/process_result.dart';
import 'package:recon_mobile_app/domain/models/publish_payload.dart';
import 'package:recon_mobile_app/domain/repositories/history_repository.dart';
import 'package:recon_mobile_app/domain/services/item_processing_service.dart';
import 'package:recon_mobile_app/features/capture/application/workflow_controller.dart';

class _FakeService implements ItemProcessingService {
  @override
  Future<AnalyzedItem> analyzeItem(String imagePath) async => const AnalyzedItem(
        title: 'Mock item',
        price: 22,
        category: 'home',
        condition: 'good',
        pickupArea: 'Centro',
        description: 'desc',
      );

  @override
  Future<bool> publishItem(PublishPayload payload) async => true;
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

void main() {
  test('workflow transitions imageReady -> analyzed -> published', () async {
    final history = _MemoryHistoryRepository();
    final controller = WorkflowController(_FakeService(), history);

    controller.setPreparedImage(
      imagePath: '/tmp/item.jpg',
      optimization: ImageOptimizationResult(
        file: File('/tmp/item.jpg'),
        originalBytes: 120000,
        finalBytes: 48000,
        finalWidth: 1024,
        finalHeight: 1024,
        targetReached: true,
        attempts: 3,
      ),
    );

    expect(controller.state.step, WorkflowStep.imageReady);

    final analyzed = await controller.analyze();
    expect(analyzed, isTrue);
    expect(controller.state.step, WorkflowStep.analyzed);
    expect(controller.state.analyzedItem?.title, 'Mock item');

    final published = await controller.publish();
    expect(published, isTrue);
    expect(controller.state.step, WorkflowStep.published);
    expect(history.items.length, 1);
  });
}
