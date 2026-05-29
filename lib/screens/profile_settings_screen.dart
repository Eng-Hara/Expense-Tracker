import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  Future<void> _logout(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.danger,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authService = ref.read(authServiceProvider);

      await authService.signOut();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    final themeNotifier = ref.read(themeProvider.notifier);

    return Container(
      color: AppConstants.darkBg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ================= HEADER =================

              Text(
                "Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 20),

              // ================= USER CARD =================

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppConstants.darkCard,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppConstants.primary,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? "User",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? "",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ================= PREFERENCES =================

              const Text(
                "Preferences",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: AppConstants.darkCard,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: SwitchListTile(
                  title: const Text(
                    "Dark Mode",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Toggle app theme",
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: isDark,
                  activeColor: AppConstants.primary,
                  onChanged: (value) {
                    themeNotifier.setDarkMode(value);
                  },
                ),
              ),

              const SizedBox(height: 26),

              // ================= MANAGEMENT =================

              const Text(
                "Management",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              _menuItem(
                icon: Icons.category_rounded,
                title: "Categories",
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/categories',
                  );
                },
              ),

              const SizedBox(height: 12),

              _menuItem(
                icon: Icons.bar_chart_rounded,
                title: "Budgets",
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/budgets',
                  );
                },
              ),

              const SizedBox(height: 30),

              // ================= LOGOUT =================

              GestureDetector(
                onTap: () => _logout(ref, context),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppConstants.danger.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: AppConstants.danger,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: AppConstants.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.darkCard,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppConstants.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
