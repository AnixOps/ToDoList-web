// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TodoList';

  @override
  String get todoList => 'Todo List';

  @override
  String get addTask => 'Add Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get taskDescription => 'Task Description';

  @override
  String get dueDate => 'Due Date';

  @override
  String get priority => 'Priority';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get overdue => 'Overdue';

  @override
  String get noTasks => 'No tasks';

  @override
  String get loadFailed => 'Load failed';

  @override
  String get retry => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteMessage(String taskTitle) {
    return 'Are you sure you want to delete \"$taskTitle\"?';
  }

  @override
  String get taskCreatedSuccess => 'Task created successfully';

  @override
  String get taskUpdatedSuccess => 'Task updated successfully';

  @override
  String get taskDeletedSuccess => 'Task deleted successfully';

  @override
  String get createFailed => 'Create failed';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysLater(int count) {
    return '$count days later';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get selectDate => 'Select Date';

  @override
  String get onlineMode => 'Online Mode';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get switchMode => 'Switch Mode';

  @override
  String get switchToOnlineMode =>
      'Currently in offline mode, switch to online mode?';

  @override
  String get switchToOfflineMode =>
      'Currently in online mode, switch to offline mode?';

  @override
  String get switchButton => 'Switch';

  @override
  String get loading => 'Loading...';

  @override
  String get addSubTask => 'Add Subtask';

  @override
  String get subTasks => 'Subtasks';

  @override
  String subTasksCount(int completed, int total) {
    return '$completed/$total subtasks completed';
  }

  @override
  String get pleaseEnterTaskTitle => 'Please enter task title';

  @override
  String get taskTitleHint => 'Enter task title';

  @override
  String get taskDescriptionHint => 'Enter task description (optional)';

  @override
  String viewDetails(String taskTitle) {
    return 'View Details: $taskTitle';
  }

  @override
  String get operationFailed => 'Operation failed';

  @override
  String get profile => 'Profile';

  @override
  String get tasks => 'Tasks';
}
