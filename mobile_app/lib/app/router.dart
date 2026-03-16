import 'package:flutter/material.dart';

import '../features/analysis/presentation/analysis_result_page.dart';
import '../features/capture/presentation/home_capture_page.dart';
import '../features/edit/presentation/manual_edit_page.dart';
import '../features/history/presentation/history_page.dart';
import '../features/preview/presentation/preview_page.dart';
import '../features/publish/presentation/publish_confirmation_page.dart';

class AppRoutes {
  static const home = '/';
  static const preview = '/preview';
  static const analysis = '/analysis';
  static const edit = '/edit';
  static const publish = '/publish';
  static const history = '/history';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.preview:
      return MaterialPageRoute(builder: (_) => const PreviewPage());
    case AppRoutes.analysis:
      return MaterialPageRoute(builder: (_) => const AnalysisResultPage());
    case AppRoutes.edit:
      return MaterialPageRoute(builder: (_) => const ManualEditPage());
    case AppRoutes.publish:
      return MaterialPageRoute(builder: (_) => const PublishConfirmationPage());
    case AppRoutes.history:
      return MaterialPageRoute(builder: (_) => const HistoryPage());
    case AppRoutes.home:
    default:
      return MaterialPageRoute(builder: (_) => const HomeCapturePage());
  }
}
