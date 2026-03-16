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

    if (state.imagePath == null) {
      return const Scaffold(body: Center(child: Text('No hay imagen seleccionada')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Vista previa')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(state.imagePath!), fit: BoxFit.cover, width: double.infinity),
                ),
              ),
              const SizedBox(height: 12),
              AppSection(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Peso final'),
                    Text('${((state.imageBytes ?? 0) / 1024).toStringAsFixed(1)} KB'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PrimaryAction(
                label: 'Analizar',
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
