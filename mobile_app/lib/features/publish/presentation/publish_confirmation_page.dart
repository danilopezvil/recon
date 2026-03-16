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

    final isPublished = state.lastPublished != null && state.step == WorkflowStep.published;

    return Scaffold(
      appBar: AppBar(title: const Text('Publicación')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPublished ? 'Publicado (simulado)' : 'Listo para enviar',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              isPublished
                  ? 'Puedes volver al inicio para capturar otro artículo.'
                  : 'Publicación simulada. La integración real se conectará en la siguiente fase.',
            ),
            const SizedBox(height: 12),
            AppSection(
              child: Text(state.analyzedItem?.title ?? 'Sin título'),
            ),
            const Spacer(),
            if (!isPublished)
              PrimaryAction(
                label: 'Publicar (simulado)',
                isBusy: state.isLoading,
                onPressed: () async {
                  await controller.publish();
                },
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        controller.resetFlow();
                        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
                      },
                      child: const Text('Nuevo artículo'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
                      child: const Text('Ver historial'),
                    ),
                  ),
                ],
              ),
            if (state.error != null) ...[
              const SizedBox(height: 10),
              Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
            ],
          ],
        ),
      ),
    );
  }
}
