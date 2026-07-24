class StreakModel {
  const StreakModel({
    required this.date,
    this.cardsCompleted = 0,
    this.streakCount = 0,
  });

  final String date;
  final int cardsCompleted;
  final int streakCount;

  factory StreakModel.fromMap(Map<String, dynamic> map) {
    return StreakModel(
      date: map['date'] as String,
      cardsCompleted: map['cards_completed'] as int,
      streakCount: map['streak_count'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'cards_completed': cardsCompleted,
      'streak_count': streakCount,
    };
  }
}
