import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:savant/main.dart';

void main() {
  testWidgets('Savant app builds and shows skeleton home', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SavantApp()));

    expect(find.text('Savant'), findsOneWidget);
    expect(find.text('Proje iskeleti hazır 🎉'), findsOneWidget);
  });
}
