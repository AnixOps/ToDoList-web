import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../utils/constants.dart';
import '../l10n/generated/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserStats();
    });
  }

  Future<void> _loadUserStats() async {
    final todoProvider = context.read<TodoProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isLoggedIn) {
      await todoProvider.loadEvents(userId: authProvider.user?.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final todoProvider = context.watch<TodoProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 用户信息头部
          _buildUserHeader(authProvider, l10n),

          // 统计数据卡片
          SliverToBoxAdapter(
            child: _buildStatsCards(todoProvider, l10n),
          ),

          // 功能列表
          SliverToBoxAdapter(
            child:
                _buildFunctionList(context, authProvider, todoProvider, l10n),
          ),

          // 底部间距
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(AuthProvider authProvider, AppLocalizations l10n) {
    final user = authProvider.user;
    final todoProvider = context.watch<TodoProvider>();
    final isOffline = todoProvider.isOfflineMode;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: isOffline ? Colors.grey[700] : AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isOffline
                  ? [
                      Colors.grey[700]!,
                      Colors.grey[600]!,
                    ]
                  : [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // 头像
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: isOffline
                      ? const Icon(
                          Icons.cloud_off,
                          size: 40,
                          color: Colors.grey,
                        )
                      : Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                // 用户名
                Text(
                  isOffline ? '离线模式' : (user?.name ?? l10n.profile),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // 邮箱或提示
                Text(
                  isOffline ? '数据仅保存在本地设备' : (user?.email ?? ''),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(TodoProvider todoProvider, AppLocalizations l10n) {
    final events = todoProvider.events;
    final completedEvents = todoProvider.completedEvents.length;
    final pendingEvents = todoProvider.pendingEvents.length;
    final overdueEvents = todoProvider.overdueEvents.length;

    // 计算所有任务统计
    int totalTasks = 0;
    int completedTasks = 0;
    for (final event in events) {
      if (event.tasks != null) {
        totalTasks += event.tasks!.length;
        completedTasks += event.tasks!
            .where((task) => task.status == TaskStatus.completed)
            .length;
      }
    }

    final completionRate = totalTasks > 0
        ? (completedTasks / totalTasks * 100).toStringAsFixed(0)
        : '0';

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // 第一行：总事件、已完成、进行中
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: '总事件',
                  value: events.length.toString(),
                  icon: Icons.event_note,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  title: l10n.completed,
                  value: completedEvents.toString(),
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  title: l10n.pending,
                  value: pendingEvents.toString(),
                  icon: Icons.pending,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // 第二行：已过期、总任务、完成率
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: l10n.overdue,
                  value: overdueEvents.toString(),
                  icon: Icons.warning,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  title: '总任务',
                  value: totalTasks.toString(),
                  icon: Icons.task,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  title: '完成率',
                  value: '$completionRate%',
                  icon: Icons.trending_up,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionList(
    BuildContext context,
    AuthProvider authProvider,
    TodoProvider todoProvider,
    AppLocalizations l10n,
  ) {
    final isOffline = todoProvider.isOfflineMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // 离线模式：显示切换到在线模式的提示卡片
          if (isOffline) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange[400]!,
                    Colors.orange[600]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    '当前为离线模式',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    '数据仅保存在本地设备\n切换到在线模式以同步数据到云端',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () => _switchToOnlineMode(context, todoProvider),
                    icon: const Icon(Icons.cloud_queue),
                    label: const Text(
                      '切换到在线模式',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 在线模式才显示账户设置
          if (!isOffline) ...[
            _buildSectionHeader('账户设置'),
            _buildFunctionGroup([
              _buildFunctionItem(
                icon: Icons.person_outline,
                title: '编辑个人资料',
                subtitle: '修改用户名、邮箱等信息',
                onTap: () => _showEditProfile(context),
              ),
              _buildFunctionItem(
                icon: Icons.lock_outline,
                title: '修改密码',
                subtitle: '更新账户密码',
                onTap: () => _showChangePassword(context),
              ),
            ]),
            const SizedBox(height: AppSpacing.md),
          ],

          // 应用设置区域
          _buildSectionHeader('应用设置'),
          _buildFunctionGroup([
            // 在线模式显示开关，离线模式不显示（已经有上面的大按钮了）
            if (!isOffline)
              _buildFunctionItem(
                icon: Icons.cloud_queue,
                title: '在线模式',
                subtitle: '当前为在线模式，数据会同步到服务器',
                trailing: Switch(
                  value: true,
                  onChanged: (value) =>
                      _toggleMode(context, todoProvider, !value),
                  activeColor: AppColors.primary,
                ),
              ),
            // 仅在线模式显示同步功能
            if (!isOffline)
              _buildFunctionItem(
                icon: Icons.sync,
                title: '同步数据',
                subtitle: '手动同步本地和服务器数据',
                onTap: () => _syncData(context, todoProvider),
                trailing: todoProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
            _buildFunctionItem(
              icon: Icons.language,
              title: '语言设置',
              subtitle: '中文 / English',
              onTap: () => _showLanguageSettings(context),
            ),
            _buildFunctionItem(
              icon: Icons.notifications_outlined,
              title: '通知设置',
              subtitle: '管理推送通知',
              onTap: () => _showNotificationSettings(context),
            ),
          ]),

          const SizedBox(height: AppSpacing.md),

          // 数据管理区域
          _buildSectionHeader('数据管理'),
          _buildFunctionGroup([
            _buildFunctionItem(
              icon: Icons.file_download_outlined,
              title: '导出数据',
              subtitle: '导出所有待办事项数据',
              onTap: () => _exportData(context),
            ),
            _buildFunctionItem(
              icon: Icons.file_upload_outlined,
              title: '导入数据',
              subtitle: '从文件导入数据',
              onTap: () => _importData(context),
            ),
            _buildFunctionItem(
              icon: Icons.delete_outline,
              title: '清除缓存',
              subtitle: '清除本地缓存数据',
              onTap: () => _clearCache(context),
            ),
          ]),

          const SizedBox(height: AppSpacing.md),

          // 关于区域
          _buildSectionHeader('关于'),
          _buildFunctionGroup([
            _buildFunctionItem(
              icon: Icons.info_outline,
              title: '关于应用',
              subtitle: '版本 ${Config.appVersion}',
              onTap: () => _showAbout(context),
            ),
            _buildFunctionItem(
              icon: Icons.help_outline,
              title: '帮助与反馈',
              subtitle: '获取帮助或提交反馈',
              onTap: () => _showHelp(context),
            ),
            _buildFunctionItem(
              icon: Icons.privacy_tip_outlined,
              title: '隐私政策',
              subtitle: '查看隐私政策',
              onTap: () => _showPrivacyPolicy(context),
            ),
          ]),

          const SizedBox(height: AppSpacing.md),

          // 退出登录按钮（仅在线模式显示）
          if (!isOffline && authProvider.isLoggedIn)
            _buildFunctionGroup([
              _buildFunctionItem(
                icon: Icons.logout,
                title: '退出登录',
                subtitle: '退出当前账户',
                titleColor: AppColors.error,
                onTap: () => _logout(context, authProvider),
              ),
            ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildFunctionGroup(List<Widget> children) {
    return Container(
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
        children: children,
      ),
    );
  }

  Widget _buildFunctionItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (titleColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: titleColor ?? AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  // 功能实现方法

  void _showEditProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('编辑个人资料功能开发中...')),
    );
  }

  void _showChangePassword(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('修改密码功能开发中...')),
    );
  }

  Future<void> _toggleMode(
    BuildContext context,
    TodoProvider todoProvider,
    bool offline,
  ) async {
    try {
      await todoProvider.switchMode(offline: offline);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(offline ? '已切换到离线模式' : '已切换到在线模式'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('切换失败: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _switchToOnlineMode(
    BuildContext context,
    TodoProvider todoProvider,
  ) async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('切换到在线模式'),
        content: const Text(
          '切换到在线模式后，数据将会同步到云端。\n'
          '如果您没有登录，将会跳转到登录页面。\n\n'
          '是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('切换'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 检查是否已登录
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isLoggedIn) {
        // 未登录，跳转到登录页
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('请先登录以使用在线模式'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // 已登录，切换模式
      await todoProvider.switchMode(offline: false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已切换到在线模式，正在同步数据...'),
            backgroundColor: AppColors.success,
          ),
        );

        // 自动同步数据
        try {
          await todoProvider.syncData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('数据同步成功'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('同步失败: ${e.toString()}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('切换失败: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _syncData(
      BuildContext context, TodoProvider todoProvider) async {
    if (todoProvider.isOfflineMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('离线模式下无法同步数据'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      await todoProvider.syncData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('数据同步成功'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('同步失败: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showLanguageSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('语言设置功能开发中...')),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知设置功能开发中...')),
    );
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出数据功能开发中...')),
    );
  }

  void _importData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入数据功能开发中...')),
    );
  }

  Future<void> _clearCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有本地缓存数据吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('清除缓存功能开发中...')),
      );
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'TodoList',
      applicationVersion: Config.appVersion,
      applicationIcon: const Icon(
        Icons.check_circle,
        size: 48,
        color: AppColors.primary,
      ),
      children: [
        const Text('一个简洁高效的待办事项管理应用'),
        const SizedBox(height: 8),
        const Text('支持二级任务、离线模式、数据同步等功能'),
      ],
    );
  }

  void _showHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('帮助与反馈功能开发中...')),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('隐私政策功能开发中...')),
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账户吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('退出'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.logout();
      if (mounted) {
        // 清除Provider数据
        context.read<TodoProvider>().clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已退出登录'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
