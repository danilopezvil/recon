import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial local')),
      body: history.when(
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('Sin elementos procesados aún.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, i) {
              final e = items[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFFE8EAEE)),
                ),
                title: Text(e.item.title),
                subtitle: Text(
                  '${e.item.category} · ${e.item.condition} · ${e.item.price}€\n${e.createdAt.toLocal()}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${(e.imageBytes / 1024).toStringAsFixed(1)} KB'),
                    Icon(
                      e.published ? Icons.check_circle : Icons.error_outline,
                      size: 16,
                      color: e.published ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: items.length,
          );
        },
        error: (_, __) => const Center(child: Text('Error cargando historial')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
