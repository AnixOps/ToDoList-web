import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_event.dart';
import '../providers/todo_provider.dart';
import '../utils/constants.dart';
import '../l10n/generated/app_localizations.dart';

class EditTaskDialog extends StatefulWidget {
  final TodoTask task;

  const EditTaskDialog({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _selectedPriority = widget.task.priority;
    _selectedDueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题栏
              Row(
                children: [
                  Text(
                    l10n.editTask,
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

              const SizedBox(height: AppSpacing.lg),

              // 表单
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 任务标题
                    Text(
                      '${l10n.taskTitle} *',
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
                        hintText: l10n.taskTitleHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.pleaseEnterTaskTitle;
                        }
                        return null;
                      },
                      autofocus: true,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 任务描述
                    Text(
                      l10n.taskDescription,
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
                        hintText: l10n.taskDescriptionHint,
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
                      l10n.priority,
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
                      l10n.dueDate,
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
                                  ? l10n.selectDueDate
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
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        child: Text(l10n.save),
                      ),
                    ),
                  ],
                ),
            ],
          ),
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

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        updatedAt: DateTime.now(),
      );

      final success =
          await context.read<TodoProvider>().updateTask(updatedTask);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.taskUpdatedSuccess),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final error = context.read<TodoProvider>().error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(error ?? AppLocalizations.of(context)!.updateFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
