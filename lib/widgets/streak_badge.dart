import 'package:flutter/material.dart';

/// Şu an sabit bir değer gösterir; gerçek streak hesaplaması Gün 7'de
/// `AppState` üzerinden bağlanacak.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.streakCount});

  final int streakCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, size: 40, color: Colors.orange),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$streakCount gün', style: Theme.of(context).textTheme.headlineMedium),
                const Text('Streak'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
