export 'service_providers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/capture/application/workflow_controller.dart';

final workflowControllerProvider = NotifierProvider<WorkflowController, WorkflowState>(
  WorkflowController.new,
);
