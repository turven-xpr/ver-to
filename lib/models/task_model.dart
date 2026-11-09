import 'package:uuid/uuid.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final String? linkedGoalId;
  final String priority; // 'low', 'medium', 'high'
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;

  TaskModel({
    String? id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.linkedGoalId,
    this.priority = 'medium',
    this.dueDate,
    DateTime? createdAt,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? linkedGoalId,
    bool clearLinkedGoal = false,
    String? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      linkedGoalId: clearLinkedGoal ? null : (linkedGoalId ?? this.linkedGoalId),
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'linkedGoalId': linkedGoalId,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return TaskModel(
      id: docId ?? map['id'] ?? const Uuid().v4(),
      title: map['title'] ?? '',
      description: map['description'],
      isCompleted: map['isCompleted'] ?? false,
      linkedGoalId: map['linkedGoalId'],
      priority: map['priority'] ?? 'medium',
      dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate']) : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'])
          : null,
    );
  }
}
