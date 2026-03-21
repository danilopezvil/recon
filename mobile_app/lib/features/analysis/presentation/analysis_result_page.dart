import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../domain/models/analyzed_item.dart';
import '../../../shared/widgets/step_indicator.dart';

class AnalysisResultPage extends ConsumerWidget {
  const AnalysisResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(workflowControllerProvider).analyzedItem;

    if (item == null) {
      return const Scaffold(body: Center(child: Text('No hay análisis disponible')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis'),
        bottom: const StepIndicator(currentStep: 2),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCard(item: item),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _MetaChip(
                          icon: _iconForCategory(item.category),
                          label: _labelForCategory(item.category),
                          color: _colorForCategory(item.category),
                        ),
                        const SizedBox(width: 8),
                        _MetaChip(
                          icon: _iconForCondition(item.condition),
                          label: _labelForCondition(item.condition),
                          color: _colorForCondition(item.condition),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _FieldCard(
                      icon: Icons.location_on_rounded,
                      label: 'Zona de recogida',
                      value: item.pickupArea.isNotEmpty ? item.pickupArea : '—',
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _FieldCard(
                        icon: Icons.notes_rounded,
                        label: 'Descripción',
                        value: item.description,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.edit),
                      icon: const Icon(Icons.edit_rounded, size: 17),
                      label: const Text('Editar datos'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.publish),
                      icon: const Icon(Icons.rocket_launch_rounded, size: 17),
                      label: const Text('Publicar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconForCategory(String cat) => switch (cat) {
        'kitchen' => Icons.restaurant_menu_rounded,
        'books' => Icons.menu_book_rounded,
        'home' => Icons.home_rounded,
        'electronics' => Icons.devices_rounded,
        _ => Icons.category_rounded,
      };

  static Color _colorForCategory(String cat) => switch (cat) {
        'kitchen' => const Color(0xFFEF6C00),
        'books' => const Color(0xFF6D4C41),
        'home' => const Color(0xFF2E7D32),
        'electronics' => AppColors.accent,
        _ => AppColors.textSecondary,
      };

  static IconData _iconForCondition(String cond) => switch (cond) {
        'new' => Icons.fiber_new_rounded,
        'like_new' => Icons.stars_rounded,
        'good' => Icons.thumb_up_rounded,
        'fair' => Icons.thumbs_up_down_rounded,
        'parts' => Icons.build_rounded,
        _ => Icons.help_outline_rounded,
      };

  static Color _colorForCondition(String cond) => switch (cond) {
        'new' => AppColors.success,
        'like_new' => const Color(0xFF0288D1),
        'good' => const Color(0xFF388E3C),
        'fair' => AppColors.warning,
        'parts' => AppColors.error,
        _ => AppColors.textSecondary,
      };

  static String _labelForCategory(String cat) => switch (cat) {
        'kitchen' => 'Cocina',
        'books' => 'Libros',
        'home' => 'Hogar',
        'electronics' => 'Electrónica',
        _ => cat.isEmpty ? 'Otro' : cat,
      };

  static String _labelForCondition(String cond) => switch (cond) {
        'new' => 'Nuevo',
        'like_new' => 'Como nuevo',
        'good' => 'Buen estado',
        'fair' => 'Aceptable',
        'parts' => 'Para piezas',
        _ => cond.isEmpty ? 'N/D' : cond,
      };
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.item});

  final AnalyzedItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0x99FFFFFF)),
              const SizedBox(width: 6),
              const Text(
                'Sugerido por IA',
                style: TextStyle(fontSize: 11, color: Color(0x99FFFFFF), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${item.price} €',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
