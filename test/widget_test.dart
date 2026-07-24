import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:savant/screens/home_screen.dart';
import 'package:savant/services/database_service.dart';
import 'package:savant/services/seed_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  // NoIsolate: sorguları ayrı bir isolate yerine aynı isolate'te çalıştırır.
  databaseFactory = databaseFactoryFfiNoIsolate;

  testWidgets('HomeScreen bugünün kartlarını ve kategori ilerlemesini gösterir', (
    tester,
  ) async {
    // tester.pump()'ın "sahte zaman" mekanizması, sqflite_common_ffi'nin
    // gerçek FFI çağrıları için ihtiyaç duyduğu gerçek event loop tick'lerini
    // vermiyor ve await sonsuza dek askıda kalıyor. tester.runAsync(),
    // Flutter'ın gerçek async I/O (dosya/DB/plugin) için testWidgets içinde
    // kullanılmasını önerdiği resmi kaçış kapısı.
    await tester.runAsync(() async {
      final dbService = DatabaseService.forTesting(inMemoryDatabasePath);
      await SeedService(databaseService: dbService).seedIfNeeded();

      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(databaseService: dbService)),
      );

      // HomeScreen.initState() içindeki _loadData() da gerçek FFI I/O
      // kullanıyor; veri gelene kadar gerçek zamanlı bekleyip UI'ı
      // güncellemek için pump ediyoruz.
      for (var i = 0; i < 20; i++) {
        if (find.textContaining('Bugünün Kartları').evaluate().isNotEmpty) break;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }

      expect(find.text('Savant'), findsOneWidget);
      expect(find.textContaining('Bugünün Kartları'), findsOneWidget);
      for (final category in ['Tarih', 'Jeopolitik', 'Bilim', 'Sanat', 'Genel Kültür']) {
        expect(find.text(category), findsOneWidget);
      }

      await dbService.close();
    });
  });
}
