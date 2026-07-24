import 'package:flutter/material.dart';

import '../models/card_model.dart';

enum _OptionVisualState { neutral, correct, wrongSelected }

/// Tek bir kartı gösterir: soru + şıklar. Cevaplandıktan sonra doğru/yanlış
/// geri bildirimi, açıklama ve zorluk seçimi (Zor/Orta/Kolay) eklenir.
class FlipCardWidget extends StatelessWidget {
  const FlipCardWidget({
    super.key,
    required this.card,
    required this.selectedOptionIndex,
    required this.onSelectOption,
    required this.onRateDifficulty,
  });

  final CardModel card;
  final int? selectedOptionIndex;
  final ValueChanged<int> onSelectOption;
  final ValueChanged<String> onRateDifficulty;

  bool get _isAnswered => selectedOptionIndex != null;

  _OptionVisualState _optionState(int index) {
    if (!_isAnswered) return _OptionVisualState.neutral;
    if (index == card.correctIndex) return _OptionVisualState.correct;
    if (index == selectedOptionIndex) return _OptionVisualState.wrongSelected;
    return _OptionVisualState.neutral;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.category, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Text(card.question, style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < card.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _OptionButton(
                text: card.options[i],
                state: _optionState(i),
                onTap: _isAnswered ? null : () => onSelectOption(i),
              ),
            ),
          if (_isAnswered) ...[
            const SizedBox(height: 8),
            Card(
              color: selectedOptionIndex == card.correctIndex
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedOptionIndex == card.correctIndex ? 'Doğru!' : 'Yanlış',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(card.explanation),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bu kart sana ne kadar zor geldi?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onRateDifficulty('zor'),
                    child: const Text('Zor'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onRateDifficulty('orta'),
                    child: const Text('Orta'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onRateDifficulty('kolay'),
                    child: const Text('Kolay'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({required this.text, required this.state, required this.onTap});

  final String text;
  final _OptionVisualState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color? backgroundColor, Color? borderColor) = switch (state) {
      _OptionVisualState.correct => (Colors.green.withValues(alpha: 0.15), Colors.green),
      _OptionVisualState.wrongSelected => (Colors.red.withValues(alpha: 0.15), Colors.red),
      _OptionVisualState.neutral => (null, null),
    };

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        side: borderColor != null ? BorderSide(color: borderColor) : null,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        alignment: Alignment.centerLeft,
      ),
      child: Text(text),
    );
  }
}
