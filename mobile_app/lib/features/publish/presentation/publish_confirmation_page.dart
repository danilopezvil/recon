import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../shared/widgets/app_section.dart';
import '../../../shared/widgets/primary_action.dart';

class PublishConfirmationPage extends ConsumerWidget {
  const PublishConfirmationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workflowControllerProvider);
    final controller = ref.read(workflowControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Publicación')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Listo para enviar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('En esta fase la publicación es simulada. El contrato remoto ya está preparado.'),
            const SizedBox(height: 12),
            AppSection(
              child: Text(state.analyzedItem?.title ?? 'Sin título'),
            ),
            const Spacer(),
            PrimaryAction(
              label: 'Publicar (simulado)',
              isBusy: state.isLoading,
              onPressed: () async {
                final ok = await controller.publish();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Publicado (mock)' : 'No se pudo publicar')),
                );
                if (ok) {
                  controller.resetFlow();
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
