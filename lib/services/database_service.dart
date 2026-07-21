import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite şemasını oluşturur ve tekil (singleton) [Database] erişimi sağlar.
///
/// Tablolar: `cards` (seed edilir, salt okunur), `user_progress` (SM-2 verisi),
/// `streak_log` (günlük streak kaydı). Bkz. SAVANT_SPEC.md bölüm 3.
class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService instance = DatabaseService._internal();

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
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, _dbName);

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

  /// Kartların DB'de zaten seed edilip edilmediğini kontrol etmek için kullanılır.
  Future<int> get cardCount async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM $tableCards');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
