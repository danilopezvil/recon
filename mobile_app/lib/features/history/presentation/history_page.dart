import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/models/process_result.dart';

final historyProvider = FutureProvider<List<ProcessResult>>(
  (ref) => ref.read(historyRepositoryProvider).getAll(),
);

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
                title: Text(e.title),
                subtitle: Text('${e.flowType} · ${e.category} · ${e.condition} · ${e.price}€'),
                trailing: Text(e.success ? 'ok' : 'fail'),
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
