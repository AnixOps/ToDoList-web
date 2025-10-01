import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import '../providers/auth_provider.dart';
import '../models/todo_event.dart';
import '../widgets/todo_item_widget.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/edit_todo_dialog.dart';
import '../widgets/loading_widget.dart';
import '../utils/constants.dart';
import '../l10n/generated/app_localizations.dart';
import 'task_detail_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 初始化加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final todoProvider = context.read<TodoProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isLoggedIn) {
      await todoProvider.loadEvents(userId: authProvider.user?.id);
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todoList),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: l10n.pending),
            Tab(text: l10n.completed),
            Tab(text: l10n.overdue),
          ],
        ),
        actions: [
          Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              return IconButton(
                icon: todoProvider.isOfflineMode
                    ? const Icon(Icons.cloud_off)
                    : const Icon(Icons.cloud),
                onPressed: () {
                  _showModeDialog();
                },
                tooltip: todoProvider.isOfflineMode ? '离线模式' : '在线模式',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          if (todoProvider.isLoading && todoProvider.events.isEmpty) {
            return LoadingWidget(message: l10n.loading);
          }

          if (todoProvider.error != null) {
            return _buildErrorWidget(todoProvider.error!);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTodoList(todoProvider.pendingEvents),
              _buildTodoList(todoProvider.completedEvents),
              _buildTodoList(todoProvider.overdueEvents),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodoList(List<TodoEvent> events) {
    final l10n = AppLocalizations.of(context)!;

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              l10n.noTasks,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: TodoItemWidget(
              event: event,
              onTap: () => _showEventDetails(event),
              onToggleComplete: () => _toggleEventComplete(event),
              onEdit: () => _showEditDialog(event),
              onDelete: () => _showDeleteDialog(event),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.loadFailed,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(TodoEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(event: event),
      ),
    );
  }

  Future<void> _toggleEventComplete(TodoEvent event) async {
    final todoProvider = context.read<TodoProvider>();
    final success = await todoProvider.updateEvent(
      eventId: event.id,
      isCompleted: !event.isCompleted,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(todoProvider.error ?? '操作失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditDialog(TodoEvent event) {
    showDialog(
      context: context,
      builder: (context) => EditTodoDialog(event: event),
    );
  }

  void _showDeleteDialog(TodoEvent event) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteMessage(event.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteEvent(event);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(TodoEvent event) async {
    final todoProvider = context.read<TodoProvider>();
    final success = await todoProvider.deleteEvent(event.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '删除成功' : (todoProvider.error ?? '删除失败')),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showModeDialog() {
    final l10n = AppLocalizations.of(context)!;
    final todoProvider = context.read<TodoProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.switchMode),
        content: Text(todoProvider.isOfflineMode
            ? l10n.switchToOnlineMode
            : l10n.switchToOfflineMode),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              todoProvider.switchMode(offline: !todoProvider.isOfflineMode);
            },
            child: Text(l10n.switchButton),
          ),
        ],
      ),
    );
  }
}
