import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

import '../models/card_model.dart';
import '../models/user_progress_model.dart';
import 'database_service.dart';

/// card.json'daki verileri veritabanına aktaran kısım.
class SeedService {
  SeedService({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  Future<void> seedIfNeeded() async {
    final existingCount = await _databaseService.cardCount;
    if (existingCount > 0) return;

    final raw = await rootBundle.loadString('assets/cards.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final cardsJson = decoded['cards'] as List;
    final cards = cardsJson
        .map((e) => CardModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final db = await _databaseService.database;
    final batch = db.batch();

    for (final card in cards) {
      batch.insert(DatabaseService.tableCards, card.toMap());
      batch.insert(
        DatabaseService.tableUserProgress,
        UserProgressModel(cardId: card.id, nextReviewDate: today).toMap(),
      );
    }

    await batch.commit(noResult: true);
  }
}
