import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/loading_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // 登录成功，跳转到首页
      context.go('/home');
    } else if (mounted) {
      // 显示错误信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? '登录失败'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        
                        // 标题
                        Text(
                          '欢迎回来',
                          style: AppTextStyles.largeTitle,
                        ),
                        
                        const SizedBox(height: AppSpacing.sm),
                        
                        Text(
                          '登录您的账户继续使用',
                          style: AppTextStyles.callout.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.xxl),
                        
                        // 邮箱输入框
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: '邮箱',
                            hintText: '请输入您的邮箱地址',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入邮箱';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return '请输入有效的邮箱地址';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppSpacing.md),
                        
                        // 密码输入框
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                          decoration: InputDecoration(
                            labelText: '密码',
                            hintText: '请输入您的密码',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入密码';
                            }
                            if (value.length < 6) {
                              return '密码长度至少6位';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppSpacing.md),
                        
                        // 记住我
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            Text(
                              '记住我',
                              style: AppTextStyles.callout,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // TODO: 忘记密码功能
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('功能开发中...')),
                                );
                              },
                              child: Text(
                                '忘记密码？',
                                style: AppTextStyles.callout.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: AppSpacing.xl),
                        
                        // 登录按钮
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    '登录',
                                    style: AppTextStyles.headline.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.lg),
                        
                        // 分割线
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Text(
                                '或',
                                style: AppTextStyles.callout.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        
                        const SizedBox(height: AppSpacing.lg),
                        
                        // 离线模式按钮
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: 离线模式功能
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('离线模式开发中...')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                            ),
                            child: Text(
                              '使用离线模式',
                              style: AppTextStyles.headline.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.xxl),
                        
                        // 注册链接
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '还没有账户？',
                                style: AppTextStyles.callout.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.go('/register');
                                },
                                child: Text(
                                  '立即注册',
                                  style: AppTextStyles.callout.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 加载遮罩
                if (authProvider.isLoading)
                  const LoadingWidget(),
              ],
            );
          },
        ),
      ),
    );
  }
}