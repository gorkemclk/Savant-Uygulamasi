import 'package:flutter/material.dart';

import '../models/card_model.dart';
import '../widgets/flip_card_widget.dart';

/// Verilen kart listesini tek tek gösterir, cevapları ve zorluk seçimlerini
/// toplar, bitince özet ekranını gösterir.
///
/// SM-2 güncellemesi (zorluk seçimine göre ease_factor/interval_days
/// hesaplama) henüz burada yapılmıyor — Gün 5'te bağlanacak. Streak
/// güncellemesi de Gün 7'nin işi.
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, required this.cards});

  final List<CardModel> cards;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late final List<CardModel> _shuffledCards;
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  int _correctCount = 0;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
    _shuffledCards = widget.cards.map((card) => card.shuffled()).toList();
  }

  CardModel get _currentCard => _shuffledCards[_currentIndex];

  bool get _isFinished => _currentIndex >= _shuffledCards.length;

  void _selectOption(int index) {
    if (_selectedOptionIndex != null) return;
    setState(() {
      _selectedOptionIndex = index;
      if (index == _currentCard.correctIndex) {
        _correctCount++;
      } else {
        _wrongCount++;
      }
    });
  }

  void _rateDifficulty(String difficulty) {
    setState(() {
      _currentIndex++;
      _selectedOptionIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_shuffledCards.isEmpty || _isFinished) {
      return _SummaryView(correctCount: _correctCount, wrongCount: _wrongCount);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${_shuffledCards.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FlipCardWidget(
          card: _currentCard,
          selectedOptionIndex: _selectedOptionIndex,
          onSelectOption: _selectOption,
          onRateDifficulty: _rateDifficulty,
        ),
      ),
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({required this.correctCount, required this.wrongCount});

  final int correctCount;
  final int wrongCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Özet')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Doğru: $correctCount', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Yanlış: $wrongCount', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    );
  }
}
