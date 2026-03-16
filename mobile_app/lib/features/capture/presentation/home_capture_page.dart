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
    final state = ref.watch(workflowControllerProvider);
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
              const Text('Captura, revisa y publica rápido. Flujo optimizado para varios objetos seguidos.'),
              const SizedBox(height: 12),
              if (state.lastPublished != null)
                AppSection(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Último envío: ${state.lastPublished!.item.title}')),
                      const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              AppSection(
                child: Column(
                  children: [
                    PrimaryAction(
                      label: 'Tomar foto',
                      isBusy: state.isLoading,
                      onPressed: () async {
                        final ok = await controller.pickFromCamera();
                        if (ok && context.mounted) {
                          Navigator.pushNamed(context, AppRoutes.preview);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: state.isLoading
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
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
