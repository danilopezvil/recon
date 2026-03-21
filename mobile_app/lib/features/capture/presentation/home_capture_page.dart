import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/primary_action.dart';
import '../../../shared/widgets/step_indicator.dart';

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
            tooltip: 'Configuración',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
        bottom: const StepIndicator(currentStep: 0),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Foto del artículo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Elige cámara o galería. La app comprimirá automáticamente a 50 KB o menos.',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    PrimaryAction(
                      label: 'Tomar foto',
                      icon: Icons.camera_alt_rounded,
                      isBusy: isLoading,
                      onPressed: () async {
                        final ok = await controller.pickFromCamera();
                        if (ok && context.mounted) {
                          Navigator.pushNamed(context, AppRoutes.preview);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final ok = await controller.pickFromGallery();
                                if (ok && context.mounted) {
                                  Navigator.pushNamed(context, AppRoutes.preview);
                                }
                              },
                        icon: const Icon(Icons.photo_library_rounded, size: 18),
                        label: const Text('Seleccionar de galería'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _TipRow(
                icon: Icons.compress_rounded,
                text: 'La imagen se comprimirá automáticamente a ≤ 50 KB.',
              ),
              const SizedBox(height: 8),
              _TipRow(
                icon: Icons.auto_awesome_rounded,
                text: 'La IA detectará el título, precio y categoría.',
              ),
              if (error != null) ...[
                const SizedBox(height: 16),
                _ErrorBanner(message: error),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 0,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, AppRoutes.history);
        },
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0x33EF4444)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
