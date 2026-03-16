import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../shared/widgets/app_section.dart';
import '../../../shared/widgets/primary_action.dart';

class PreviewPage extends ConsumerWidget {
  const PreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workflowControllerProvider);
    final controller = ref.read(workflowControllerProvider.notifier);

    if (state.imagePath == null || state.optimization == null) {
      return const Scaffold(body: Center(child: Text('No hay imagen seleccionada')));
    }

    final opt = state.optimization!;

    return Scaffold(
      appBar: AppBar(title: const Text('Vista previa')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(state.imagePath!), fit: BoxFit.cover, width: double.infinity),
                ),
              ),
              const SizedBox(height: 12),
              AppSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _line('Original', '${(opt.originalBytes / 1024).toStringAsFixed(1)} KB'),
                    _line('Final', '${(opt.finalBytes / 1024).toStringAsFixed(1)} KB'),
                    _line('Resolución usada', '${opt.finalWidth}x${opt.finalHeight}'),
                    _line('Intentos', '${opt.attempts}'),
                    _line('Objetivo ≤50KB', opt.targetReached ? 'Sí' : 'No (se mantuvo legibilidad)'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PrimaryAction(
                label: 'Analizar (mock)',
                isBusy: state.isLoading,
                onPressed: () async {
                  final ok = await controller.analyze();
                  if (ok && context.mounted) {
                    Navigator.pushNamed(context, AppRoutes.analysis);
                  }
                },
              ),
              if (state.error != null) ...[
                const SizedBox(height: 8),
                Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))],
      ),
    );
  }
}
