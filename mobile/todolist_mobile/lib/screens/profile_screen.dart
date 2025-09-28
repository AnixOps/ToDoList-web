import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 设置页面
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // 用户头像
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user?.name.substring(0, 1).toUpperCase() ?? 'U',
                    style: AppTextStyles.largeTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // 用户信息
                Text(
                  user?.name ?? '未知用户',
                  style: AppTextStyles.title2,
                ),
                
                const SizedBox(height: AppSpacing.xs),
                
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.callout.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // 功能列表
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('编辑资料'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: 编辑资料
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined),
                        title: const Text('通知设置'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: 通知设置
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('帮助与支持'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: 帮助页面
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('关于我们'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: 关于页面
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // 登出按钮
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('确认登出'),
                          content: const Text('您确定要登出当前账户吗？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('确认'),
                            ),
                          ],
                        ),
                      );
                      
                      if (shouldLogout == true) {
                        await authProvider.logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('登出'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}