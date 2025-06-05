import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../transaction/income_list_screen.dart';
import '../transaction/expense_list_screen.dart';
import '../categories/category_management_screen.dart';
import './dashboard_screen.dart';
import '../analytics/analytics_screen.dart';
import '../transaction/transaction_landing_screen.dart';
import '../profile/profile_screen.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const TransactionLandingScreen(),
    const CategoryManagementScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        context.read<CategoryViewModel>().loadCategories();
        context.read<IncomeViewModel>().loadIncomes();
        context.read<ExpenseViewModel>().loadExpenses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Phân tích',
          ),
          NavigationDestination(
            icon: Icon(Icons.compare_arrows),
            label: 'Giao dịch',
          ),
          NavigationDestination(icon: Icon(Icons.category), label: 'Category'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}
