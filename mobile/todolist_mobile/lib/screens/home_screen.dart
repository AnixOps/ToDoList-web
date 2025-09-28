import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './todo_list_screen.dart'; // Added import
import './profile_screen.dart'; // Added import
import '../providers/todo_provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TodoListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化 TodoProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final todoProvider = context.read<TodoProvider>();
      final authProvider = context.read<AuthProvider>();

      // 初始化 TodoProvider
      todoProvider.init().then((_) {
        // 如果用户已登录，加载事件数据
        if (authProvider.isLoggedIn) {
          todoProvider.loadEvents(userId: authProvider.user?.id);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        // selectedItemColor: AppColors.primary, // Assuming AppColors is defined in constants.dart
        // unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '任务',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
