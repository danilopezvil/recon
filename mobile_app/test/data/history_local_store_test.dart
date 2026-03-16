import 'package:flutter_test/flutter_test.dart';
import 'package:recon_mobile_app/data/local/history_local_store.dart';
import 'package:recon_mobile_app/domain/models/process_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HistoryLocalStore', () {
    test('stores and returns sorted records by date desc', () async {
      SharedPreferences.setMockInitialValues({});
      final store = HistoryLocalStore();

      final older = ProcessResult(
        id: '1',
        flowType: 'ai_assisted',
        imageUrl: 'a',
        title: 'A',
        category: 'books',
        condition: 'good',
        price: 1,
        pickupArea: 'X',
        publishedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        success: true,
      );
      final newer = older.copyWith(id: '2', publishedAt: DateTime.parse('2024-01-03T00:00:00.000Z'));

      await store.save(older);
      await store.save(newer);

      final all = await store.getAll();
      expect(all.first.id, '2');
      expect(all.last.id, '1');
    });

    test('limits history to 50 records', () async {
      SharedPreferences.setMockInitialValues({});
      final store = HistoryLocalStore();

      for (var i = 0; i < 55; i++) {
        await store.save(
          ProcessResult(
            id: '$i',
            flowType: 'manual',
            imageUrl: '/$i.jpg',
            title: 'T',
            category: 'c',
            condition: 'good',
            price: i,
            pickupArea: 'p',
            publishedAt: DateTime.now().add(Duration(minutes: i)),
            success: true,
          ),
        );
      }

      final all = await store.getAll();
      expect(all.length, 50);
    });
  });
}
