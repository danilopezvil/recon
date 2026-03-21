import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../domain/models/process_result.dart';
import '../../../shared/widgets/bottom_nav.dart';

final historyProvider = FutureProvider<List<ProcessResult>>(
  (ref) => ref.read(historyRepositoryProvider).getAll(),
);

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: history.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_rounded, size: 52, color: AppColors.textMuted),
                  SizedBox(height: 14),
                  Text(
                    'Sin artículos procesados',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Los artículos que captures aparecerán aquí',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, i) => _HistoryItem(item: items[i]),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: items.length,
          );
        },
        error: (_, __) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
              SizedBox(height: 10),
              Text(
                'Error cargando historial',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 1,
        onTap: (i) {
          if (i == 0) Navigator.pop(context);
        },
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.item});

  final ProcessResult item;

  @override
  Widget build(BuildContext context) {
    final catIcon = _iconForCategory(item.category);
    final catColor = _colorForCategory(item.category);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category icon with status overlay
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: catColor.withOpacity(0.2)),
                ),
                child: Icon(catIcon, size: 22, color: catColor),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: item.success ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(
                    item.success ? Icons.check_rounded : Icons.close_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _ConditionDot(condition: item.condition),
                    _MiniChip(label: item.category),
                    Text(
                      '${item.price} €',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(item.publishedAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
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

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$day/$month/${d.year}  $hour:$min';
  }
}

class _ConditionDot extends StatelessWidget {
  const _ConditionDot({required this.condition});

  final String condition;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (condition) {
      'new' => ('Nuevo', AppColors.success),
      'like_new' => ('Como nuevo', const Color(0xFF0288D1)),
      'good' => ('Buen estado', const Color(0xFF388E3C)),
      'fair' => ('Aceptable', AppColors.warning),
      'parts' => ('Piezas', AppColors.error),
      _ => (condition, AppColors.textMuted),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
