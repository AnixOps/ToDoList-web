import 'package:flutter/foundation.dart';

@immutable
class Todo {
  final String id; // Typically a UUID or a server-generated ID
  final String title;
  final String? description;
  final bool isCompleted;
  final String? userId; // To associate todo with a user
  final DateTime? createdAt; // ISO 8601 string format for db
  final DateTime? updatedAt; // ISO 8601 string format for db
  final bool isSynced; // To track if the item is synced with the server

  const Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.isSynced = true, // Default to true if coming from server, false if created offline
  });

  // Convert a Todo object into a Map object for sqflite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0, // sqflite doesn't support boolean directly
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // Extract a Todo object from a Map object
  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: (map['isCompleted'] as int) == 1,
      userId: map['userId'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'] as String) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'] as String) : null,
      isSynced: map['isSynced'] != null ? (map['isSynced'] as int) == 1 : true,
    );
  }

  // Helper for creating a copy with modified fields
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  String toString() {
    return 'Todo{id: $id, title: $title, isCompleted: $isCompleted, userId: $userId, synced: $isSynced}';
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Todo &&
        runtimeType == other.runtimeType &&
        id == other.id &&
        title == other.title &&
        description == other.description &&
        isCompleted == other.isCompleted &&
        userId == other.userId &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        isSynced == other.isSynced;

  @override
  int get hashCode =>
    id.hashCode ^
    title.hashCode ^
    description.hashCode ^
    isCompleted.hashCode ^
    userId.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode ^
    isSynced.hashCode;
}
