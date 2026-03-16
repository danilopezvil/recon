import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../shared/widgets/app_section.dart';

class AnalysisResultPage extends ConsumerWidget {
  const AnalysisResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(workflowControllerProvider).analyzedItem;

    if (item == null) {
      return const Scaffold(body: Center(child: Text('No hay análisis disponible')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado de análisis')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppSection(
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(item.toJson()),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12.8),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.edit),
                child: const Text('Editar JSON manualmente'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.publish),
                child: const Text('Continuar a publicación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
