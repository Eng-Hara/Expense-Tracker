import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/profile_settings_screen.dart';

import 'utils/constants.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,

      // ================= THEMES =================
      theme: AppConstants.lightTheme,
      darkTheme: AppConstants.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // ================= START SCREEN =================
      initialRoute: '/',

      // ================= ROUTES =================
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const HomeScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/budgets': (context) => const BudgetScreen(),
        '/profile': (context) => const ProfileSettingsScreen(),
      },

      // ================= SMOOTH ANIMATION =================
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case '/login':
            page = const LoginScreen();
            break;
          case '/signup':
            page = const SignupScreen();
            break;
          case '/home':
            page = const HomeScreen();
            break;
          case '/dashboard':
            page = const HomeScreen();
            break;
          case '/categories':
            page = const CategoriesScreen();
            break;
          case '/budgets':
            page = const BudgetScreen();
            break;
          case '/profile':
            page = const ProfileSettingsScreen();
            break;
          default:
            page = const SplashScreen();
        }

        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}
