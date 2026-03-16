import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../shared/widgets/app_section.dart';
import '../../../shared/widgets/primary_action.dart';

class HomeCapturePage extends ConsumerWidget {
  const HomeCapturePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(workflowControllerProvider.select((s) => s.isLoading));
    final error = ref.watch(workflowControllerProvider.select((s) => s.error));
    final controller = ref.read(workflowControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Captura rápida'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Foto del artículo', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Elige cámara o galería. La app comprimirá automáticamente a 50 KB o menos.'),
              const SizedBox(height: 18),
              AppSection(
                child: Column(
                  children: [
                    PrimaryAction(
                      label: 'Tomar foto',
                      isBusy: isLoading,
                      onPressed: () async {
                        final ok = await controller.pickFromCamera();
                        if (ok && context.mounted) {
                          Navigator.pushNamed(context, AppRoutes.preview);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final ok = await controller.pickFromGallery();
                              if (ok && context.mounted) {
                                Navigator.pushNamed(context, AppRoutes.preview);
                              }
                            },
                      child: const Text('Seleccionar de galería'),
                    ),
                  ],
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error, style: const TextStyle(color: Colors.redAccent)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
