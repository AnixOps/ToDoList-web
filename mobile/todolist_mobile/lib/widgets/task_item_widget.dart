import 'package:flutter/material.dart';
import '../models/todo_event.dart';
import '../utils/constants.dart';

class TaskItemWidget extends StatelessWidget {
  final TodoTask task;
  final bool isParentTask;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onAddSubTask;

  const TaskItemWidget({
    super.key,
    required this.task,
    this.isParentTask = false,
    this.onTap,
    this.onToggleComplete,
    this.onAddSubTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: isParentTask ? AppSpacing.md : AppSpacing.xl,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: isParentTask
              ? BorderSide.none
              : BorderSide(
                  color: Colors.grey[300]!,
                  width: 2,
                ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              // 完成状态按钮
              GestureDetector(
                onTap: onToggleComplete,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted ? AppColors.primary : Colors.grey,
                      width: 2,
                    ),
                    color: task.isCompleted
                        ? AppColors.primary
                        : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // 任务内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: isParentTask ? 16 : 14,
                        fontWeight:
                            isParentTask ? FontWeight.w600 : FontWeight.w500,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              task.isCompleted ? Colors.grey : Colors.grey[600],
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // 任务信息行
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // 优先级标识
                        _buildPriorityChip(task.priority),
                        const SizedBox(width: AppSpacing.sm),

                        // 截止日期
                        if (task.dueDate != null) ...[
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color:
                                task.isOverdue ? Colors.red : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(task.dueDate!),
                            style: TextStyle(
                              fontSize: 10,
                              color: task.isOverdue
                                  ? Colors.red
                                  : Colors.grey[600],
                            ),
                          ),
                        ],

                        const Spacer(),

                        // 过期标识
                        if (task.isOverdue && !task.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '已过期',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // 操作按钮
              if (isParentTask && onAddSubTask != null)
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: onAddSubTask,
                  tooltip: '添加子任务',
                ),

              const Icon(
                Icons.more_vert,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
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
}
