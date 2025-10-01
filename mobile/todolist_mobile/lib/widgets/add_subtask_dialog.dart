import 'package:flutter/material.dart';
import '../models/todo_event.dart';
import '../utils/constants.dart';

class AddSubtaskDialog extends StatefulWidget {
  final TodoEvent parentEvent;
  final Function(TodoTask) onAddSubtask;

  const AddSubtaskDialog({
    super.key,
    required this.parentEvent,
    required this.onAddSubtask,
  });

  @override
  State<AddSubtaskDialog> createState() => _AddSubtaskDialogState();
}

class _AddSubtaskDialogState extends State<AddSubtaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Text(
                  '添加子任务',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            // 父任务信息
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '添加到: ${widget.parentEvent.title}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 表单
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 任务标题
                  Text(
                    '任务标题 *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: '输入任务标题',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入任务标题';
                      }
                      return null;
                    },
                    autofocus: true,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 任务描述
                  Text(
                    '任务描述',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: '输入任务描述（可选）',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 优先级选择
                  Text(
                    '优先级',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: TaskPriority.values.map((priority) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: priority != TaskPriority.values.last
                                ? AppSpacing.sm
                                : 0,
                          ),
                          child: _buildPriorityOption(priority),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 截止日期
                  Text(
                    '截止日期',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    onTap: () => _selectDueDate(context),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _selectedDueDate == null
                                ? '选择截止日期（可选）'
                                : _formatDate(_selectedDueDate!),
                            style: TextStyle(
                              color: _selectedDueDate == null
                                  ? Colors.grey[600]
                                  : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          if (_selectedDueDate != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDueDate = null;
                                });
                              },
                              child: Icon(
                                Icons.clear,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addSubtask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: const Text('添加'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityOption(TaskPriority priority) {
    final isSelected = _selectedPriority == priority;

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

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('zh', 'CN'),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return '今天 (${date.month}/${date.day})';
    } else if (difference == 1) {
      return '明天 (${date.month}/${date.day})';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }

  void _addSubtask() {
    if (_formKey.currentState!.validate()) {
      final newTask = TodoTask(
        id: DateTime.now().millisecondsSinceEpoch,
        eventId: widget.parentEvent.id,
        userId: widget.parentEvent.userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        parentTaskId: widget.parentEvent.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onAddSubtask(newTask);
      Navigator.of(context).pop();
    }
  }
}
