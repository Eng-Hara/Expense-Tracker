import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_list.dart';
import '../utils/constants.dart';

import '../widgets/add_transaction_sheet.dart';
import '../widgets/loading_widget.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/glass_fab.dart';
import '../widgets/modern_bottom_nav.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime selectedMonth = DateTime.now();

  Future<void> pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedMonth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final transactionsAsync = ref.watch(transactionStreamProvider);
    final categoriesAsync = ref.watch(categoryStreamProvider);

    return Container(
      color: isDark ? AppConstants.darkBg : AppConstants.lightBg,
      child: SafeArea(
        child: transactionsAsync.when(
          loading: () => const LoadingWidget(),
          error: (e, s) => Center(
            child: Text("Error: $e"),
          ),
          data: (transactions) {
            final monthTransactions = transactions.where((t) {
              return t.date.year == selectedMonth.year &&
                  t.date.month == selectedMonth.month;
            }).toList();

            final income = monthTransactions
                .where((t) => t.type == 'income')
                .fold(0.0, (a, b) => a + b.amount);

            final expense = monthTransactions
                .where((t) => t.type == 'expense')
                .fold(0.0, (a, b) => a + b.amount);

            final balance = income - expense;

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(transactionStreamProvider);
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                    top: 20, left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Statistics',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : AppConstants.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: pickMonth,
                          child: const Text('This Month'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                        isDark ? AppConstants.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: SizedBox(
                        height: 260,
                        child: PieChartWidget(
                          transactions: monthTransactions,
                          categoriesAsync: categoriesAsync,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : AppConstants.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    TransactionList(
                      transactions: monthTransactions.take(5).toList(),
                      categoriesAsync: categoriesAsync,
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}