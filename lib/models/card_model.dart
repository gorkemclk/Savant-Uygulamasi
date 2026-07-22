import 'dart:convert';

/// `cards` tablosundaki (seed edilen, salt okunur) bir kartı temsil eder.
class CardModel {
  const CardModel({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
  });

  final String id;
  final String category;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String difficulty;

  /// `assets/cards.json` içindeki ham kayıttan oluşturur.
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as String,
      category: json['category'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correct_index'] as int,
      explanation: json['explanation'] as String,
      difficulty: json['difficulty'] as String,
    );
  }

  /// sqflite'tan okunan bir satırdan oluşturur (`options` DB'de JSON string olarak tutulur).
  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] as String,
      category: map['category'] as String,
      question: map['question'] as String,
      options: List<String>.from(jsonDecode(map['options'] as String) as List),
      correctIndex: map['correct_index'] as int,
      explanation: map['explanation'] as String,
      difficulty: map['difficulty'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'options': jsonEncode(options),
      'correct_index': correctIndex,
      'explanation': explanation,
      'difficulty': difficulty,
    };
  }
}
