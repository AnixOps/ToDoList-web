import 'package:json_annotation/json_annotation.dart';
import '../utils/constants.dart';

part 'todo_event.g.dart';

@JsonSerializable()
class TodoEvent {
  final int id;
  final String title;
  final String description;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  final TaskPriority priority;

  // 关联的任务列表
  final List<TodoTask>? tasks;

  const TodoEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.tasks,
  });

  factory TodoEvent.fromJson(Map<String, dynamic> json) =>
      _$TodoEventFromJson(json);
  Map<String, dynamic> toJson() => _$TodoEventToJson(this);

  TodoEvent copyWith({
    int? id,
    String? title,
    String? description,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    bool? isCompleted,
    TaskPriority? priority,
    List<TodoTask>? tasks,
  }) {
    return TodoEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      tasks: tasks ?? this.tasks,
    );
  }

  // 获取任务完成进度
  double get progress {
    if (tasks == null || tasks!.isEmpty) return 0.0;

    final completedTasks =
        tasks!.where((task) => task.status == TaskStatus.completed).length;
    return completedTasks / tasks!.length;
  }

  // 获取待完成任务数量
  int get pendingTasksCount {
    if (tasks == null) return 0;
    return tasks!.where((task) => task.status == TaskStatus.pending).length;
  }

  // 获取已完成任务数量
  int get completedTasksCount {
    if (tasks == null) return 0;
    return tasks!.where((task) => task.status == TaskStatus.completed).length;
  }

  // 检查是否过期
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TodoEvent(id: $id, title: $title, isCompleted: $isCompleted)';
  }
}

@JsonSerializable()
class TodoTask {
  final int id;
  final String title;
  final String description;
  @JsonKey(name: 'event_id')
  final int eventId;
  @JsonKey(name: 'parent_task_id')
  final int? parentTaskId;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  final TaskStatus status;
  final TaskPriority priority;
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  // 子任务列表
  final List<TodoTask>? subTasks;

  const TodoTask({
    required this.id,
    required this.title,
    required this.description,
    required this.eventId,
    this.parentTaskId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    this.sortOrder = 0,
    this.subTasks,
  });

  factory TodoTask.fromJson(Map<String, dynamic> json) =>
      _$TodoTaskFromJson(json);
  Map<String, dynamic> toJson() => _$TodoTaskToJson(this);

  TodoTask copyWith({
    int? id,
    String? title,
    String? description,
    int? eventId,
    int? parentTaskId,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    TaskStatus? status,
    TaskPriority? priority,
    int? sortOrder,
    List<TodoTask>? subTasks,
  }) {
    return TodoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventId: eventId ?? this.eventId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      sortOrder: sortOrder ?? this.sortOrder,
      subTasks: subTasks ?? this.subTasks,
    );
  }

  // 检查是否过期
  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // 检查是否已完成
  bool get isCompleted => status == TaskStatus.completed;

  // 检查是否已取消
  bool get isCancelled => status == TaskStatus.cancelled;

  // 检查是否是主任务（没有父任务）
  bool get isMainTask => parentTaskId == null;

  // 检查是否是子任务
  bool get isSubTask => parentTaskId != null;

  // 获取子任务完成进度
  double get subTaskProgress {
    if (subTasks == null || subTasks!.isEmpty) return 0.0;

    final completedSubTasks =
        subTasks!.where((task) => task.isCompleted).length;
    return completedSubTasks / subTasks!.length;
  }

  // 获取待完成子任务数量
  int get pendingSubTasksCount {
    if (subTasks == null) return 0;
    return subTasks!.where((task) => !task.isCompleted).length;
  }

  // 获取已完成子任务数量
  int get completedSubTasksCount {
    if (subTasks == null) return 0;
    return subTasks!.where((task) => task.isCompleted).length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoTask && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TodoTask(id: $id, title: $title, status: $status)';
  }
}
