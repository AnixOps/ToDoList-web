import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import '../utils/constants.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的任务'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 搜索功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: 更多选项
            },
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          if (todoProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (todoProvider.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '暂无任务',
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '点击右下角按钮创建您的第一个任务',
                    style: AppTextStyles.callout.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: todoProvider.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: todoProvider.events.length,
              itemBuilder: (context, index) {
                final event = todoProvider.events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ListTile(
                    title: Text(event.title),
                    subtitle: Text(event.description),
                    trailing: Icon(
                      event.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: event.isCompleted
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    onTap: () {
                      // TODO: 查看事件详情
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 创建新任务
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}