import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../shared/widgets/primary_action.dart';
import '../../../shared/widgets/step_indicator.dart';

class PreviewPage extends ConsumerWidget {
  const PreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workflowControllerProvider.select(
      (s) => (imagePath: s.imagePath, imageBytes: s.imageBytes, isLoading: s.isLoading),
    ));
    final controller = ref.read(workflowControllerProvider.notifier);

    if (state.imagePath == null) {
      return const Scaffold(body: Center(child: Text('No hay imagen seleccionada')));
    }

    final sizeKb = ((state.imageBytes ?? 0) / 1024).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista previa'),
        bottom: const StepIndicator(currentStep: 1),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(state.imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_size_select_small_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$sizeKb KB',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryAction(
                label: 'Analizar con IA',
                icon: Icons.auto_awesome_rounded,
                isBusy: state.isLoading,
                onPressed: () async {
                  final ok = await controller.analyze();
                  if (ok && context.mounted) {
                    Navigator.pushNamed(context, AppRoutes.analysis);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
