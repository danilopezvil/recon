import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/settings/application/api_key_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load any stored API key before the first frame renders.
  // This avoids a flicker where the env key is used briefly before
  // the async load completes.
  final container = ProviderContainer();
  await container.read(apiKeyNotifierProvider.notifier).loadFromStorage();

  runApp(UncontrolledProviderScope(
    container: container,
    child: const App(),
  ));
}
