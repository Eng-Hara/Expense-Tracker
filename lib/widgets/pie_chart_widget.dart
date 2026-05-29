import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';

class PieChartWidget extends ConsumerWidget {
  final List<TransactionModel> transactions;

  final AsyncValue<List<CategoryModel>>
  categoriesAsync;

  const PieChartWidget({
    super.key,
    required this.transactions,
    required this.categoriesAsync,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final expenses =
    transactions.where((t) {
      return t.type == 'expense';
    }).toList();

    final total = expenses.fold(
      0.0,
          (a, b) => a + b.amount,
    );

    if (expenses.isEmpty) {
      return SizedBox(
        height: 260,
        child: Center(
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 52,
                color: isDark
                    ? Colors.white24
                    : Colors.black26,
              ),

              const SizedBox(height: 12),

              Text(
                "No expense data",

                style: TextStyle(
                  color: isDark
                      ? Colors.white54
                      : Colors.black54,

                  fontSize: 15,

                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return categoriesAsync.when(
      data: (categories) {
        final Map<String, double>
        expenseMap = {};

        for (final t in expenses) {
          expenseMap[t.categoryId] =
              (expenseMap[t.categoryId] ??
                  0) +
                  t.amount;
        }

        final entries =
        expenseMap.entries.toList();

        final sections =
        entries.map((e) {
          final category =
          categories.firstWhere(
                (c) => c.id == e.key,
            orElse: () =>
            categories.first,
          );

          final percent =
          total == 0
              ? 0
              : (e.value / total) *
              100;

          return PieChartSectionData(
            value: e.value,

            color: _hexToColor(
              category.color,
            ),

            radius: 58,

            title:
            '${percent.toStringAsFixed(0)}%',

            titleStyle:
            const TextStyle(
              color: Colors.white,
              fontWeight:
              FontWeight.bold,
              fontSize: 11,
            ),
          );
        }).toList();

        return SizedBox(
          height: 320,

          child: Column(
            children: [

              // ================= CHART =================

              SizedBox(
                height: 190,

                child: Stack(
                  alignment:
                  Alignment.center,

                  children: [
                    PieChart(
                      PieChartData(
                        sections:
                        sections,

                        centerSpaceRadius:
                        52,

                        sectionsSpace:
                        3,

                        borderData:
                        FlBorderData(
                          show: false,
                        ),
                      ),
                    ),

                    Column(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                      children: [
                        Text(
                          "Total",

                          style:
                          TextStyle(
                            color: isDark
                                ? Colors
                                .white54
                                : Colors
                                .black54,

                            fontSize:
                            12,
                          ),
                        ),

                        const SizedBox(
                            height: 4),

                        Text(
                          '\$${total.toStringAsFixed(0)}',

                          style:
                          TextStyle(
                            color: isDark
                                ? Colors
                                .white
                                : Colors
                                .black,

                            fontSize:
                            22,

                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ================= LEGEND =================

              Expanded(
                child:
                SingleChildScrollView(
                  physics:
                  const BouncingScrollPhysics(),

                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,

                    children:
                    entries.map((e) {
                      final category =
                      categories
                          .firstWhere(
                            (c) =>
                        c.id ==
                            e.key,

                        orElse: () =>
                        categories
                            .first,
                      );

                      return _legendItem(
                        title:
                        category.name,

                        amount: e.value,

                        color:
                        _hexToColor(
                          category.color,
                        ),

                        isDark:
                        isDark,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },

      loading: () => const SizedBox(
        height: 260,
        child: Center(
          child:
          CircularProgressIndicator(),
        ),
      ),

      error: (e, s) => SizedBox(
        height: 260,

        child: Center(
          child: Text(
            "Chart error",

            style: TextStyle(
              color: isDark
                  ? Colors.white54
                  : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendItem({
    required String title,
    required double amount,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: isDark
            ? AppConstants.darkCard
            : Colors.white,

        borderRadius:
        BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.04),

            blurRadius: 10,
          ),
        ],
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [

          // COLOR DOT

          Container(
            width: 10,
            height: 10,

            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 10),

          // TEXT

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black,

                  fontSize: 12,

                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                '\$${amount.toStringAsFixed(0)}',

                style: TextStyle(
                  color: isDark
                      ? Colors.white54
                      : Colors.black54,

                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(
        int.parse(
          hex.replaceFirst(
            '#',
            '0xff',
          ),
        ),
      );
    } catch (_) {
      return AppConstants.primary;
    }
  }
}