import 'package:flutter/material.dart';
import '../expense/expense_list_screen.dart';
import '../analytics/charts_screen.dart';
import '../settings/budget_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    ExpenseListScreen(),
    ChartsScreen(),
    BudgetScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: const Color(0xFF5B2EFF),
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Expenses"),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "Charts"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Budget"),
        ],
      ),
    );
  }
}
