import 'package:uuid/uuid.dart';

class GoalModel {
  final String id;
  final String title;
  final String? description;
  final int targetBricks; // total bricks needed (e.g., 50, 100)
  final int colorValue;   // Color int for brick styling
  final DateTime createdAt;

  GoalModel({
    String? id,
    required this.title,
    this.description,
    this.targetBricks = 100,
    this.colorValue = 0xFFD84315, // Brick terracotta default
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    int? targetBricks,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetBricks: targetBricks ?? this.targetBricks,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetBricks': targetBricks,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return GoalModel(
      id: docId ?? map['id'] ?? const Uuid().v4(),
      title: map['title'] ?? '',
      description: map['description'],
      targetBricks: map['targetBricks'] ?? 100,
      colorValue: map['colorValue'] ?? 0xFFD84315,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

