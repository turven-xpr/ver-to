import 'package:uuid/uuid.dart';

class NoteModel {
  final String id;
  final String periodType; // 'day', 'week', 'month', or 'goal'
  final DateTime date;
  final String title;
  final String content;
  final String? linkedGoalId;
  final DateTime createdAt;

  NoteModel({
    String? id,
    required this.periodType,
    required this.date,
    required this.title,
    required this.content,
    this.linkedGoalId,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  NoteModel copyWith({
    String? id,
    String? periodType,
    DateTime? date,
    String? title,
    String? content,
    String? linkedGoalId,
    DateTime? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      periodType: periodType ?? this.periodType,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      linkedGoalId: linkedGoalId ?? this.linkedGoalId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'periodType': periodType,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
      'linkedGoalId': linkedGoalId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return NoteModel(
      id: docId ?? map['id'] ?? const Uuid().v4(),
      periodType: map['periodType'] ?? 'day',
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      linkedGoalId: map['linkedGoalId'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

