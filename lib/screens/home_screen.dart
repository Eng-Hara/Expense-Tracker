import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/constants.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/glass_fab.dart';
import '../widgets/modern_bottom_nav.dart';
import 'budget_screen.dart';
import 'categories_screen.dart';
import 'dashboard_screen.dart';
import 'profile_settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  static const _titles = [
    'Expense Tacker',
    'Categories',
    'Budgets',
    'Profile',
  ];

  final List<Widget> _pages = const [
    DashboardScreen(),
    CategoriesScreen(),
    BudgetScreen(),
    ProfileSettingsScreen(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openAddTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBg : AppConstants.lightBg,
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _titles[_currentIndex],
                      style: TextStyle(
                        color: isDark ? Colors.white : AppConstants.textDark,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (_currentIndex == 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppConstants.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(isDark ? 0.1 : 0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.notifications_rounded,
                        color: isDark ? Colors.white70 : AppConstants.textDark,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? GlassFab(
              onPressed: _openAddTransaction,
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
