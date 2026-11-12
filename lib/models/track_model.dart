import 'package:uuid/uuid.dart';

class TrackItemModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int colorValue;
  final DateTime createdAt;

  TrackItemModel({
    String? id,
    required this.title,
    this.description = '',
    this.icon = '📋',
    this.colorValue = 0xFFD84315,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  TrackItemModel copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return TrackItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TrackItemModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return TrackItemModel(
      id: docId ?? map['id'] ?? const Uuid().v4(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '📋',
      colorValue: map['colorValue'] is int ? map['colorValue'] : 0xFFD84315,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class TrackEntryModel {
  final String id;
  final String trackItemId;
  final String title;
  final String content;
  final DateTime timestamp;
  final String? tag;
  final int? rating; // 1-5 optional rating

  TrackEntryModel({
    String? id,
    required this.trackItemId,
    required this.title,
    required this.content,
    DateTime? timestamp,
    this.tag,
    this.rating,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  TrackEntryModel copyWith({
    String? id,
    String? trackItemId,
    String? title,
    String? content,
    DateTime? timestamp,
    String? tag,
    int? rating,
  }) {
    return TrackEntryModel(
      id: id ?? this.id,
      trackItemId: trackItemId ?? this.trackItemId,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      tag: tag ?? this.tag,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackItemId': trackItemId,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'tag': tag,
      'rating': rating,
    };
  }

  factory TrackEntryModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return TrackEntryModel(
      id: docId ?? map['id'] ?? const Uuid().v4(),
      trackItemId: map['trackItemId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      tag: map['tag'],
      rating: map['rating'] is int ? map['rating'] : null,
    );
  }
}

