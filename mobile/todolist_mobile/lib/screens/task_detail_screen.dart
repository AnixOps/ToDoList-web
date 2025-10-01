import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/todo_event.dart';
import '../providers/todo_provider.dart';
import '../utils/constants.dart';
import '../widgets/task_item_widget.dart';
import '../widgets/add_subtask_dialog.dart';
import '../widgets/edit_task_dialog.dart';

class TaskDetailScreen extends StatefulWidget {
  final TodoEvent event;

  const TaskDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        actions: [
          IconButton(
            icon: Icon(
              widget.event.isCompleted
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
            ),
            onPressed: _toggleEventCompletion,
            tooltip: widget.event.isCompleted
                ? l10n.markIncomplete
                : l10n.markComplete,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showEventOptions(),
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          // 查找当前事件的所有任务
          final event = provider.events.firstWhere(
            (e) => e.id == widget.event.id,
            orElse: () => widget.event,
          );

          final tasks = event.tasks ?? [];

          // 将任务按父子关系分组
          final taskGroups = _groupTasksByParent(tasks);

          return CustomScrollView(
            slivers: [
              // 事件信息卡片
              SliverToBoxAdapter(
                child: _buildEventInfoCard(event, l10n),
              ),

              // 任务进度
              if (tasks.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildProgressCard(tasks, l10n),
                ),

              // 任务列表
              if (tasks.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.noTasks,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton.icon(
                          onPressed: _addNewTask,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addFirstTask),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.md,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final parentTask = taskGroups.keys.elementAt(index);
                      final subTasks = taskGroups[parentTask] ?? [];

                      return _buildTaskGroup(
                        parentTask,
                        subTasks,
                        l10n,
                      );
                    },
                    childCount: taskGroups.length,
                  ),
                ),

              // 底部间距
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEventInfoCard(TodoEvent event, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 描述
          if (event.description.isNotEmpty) ...[
            Text(
              event.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // 元信息
          Row(
            children: [
              // 优先级
              _buildPriorityChip(event.priority),
              const SizedBox(width: AppSpacing.md),

              // 截止日期
              if (event.dueDate != null) ...[
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: event.isOverdue ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(event.dueDate!),
                  style: TextStyle(
                    fontSize: 12,
                    color: event.isOverdue ? Colors.red : Colors.grey[600],
                  ),
                ),
              ],

              const Spacer(),

              // 状态标识
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: event.isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: event.isCompleted
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  event.isCompleted ? l10n.completed : l10n.pending,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: event.isCompleted ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(List<TodoTask> tasks, AppLocalizations l10n) {
    final completedCount =
        tasks.where((t) => t.status == TaskStatus.completed).length;
    final totalCount = tasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.progress,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completedCount / $totalCount',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskGroup(
    TodoTask? parentTask,
    List<TodoTask> subTasks,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 父任务（如果有）
          if (parentTask != null)
            TaskItemWidget(
              task: parentTask,
              isParentTask: true,
              onTap: () => _showTaskOptions(parentTask),
              onToggleComplete: () => _toggleTaskCompletion(parentTask),
              onAddSubTask: () => _addSubTask(parentTask),
            ),

          // 子任务
          if (subTasks.isNotEmpty)
            ...subTasks.map((subTask) => TaskItemWidget(
                  task: subTask,
                  isParentTask: false,
                  onTap: () => _showTaskOptions(subTask),
                  onToggleComplete: () => _toggleTaskCompletion(subTask),
                )),
        ],
      ),
    );
  }

  Map<TodoTask?, List<TodoTask>> _groupTasksByParent(List<TodoTask> tasks) {
    final Map<TodoTask?, List<TodoTask>> groups = {};

    // 首先找出所有顶级任务（没有父任务的）
    final topLevelTasks = tasks.where((t) => t.parentTaskId == null).toList();

    for (final topTask in topLevelTasks) {
      // 找出该顶级任务的所有子任务
      final subTasks =
          tasks.where((t) => t.parentTaskId == topTask.id).toList();
      groups[topTask] = subTasks;
    }

    // 如果有孤儿子任务（父任务不存在），也加入分组
    final orphanSubTasks = tasks.where((t) {
      if (t.parentTaskId == null) return false;
      return !tasks.any((parent) => parent.id == t.parentTaskId);
    }).toList();

    if (orphanSubTasks.isNotEmpty) {
      groups[null] = orphanSubTasks;
    }

    return groups;
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    String text;

    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        text = '高';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        text = '中';
        break;
      case TaskPriority.low:
        color = Colors.green;
        text = '低';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '明天';
    } else if (difference == -1) {
      return '昨天';
    } else if (difference > 0) {
      return '${difference}天后';
    } else {
      return '${-difference}天前';
    }
  }

  void _addNewTask() async {
    await showDialog(
      context: context,
      builder: (context) => AddSubtaskDialog(
        parentEvent: widget.event,
        onAddSubtask: (task) async {
          await context.read<TodoProvider>().createTask(widget.event.id, task);
        },
      ),
    );
  }

  void _addSubTask(TodoTask parentTask) async {
    await showDialog(
      context: context,
      builder: (context) => AddSubtaskDialog(
        parentEvent: widget.event,
        onAddSubtask: (task) async {
          // 创建子任务，设置parentTaskId
          final subTask = task.copyWith(parentTaskId: parentTask.id);
          await context
              .read<TodoProvider>()
              .createTask(widget.event.id, subTask);
        },
      ),
    );
  }

  void _showTaskOptions(TodoTask task) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                task.status == TaskStatus.completed
                    ? Icons.remove_done
                    : Icons.done,
              ),
              title: Text(
                task.status == TaskStatus.completed
                    ? l10n.markIncomplete
                    : l10n.markComplete,
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleTaskCompletion(task);
              },
            ),
            if (task.parentTaskId == null)
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(l10n.addSubtask),
                onTap: () {
                  Navigator.pop(context);
                  _addSubTask(task);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.edit),
              onTap: () {
                Navigator.pop(context);
                _editTask(task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteTask(task);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleTaskCompletion(TodoTask task) async {
    final newStatus = task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;

    await context.read<TodoProvider>().updateTask(
          task.copyWith(status: newStatus),
        );
  }

  Future<void> _toggleEventCompletion() async {
    await context.read<TodoProvider>().updateEvent(
          eventId: widget.event.id,
          isCompleted: !widget.event.isCompleted,
        );
  }

  Future<void> _editTask(TodoTask task) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditTaskDialog(task: task),
    );

    if (result == true && mounted) {
      // 任务更新成功后刷新数据
      await context.read<TodoProvider>().loadTasks(widget.event.id);
    }
  }

  Future<void> _deleteTask(TodoTask task) async {
    await context.read<TodoProvider>().deleteTask(task.id);
  }

  void _showEventOptions() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.edit),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现编辑事件
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteEvent();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEvent() async {
    await context.read<TodoProvider>().deleteEvent(widget.event.id);
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
