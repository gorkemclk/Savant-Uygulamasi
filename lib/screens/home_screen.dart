import 'package:flutter/material.dart';

import '../models/card_model.dart';
import '../services/database_service.dart';
import '../widgets/category_progress_bar.dart';
import '../widgets/streak_badge.dart';
import 'study_screen.dart';

const _kCategoryOrder = ['Tarih', 'Jeopolitik', 'Bilim', 'Sanat', 'Genel Kültür'];

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CardModel>? _todaysCards;
  Map<String, double> _categoryProgress = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cards = await widget._databaseService.getTodaysCards(limit: 15);
    final progress = await widget._databaseService.getCategoryProgress();
    if (!mounted) return;
    setState(() {
      _todaysCards = cards;
      _categoryProgress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = _todaysCards;

    return Scaffold(
      appBar: AppBar(title: const Text('Savant')),
      body: cards == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const StreakBadge(streakCount: 0),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: cards.isEmpty ? null : () => _openStudyScreen(cards),
                  child: Text(
                    cards.isEmpty
                        ? 'Bugün için kart yok'
                        : 'Bugünün Kartları (${cards.length})',
                  ),
                ),
                const SizedBox(height: 32),
                Text('Kategori İlerlemesi', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                for (final category in _kCategoryOrder)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CategoryProgressBar(
                      category: category,
                      progress: _categoryProgress[category] ?? 0.0,
                    ),
                  ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: null,
                  child: const Text('Quiz Modu (yakında)'),
                ),
              ],
            ),
    );
  }

  void _openStudyScreen(List<CardModel> cards) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StudyScreen(cards: cards)),
    );
  }
}
