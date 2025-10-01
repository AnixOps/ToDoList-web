import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'TodoList'**
  String get appTitle;

  /// Title for todo list screen
  ///
  /// In en, this message translates to:
  /// **'Todo List'**
  String get todoList;

  /// Button text to add a new task
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// Title for editing a task
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// Label for task title input
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// Label for task description input
  ///
  /// In en, this message translates to:
  /// **'Task Description'**
  String get taskDescription;

  /// Label for due date
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// Label for priority selection
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// High priority label
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// Medium priority label
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Low priority label
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// Pending tasks tab
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Completed tasks tab
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Overdue tasks tab
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// Message when there are no tasks
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get noTasks;

  /// Error message when loading fails
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get loadFailed;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Title for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// Message for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{taskTitle}\"?'**
  String confirmDeleteMessage(String taskTitle);

  /// Success message when task is created
  ///
  /// In en, this message translates to:
  /// **'Task created successfully'**
  String get taskCreatedSuccess;

  /// Success message when task is updated
  ///
  /// In en, this message translates to:
  /// **'Task updated successfully'**
  String get taskUpdatedSuccess;

  /// Success message when task is deleted
  ///
  /// In en, this message translates to:
  /// **'Task deleted successfully'**
  String get taskDeletedSuccess;

  /// Error message when creation fails
  ///
  /// In en, this message translates to:
  /// **'Create failed'**
  String get createFailed;

  /// Error message when update fails
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// Error message when deletion fails
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFailed;

  /// Today label for dates
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Tomorrow label for dates
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Yesterday label for dates
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Days later label
  ///
  /// In en, this message translates to:
  /// **'{count} days later'**
  String daysLater(int count);

  /// Days ago label
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// Placeholder for date selection
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Online mode tooltip
  ///
  /// In en, this message translates to:
  /// **'Online Mode'**
  String get onlineMode;

  /// Offline mode tooltip
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// Title for mode switch dialog
  ///
  /// In en, this message translates to:
  /// **'Switch Mode'**
  String get switchMode;

  /// Message for switching to online mode
  ///
  /// In en, this message translates to:
  /// **'Currently in offline mode, switch to online mode?'**
  String get switchToOnlineMode;

  /// Message for switching to offline mode
  ///
  /// In en, this message translates to:
  /// **'Currently in online mode, switch to offline mode?'**
  String get switchToOfflineMode;

  /// Switch button text
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchButton;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Button text to add a subtask
  ///
  /// In en, this message translates to:
  /// **'Add Subtask'**
  String get addSubTask;

  /// Label for subtasks section
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get subTasks;

  /// Subtasks completion count
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} subtasks completed'**
  String subTasksCount(int completed, int total);

  /// Validation message for empty task title
  ///
  /// In en, this message translates to:
  /// **'Please enter task title'**
  String get pleaseEnterTaskTitle;

  /// Hint text for task title input
  ///
  /// In en, this message translates to:
  /// **'Enter task title'**
  String get taskTitleHint;

  /// Hint text for task description input
  ///
  /// In en, this message translates to:
  /// **'Enter task description (optional)'**
  String get taskDescriptionHint;

  /// Message for viewing task details
  ///
  /// In en, this message translates to:
  /// **'View Details: {taskTitle}'**
  String viewDetails(String taskTitle);

  /// Generic operation failed message
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get operationFailed;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Tasks tab label
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// Button text to mark task as complete
  ///
  /// In en, this message translates to:
  /// **'Mark as complete'**
  String get markComplete;

  /// Button text to mark task as incomplete
  ///
  /// In en, this message translates to:
  /// **'Mark as incomplete'**
  String get markIncomplete;

  /// Progress label for tasks
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Text to add first task when list is empty
  ///
  /// In en, this message translates to:
  /// **'Add first task'**
  String get addFirstTask;

  /// Button text to add subtask
  ///
  /// In en, this message translates to:
  /// **'Add Subtask'**
  String get addSubtask;

  /// Title for task details screen
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetails;

  /// Text when there are no subtasks
  ///
  /// In en, this message translates to:
  /// **'No subtasks'**
  String get noSubTasks;

  /// Text showing which parent task subtask will be added to
  ///
  /// In en, this message translates to:
  /// **'Add to: {parentTitle}'**
  String addSubTaskTo(String parentTitle);

  /// Hint text for due date selection
  ///
  /// In en, this message translates to:
  /// **'Select due date (optional)'**
  String get selectDueDate;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
