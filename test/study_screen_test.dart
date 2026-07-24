import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:savant/models/card_model.dart';
import 'package:savant/screens/study_screen.dart';

void main() {
  const card1 = CardModel(
    id: 'c1',
    category: 'Tarih',
    question: 'Soru 1',
    options: ['A', 'B', 'C', 'D'],
    correctIndex: 0,
    explanation: 'Açıklama 1',
    difficulty: 'kolay',
  );
  const card2 = CardModel(
    id: 'c2',
    category: 'Bilim',
    question: 'Soru 2',
    options: ['E', 'F', 'G', 'H'],
    correctIndex: 2,
    explanation: 'Açıklama 2',
    difficulty: 'orta',
  );

  testWidgets(
    'kart cevaplanır, zorluk seçilir, sıradaki karta geçilir, sonda özet gösterilir',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StudyScreen(cards: [card1, card2])),
      );

      // 1. kart gösteriliyor.
      expect(find.text('Soru 1'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);

      // Yanlış şıkkı seç (doğrusu 'A', 'B' yanlış).
      await tester.tap(find.text('B'));
      await tester.pump();

      expect(find.text('Yanlış'), findsOneWidget);
      expect(find.text('Açıklama 1'), findsOneWidget);

      // Zorluk seç -> sıradaki karta geçmeli. Buton, cevap+açıklama
      // gösterildiği için kaydırılabilir alanın altında kalmış olabilir.
      await tester.ensureVisible(find.text('Orta'));
      await tester.tap(find.text('Orta'));
      await tester.pump();

      expect(find.text('Soru 2'), findsOneWidget);
      expect(find.text('2 / 2'), findsOneWidget);

      // Doğru şıkkı seç ('G', correctIndex=2).
      await tester.tap(find.text('G'));
      await tester.pump();

      expect(find.text('Doğru!'), findsOneWidget);

      // Son karttan sonra zorluk seçilince özet ekranına geçmeli.
      await tester.ensureVisible(find.text('Kolay'));
      await tester.tap(find.text('Kolay'));
      await tester.pump();

      expect(find.text('Özet'), findsOneWidget);
      expect(find.text('Doğru: 1'), findsOneWidget);
      expect(find.text('Yanlış: 1'), findsOneWidget);
    },
  );

  testWidgets('cevaplanmadan zorluk butonları görünmez', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StudyScreen(cards: [card1])),
    );

    expect(find.text('Zor'), findsNothing);
    expect(find.text('Orta'), findsNothing);
    expect(find.text('Kolay'), findsNothing);
  });
}
