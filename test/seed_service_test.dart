import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:savant/services/database_service.dart';
import 'package:savant/services/seed_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('seedIfNeeded assets/cards.json içindeki tüm kartları ve karşılık gelen '
      'user_progress satırlarını doğru alanlarla yazar, ikinci çağrıda '
      'tekrarlamaz', () async {
    final dbService = DatabaseService.forTesting(inMemoryDatabasePath);
    final seedService = SeedService(databaseService: dbService);

    await seedService.seedIfNeeded();

    final db = await dbService.database;
    final cardRows = await db.query(DatabaseService.tableCards);
    final progressRows = await db.query(DatabaseService.tableUserProgress);

    expect(cardRows.length, 150);
    expect(progressRows.length, 150);

    final histCard = cardRows.firstWhere((row) => row['id'] == 'hist_001');
    expect(histCard['category'], 'Tarih');
    expect(histCard['correct_index'], 0);
    final options = jsonDecode(histCard['options'] as String) as List;
    expect(options, hasLength(4));
    expect(options, contains('1453'));

    final histProgress =
        progressRows.firstWhere((row) => row['card_id'] == 'hist_001');
    expect(histProgress['status'], 'new');
    expect(histProgress['repetition_count'], 0);
    expect(histProgress['ease_factor'], 2.5);
    expect(histProgress['interval_days'], 0);
    expect(histProgress['last_reviewed_date'], isNull);
    expect(histProgress['next_review_date'], isNotNull);

    // İkinci çağrı: DB zaten dolu olduğu için tekrar seed etmemeli.
    await seedService.seedIfNeeded();
    final cardRowsAfterSecondCall = await db.query(DatabaseService.tableCards);
    expect(cardRowsAfterSecondCall.length, 150);

    await dbService.close();
  });
}
