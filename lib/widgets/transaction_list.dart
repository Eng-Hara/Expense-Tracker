import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../utils/icon_helper.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final AsyncValue<List<CategoryModel>> categoriesAsync;
  final ValueChanged<TransactionModel>? onEdit;
  final ValueChanged<TransactionModel>? onDelete;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.categoriesAsync,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 42,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
            const SizedBox(height: 14),
            Text(
              "No transactions yet",
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return categoriesAsync.when(
      data: (categories) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final t = transactions[index];
            final isIncome = t.type == 'income';
            final category = categories.firstWhere(
              (c) => c.id == t.categoryId,
              orElse: () => categories.isNotEmpty
                  ? categories.first
                  : CategoryModel(
                      id: '',
                      userId: '',
                      name: 'Unknown',
                      color: '#7C3AED',
                      icon: 'help',
                      createdAt: DateTime.now(),
                    ),
            );
            final categoryColor =
                Color(int.parse(category.color.replaceFirst('#', '0xFF')));

            return Dismissible(
              key: ValueKey(t.id),
              direction: DismissDirection.endToStart,
              background: Container(
                decoration: BoxDecoration(
                  color: AppConstants.danger,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                ),
              ),
              onDismissed: (_) => onDelete?.call(t),
              child: GestureDetector(
                onTap: () => onEdit?.call(t),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppConstants.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          IconHelper.getIconData(category.icon),
                          color: categoryColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.note?.trim().isNotEmpty == true
                                  ? t.note!
                                  : category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppConstants.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: categoryColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color:
                                      isDark ? Colors.white38 : Colors.black38,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd MMM').format(t.date),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isIncome ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isIncome
                                  ? AppConstants.success
                                  : AppConstants.danger,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isIncome
                                  ? AppConstants.success.withOpacity(0.12)
                                  : AppConstants.danger.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              isIncome ? 'Income' : 'Expense',
                              style: TextStyle(
                                color: isIncome
                                    ? AppConstants.success
                                    : AppConstants.danger,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(
        child: Text(
          'Unable to load categories',
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      ),
    );
  }
}
