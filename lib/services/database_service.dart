import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/card_model.dart';

/// Telefon hafızasında savant.db adında yerel veritabanı dosyasını yönetir.
class DatabaseService {
  DatabaseService._internal({String? testPath}) : _testPath = testPath;

  static final DatabaseService instance = DatabaseService._internal();

  factory DatabaseService.forTesting(String path) =>
      DatabaseService._internal(testPath: path);

  final String? _testPath;

  static const String _dbName = 'savant.db';
  static const int _dbVersion = 1;

  static const String tableCards = 'cards';
  static const String tableUserProgress = 'user_progress';
  static const String tableStreakLog = 'streak_log';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = _testPath ??
        join((await getApplicationDocumentsDirectory()).path, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCards (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        question TEXT NOT NULL,
        options TEXT NOT NULL,
        correct_index INTEGER NOT NULL,
        explanation TEXT NOT NULL,
        difficulty TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableUserProgress (
        card_id TEXT PRIMARY KEY,
        repetition_count INTEGER NOT NULL DEFAULT 0,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        interval_days INTEGER NOT NULL DEFAULT 0,
        next_review_date TEXT NOT NULL,
        last_reviewed_date TEXT,
        status TEXT NOT NULL DEFAULT 'new',
        FOREIGN KEY (card_id) REFERENCES $tableCards (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableStreakLog (
        date TEXT PRIMARY KEY,
        cards_completed INTEGER NOT NULL DEFAULT 0,
        streak_count INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> get cardCount async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM $tableCards');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// `next_review_date`'i bugüne veya öncesine denk gelen kartları döner.
  ///
  /// Kartlar seed edilirken `next_review_date` seed gününe ayarlandığı için
  /// (bkz. seed_service.dart), bu tek koşul hem "vadesi gelmiş eski kartları"
  /// hem "hiç görülmemiş yeni kartları" birlikte kapsar.
  Future<List<CardModel>> getTodaysCards({int limit = 15, DateTime? now}) async {
    final db = await database;
    final today = DateFormat('yyyy-MM-dd').format(now ?? DateTime.now());

    final rows = await db.rawQuery('''
      SELECT $tableCards.* FROM $tableCards
      INNER JOIN $tableUserProgress ON $tableCards.id = $tableUserProgress.card_id
      WHERE $tableUserProgress.next_review_date <= ?
      ORDER BY RANDOM()
      LIMIT ?
    ''', [today, limit]);

    return rows.map(CardModel.fromMap).toList();
  }

  /// Kategori başına "known" durumundaki kartların oranını (0.0 - 1.0) döner.
  Future<Map<String, double>> getCategoryProgress() async {
    final db = await database;

    final rows = await db.rawQuery('''
      SELECT $tableCards.category AS category,
             COUNT(*) AS total,
             SUM(CASE WHEN $tableUserProgress.status = 'known' THEN 1 ELSE 0 END) AS known
      FROM $tableCards
      INNER JOIN $tableUserProgress ON $tableCards.id = $tableUserProgress.card_id
      GROUP BY $tableCards.category
    ''');

    return {
      for (final row in rows)
        row['category'] as String: (row['known'] as int) / (row['total'] as int),
    };
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
