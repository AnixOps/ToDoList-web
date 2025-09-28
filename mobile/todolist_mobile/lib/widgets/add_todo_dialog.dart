import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../l10n/generated/app_localizations.dart';

class AddTodoDialog extends StatefulWidget {
  const AddTodoDialog({super.key});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.addTask),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题输入框
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.taskTitle,
                  hintText: l10n.taskTitleHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterTaskTitle;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: AppSpacing.md),

              // 描述输入框
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.taskDescription,
                  hintText: l10n.taskDescriptionHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),

              const SizedBox(height: AppSpacing.md),

              // 截止日期选择
              Row(
                children: [
                  const Icon(Icons.schedule, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(l10n.dueDate),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: InkWell(
                      onTap: _selectDueDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _dueDate != null
                              ? _formatDate(_dueDate!)
                              : '                              : l10n.selectDate,',
                          style: TextStyle(
                            color: _dueDate != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _dueDate = null;
                        });
                      },
                      icon: const Icon(Icons.clear, size: 20),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // 优先级选择
              Row(
                children: [
                  const Icon(Icons.flag, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(l10n.priority),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SegmentedButton<TaskPriority>(
                      segments: [
                        ButtonSegment(
                          value: TaskPriority.low,
                          label: Text(l10n.low),
                          icon: const Icon(Icons.flag, color: Colors.green),
                        ),
                        ButtonSegment(
                          value: TaskPriority.medium,
                          label: Text(l10n.medium),
                          icon: const Icon(Icons.flag, color: Colors.orange),
                        ),
                        ButtonSegment(
                          value: TaskPriority.high,
                          label: Text(l10n.high),
                          icon: const Icon(Icons.flag, color: Colors.red),
                        ),
                      ],
                      selected: {_priority},
                      onSelectionChanged: (Set<TaskPriority> selection) {
                        setState(() {
                          _priority = selection.first;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveTodo,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      } else {
        setState(() {
          _dueDate = date;
        });
      }
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final todoProvider = context.read<TodoProvider>();
      final authProvider = context.read<AuthProvider>();

      if (authProvider.user == null) {
        throw Exception('用户未登录');
      }

      final success = await todoProvider.createEvent(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        userId: authProvider.user!.id,
        dueDate: _dueDate,
        priority: _priority,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('任务创建成功'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(todoProvider.error ?? '创建失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建失败: ${e.toString()}'),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == today.add(const Duration(days: 1))) {
      return '明天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
