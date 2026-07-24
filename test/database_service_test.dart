import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:savant/services/database_service.dart';
import 'package:savant/services/seed_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseService dbService;

  setUp(() async {
    dbService = DatabaseService.forTesting(inMemoryDatabasePath);
    await SeedService(databaseService: dbService).seedIfNeeded();
  });

  tearDown(() async {
    await dbService.close();
  });

  test('getTodaysCards: seed hemen sonrası tüm kartlar next_review_date=bugün '
      'olduğu için limit kadar kart döner', () async {
    final cards = await dbService.getTodaysCards(limit: 15);

    expect(cards.length, 15);
    expect(cards.every((c) => c.options.length == 4), isTrue);
  });

  test('getTodaysCards: limit parametresine uyar', () async {
    final cards = await dbService.getTodaysCards(limit: 5);
    expect(cards.length, 5);
  });

  test('getTodaysCards: next_review_date bugünden ileri olan kartları hariç tutar', () async {
    final db = await dbService.database;
    // Tüm kartların gösterim tarihini yarına ötele.
    await db.update(
      DatabaseService.tableUserProgress,
      {'next_review_date': '2999-01-01'},
    );

    final cards = await dbService.getTodaysCards(limit: 15);
    expect(cards, isEmpty);
  });

  test('getCategoryProgress: seed sonrası hiç "known" kart yok, hepsi %0', () async {
    final progress = await dbService.getCategoryProgress();

    expect(progress.keys.toSet(), {'Tarih', 'Jeopolitik', 'Bilim', 'Sanat', 'Genel Kültür'});
    expect(progress.values.every((v) => v == 0.0), isTrue);
  });

  test('getCategoryProgress: status "known" olan kartlar orana yansır', () async {
    final db = await dbService.database;
    await db.update(
      DatabaseService.tableUserProgress,
      {'status': 'known'},
      where: 'card_id = ?',
      whereArgs: ['hist_001'],
    );

    final progress = await dbService.getCategoryProgress();
    expect(progress['Tarih'], greaterThan(0.0));
  });
}
