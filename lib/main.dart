import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: SavantApp()));
}

class SavantApp extends StatelessWidget {
  const SavantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savant',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const _SkeletonHome(),
    );
  }
}

/// Gün 1 iskelet ekranı. Home/Study/Quiz/Stats/Settings ekranları
/// sonraki milestone'larda screens/ altına eklenecek.
class _SkeletonHome extends StatelessWidget {
  const _SkeletonHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savant')),
      body: const Center(child: Text('Proje iskeleti hazır 🎉')),
    );
  }
}
