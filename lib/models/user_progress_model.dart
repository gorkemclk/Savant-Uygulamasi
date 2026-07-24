class UserProgressModel {
  const UserProgressModel({
    required this.cardId,
    this.repetitionCount = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    required this.nextReviewDate,
    this.lastReviewedDate,
    this.status = 'new',
  });

  final String cardId;
  final int repetitionCount;
  final double easeFactor;
  final int intervalDays;
  final String nextReviewDate;
  final String? lastReviewedDate;
  final String status;
///veri tabanından okuma yapılan yer, sqlite satırı dart nesnesine çeviriliyor
  factory UserProgressModel.fromMap(Map<String, dynamic> map) {
    return UserProgressModel(
      cardId: map['card_id'] as String,
      repetitionCount: map['repetition_count'] as int,
      easeFactor: (map['ease_factor'] as num).toDouble(),
      intervalDays: map['interval_days'] as int,
      nextReviewDate: map['next_review_date'] as String,
      lastReviewedDate: map['last_reviewed_date'] as String?,
      status: map['status'] as String,
    );
  }
///veritabanına yazılan yer
  Map<String, dynamic> toMap() {
    return {
      'card_id': cardId,
      'repetition_count': repetitionCount,
      'ease_factor': easeFactor,
      'interval_days': intervalDays,
      'next_review_date': nextReviewDate,
      'last_reviewed_date': lastReviewedDate,
      'status': status,
    };
  }
///kopyala ve değiştir
  UserProgressModel copyWith({
    int? repetitionCount,
    double? easeFactor,
    int? intervalDays,
    String? nextReviewDate,
    String? lastReviewedDate,
    String? status,
  }) {
    return UserProgressModel(
      cardId: cardId,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewedDate: lastReviewedDate ?? this.lastReviewedDate,
      status: status ?? this.status,
    );
  }
}
