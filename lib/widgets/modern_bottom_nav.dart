import 'package:flutter/material.dart';

import '../utils/constants.dart';

class ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const ModernBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        isDark ? AppConstants.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomAppBar(
          elevation: 0,
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _navItem(
                      context,
                      icon: Icons.home_rounded,
                      label: "Home",
                      index: 0,
                    ),
                    const SizedBox(width: 8),
                    _navItem(
                      context,
                      icon: Icons.pie_chart_rounded,
                      label: "Stats",
                      index: 1,
                    ),
                  ],
                ),

                Row(
                  children: [
                    _navItem(
                      context,
                      icon: Icons.account_balance_wallet_rounded,
                      label: "Budget",
                      index: 2,
                    ),
                    const SizedBox(width: 8),
                    _navItem(
                      context,
                      icon: Icons.person_rounded,
                      label: "Profile",
                      index: 3,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required int index,
      }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final selected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap?.call(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppConstants.primary.withOpacity(0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? AppConstants.primary
                  : (isDark
                  ? Colors.white70
                  : Colors.black54),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: selected
                  ? Padding(
                padding:
                const EdgeInsets.only(left: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppConstants.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}