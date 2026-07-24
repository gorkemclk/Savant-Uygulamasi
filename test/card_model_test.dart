import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:savant/models/card_model.dart';

void main() {
  const original = CardModel(
    id: 'hist_001',
    category: 'Tarih',
    question: "İstanbul'un fethi hangi yılda gerçekleşmiştir?",
    options: ['1453', '1071', '1299', '1517'],
    correctIndex: 0,
    explanation: 'test',
    difficulty: 'kolay',
  );

  test('shuffled: doğru cevabın metni her zaman yeni correctIndex konumunda olur', () {
    // Sabit seed: aynı testin her koşulda aynı sonucu vermesini sağlar.
    for (final seed in [1, 2, 3, 4, 5]) {
      final shuffledCard = original.shuffled(Random(seed));

      expect(
        shuffledCard.options[shuffledCard.correctIndex],
        original.options[original.correctIndex],
      );
    }
  });

  test('shuffled: options aynı 4 şıkkı içerir, sadece sırası değişir', () {
    final shuffledCard = original.shuffled(Random(42));

    expect(shuffledCard.options.length, 4);
    expect(
      Set<String>.from(shuffledCard.options),
      Set<String>.from(original.options),
    );
  });

  test('shuffled: orijinal CardModel değişmez (immutable)', () {
    original.shuffled(Random(7));

    expect(original.options, ['1453', '1071', '1299', '1517']);
    expect(original.correctIndex, 0);
  });

  test('shuffled: sıra gerçekten değişebiliyor (en azından bazı seed\'lerde)', () {
    final results = [
      for (final seed in [1, 2, 3, 4, 5, 6, 7, 8]) original.shuffled(Random(seed)).options,
    ];

    final atLeastOneDifferentFromOriginal =
        results.any((options) => options.join() != original.options.join());

    expect(atLeastOneDifferentFromOriginal, isTrue);
  });
}
