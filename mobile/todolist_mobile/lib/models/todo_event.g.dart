// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoEvent _$TodoEventFromJson(Map<String, dynamic> json) => TodoEvent(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      userId: (json['user_id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      isCompleted: json['is_completed'] as bool? ?? false,
      priority: $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']) ??
          TaskPriority.medium,
      tasks: (json['tasks'] as List<dynamic>?)
          ?.map((e) => TodoTask.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TodoEventToJson(TodoEvent instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'user_id': instance.userId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'due_date': instance.dueDate?.toIso8601String(),
      'is_completed': instance.isCompleted,
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'tasks': instance.tasks,
    };

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
};

TodoTask _$TodoTaskFromJson(Map<String, dynamic> json) => TodoTask(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      eventId: (json['event_id'] as num).toInt(),
      parentTaskId: (json['parent_task_id'] as num?)?.toInt(),
      userId: (json['user_id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      status: $enumDecodeNullable(_$TaskStatusEnumMap, json['status']) ??
          TaskStatus.pending,
      priority: $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']) ??
          TaskPriority.medium,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      subTasks: (json['subTasks'] as List<dynamic>?)
          ?.map((e) => TodoTask.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TodoTaskToJson(TodoTask instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'event_id': instance.eventId,
      'parent_task_id': instance.parentTaskId,
      'user_id': instance.userId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'due_date': instance.dueDate?.toIso8601String(),
      'status': _$TaskStatusEnumMap[instance.status]!,
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'sort_order': instance.sortOrder,
      'subTasks': instance.subTasks,
    };

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.completed: 'completed',
  TaskStatus.cancelled: 'cancelled',
};
