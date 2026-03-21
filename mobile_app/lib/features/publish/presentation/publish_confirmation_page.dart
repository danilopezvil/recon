import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../domain/models/analyzed_item.dart';
import '../../../features/capture/application/workflow_controller.dart';
import '../../../shared/widgets/primary_action.dart';
import '../../../shared/widgets/step_indicator.dart';

class PublishConfirmationPage extends ConsumerWidget {
  const PublishConfirmationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workflowControllerProvider);
    final controller = ref.read(workflowControllerProvider.notifier);
    final isSuccess = state.step == WorkflowStep.publishedSuccess;

    Future<void> goNext() async {
      await controller.startNextItem();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicación'),
        bottom: const StepIndicator(currentStep: 3),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isSuccess
              ? _SuccessView(
                  itemTitle: state.analyzedItem?.title ?? '',
                  onNext: goNext,
                )
              : _ConfirmView(
                  item: state.analyzedItem,
                  isLoading: state.isLoading,
                  isRetryBlocked: state.isConfirmRetryBlocked,
                  blockedSeconds: state.confirmRetryRemaining?.inSeconds,
                  onPublish: () async {
                    final ok = await controller.publish();
                    if (!context.mounted) return;
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ref.read(workflowControllerProvider).error ?? 'No se pudo publicar',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  onNext: goNext,
                ),
        ),
      ),
    );
  }
}

class _ConfirmView extends StatelessWidget {
  const _ConfirmView({
    required this.item,
    required this.isLoading,
    required this.isRetryBlocked,
    required this.blockedSeconds,
    required this.onPublish,
    required this.onNext,
  });

  final AnalyzedItem? item;
  final bool isLoading;
  final bool isRetryBlocked;
  final int? blockedSeconds;
  final VoidCallback onPublish;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Listo para publicar',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4),
        ),
        const SizedBox(height: 6),
        const Text(
          'Revisa los datos y confirma la publicación.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 20),
        if (item != null) ...[
          _ItemSummaryCard(item: item!),
          const SizedBox(height: 12),
        ],
        if (isRetryBlocked) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color(0x4DF59E0B)),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_rounded, color: AppColors.warning, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Rate limit: espera ${blockedSeconds ?? 0}s para reintentar.',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        const Spacer(),
        PrimaryAction(
          label: isRetryBlocked
              ? 'Bloqueado (${blockedSeconds ?? 0}s)'
              : 'Confirmar y publicar',
          isBusy: isLoading,
          onPressed: isRetryBlocked ? null : onPublish,
          icon: Icons.send_rounded,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : onNext,
            child: const Text('Saltar y capturar otro artículo'),
          ),
        ),
      ],
    );
  }
}

class _ItemSummaryCard extends StatelessWidget {
  const _ItemSummaryCard({required this.item});

  final AnalyzedItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Badge(label: '${item.price} €', color: AppColors.accent),
              _Badge(label: item.category),
              _Badge(label: item.condition),
            ],
          ),
          if (item.pickupArea.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  item.pickupArea,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.itemTitle, required this.onNext});

  final String itemTitle;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: AppColors.success, size: 42),
        ),
        const SizedBox(height: 20),
        const Text(
          '¡Publicado!',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.4),
        ),
        const SizedBox(height: 8),
        Text(
          itemTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.4),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Capturar otro artículo'),
          ),
        ),
      ],
    );
  }
}
