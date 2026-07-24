import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/home_screen.dart';
import 'services/seed_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SeedService().seedIfNeeded();
  runApp(SavantApp());
}

class SavantApp extends StatelessWidget {
  SavantApp({super.key});

  /// Ekranlar arası paylaşılan tek state instance'ı. İhtiyacı olan
  /// ekranlara constructor üzerinden geçirilir (bkz. app_state.dart).
  final AppState appState = AppState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savant',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
