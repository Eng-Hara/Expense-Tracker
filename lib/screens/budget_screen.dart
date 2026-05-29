import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/budget_model.dart';
import '../models/category_model.dart';

import '../providers/auth_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';

import '../services/budget_repository.dart';

import '../utils/constants.dart';
import '../utils/icon_helper.dart';

import '../widgets/loading_widget.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() =>
      _BudgetScreenState();
}

class _BudgetScreenState
    extends ConsumerState<BudgetScreen> {
  final amountController = TextEditingController();

  String? selectedCategoryId;

  void _openSheet({
    BudgetModel? budget,
  }) {
    final isEdit = budget != null;

    if (isEdit) {
      amountController.text =
          budget.limitAmount.toString();

      selectedCategoryId = budget.categoryId;
    } else {
      amountController.clear();
      selectedCategoryId = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (_) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom:
            MediaQuery.of(context)
                .viewInsets
                .bottom +
                24,
          ),
          decoration: BoxDecoration(
            color: AppConstants.darkCard,
            borderRadius:
            const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),

          child: Consumer(
            builder: (context, ref, _) {
              final categoriesAsync =
              ref.watch(
                categoryStreamProvider,
              );

              return categoriesAsync.when(
                loading: () =>
                const SizedBox(
                  height: 200,
                  child: Center(
                    child:
                    CircularProgressIndicator(),
                  ),
                ),

                error: (e, s) =>
                const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      "Error loading categories",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                data: (categories) {
                  return Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration:
                          BoxDecoration(
                            color:
                            Colors.white24,
                            borderRadius:
                            BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 24),

                      Text(
                        isEdit
                            ? "Edit Budget"
                            : "Create Budget",
                        style:
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 24),

                      DropdownButtonFormField<
                          String>(
                        value:
                        selectedCategoryId,

                        dropdownColor:
                        AppConstants
                            .darkCard,

                        style:
                        const TextStyle(
                          color: Colors.white,
                        ),

                        decoration:
                        InputDecoration(
                          filled: true,
                          fillColor:
                          Colors.white10,

                          hintText:
                          "Select category",

                          hintStyle:
                          const TextStyle(
                            color:
                            Colors.white54,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),
                            borderSide:
                            BorderSide.none,
                          ),
                        ),

                        items:
                        categories.map((c) {
                          return DropdownMenuItem(
                            value: c.id,

                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                  _hexToColor(
                                    c.color,
                                  ),

                                  child: Icon(
                                    IconHelper
                                        .getIconData(
                                      c.icon,
                                    ),
                                    color: Colors
                                        .white,
                                    size: 18,
                                  ),
                                ),

                                const SizedBox(
                                    width: 12),

                                Text(
                                  c.name,
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        onChanged: (v) {
                          setState(() {
                            selectedCategoryId =
                                v;
                          });
                        },
                      ),

                      const SizedBox(
                          height: 18),

                      TextField(
                        controller:
                        amountController,

                        keyboardType:
                        TextInputType
                            .number,

                        style:
                        const TextStyle(
                          color: Colors.white,
                        ),

                        decoration:
                        InputDecoration(
                          filled: true,
                          fillColor:
                          Colors.white10,

                          hintText:
                          "Budget amount",

                          hintStyle:
                          const TextStyle(
                            color:
                            Colors.white54,
                          ),

                          prefixIcon:
                          const Icon(
                            Icons
                                .account_balance_wallet,
                            color:
                            Colors.white70,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),
                            borderSide:
                            BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 24),

                      SizedBox(
                        width:
                        double.infinity,
                        height: 56,

                        child:
                        ElevatedButton(
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            AppConstants
                                .primary,

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                18,
                              ),
                            ),
                          ),

                          onPressed: () async {
                            final user = ref
                                .read(
                              authStateProvider,
                            )
                                .valueOrNull;

                            if (user ==
                                null ||
                                selectedCategoryId ==
                                    null) {
                              return;
                            }

                            final amount =
                            double.tryParse(
                              amountController
                                  .text,
                            );

                            if (amount ==
                                null) {
                              return;
                            }

                            final repo =
                            ref.read(
                              budgetRepositoryProvider,
                            );

                            final month =
                            ref.read(
                              currentMonthProvider,
                            );

                            final newBudget =
                            BudgetModel(
                              id: isEdit
                                  ? budget.id
                                  : '',

                              userId:
                              user.id,

                              categoryId:
                              selectedCategoryId!,

                              limitAmount:
                              amount,

                              month:
                              DateTime(
                                month.year,
                                month.month,
                                1,
                              ),

                              createdAt:
                              DateTime
                                  .now(),
                            );

                            if (isEdit) {
                              await repo
                                  .updateBudget(
                                newBudget,
                              );
                            } else {
                              await repo
                                  .addBudget(
                                newBudget,
                              );
                            }

                            ref.invalidate(
                              budgetStreamProvider,
                            );

                            if (mounted) {
                              Navigator.pop(
                                  context);
                            }
                          },

                          child: Text(
                            isEdit
                                ? "Update Budget"
                                : "Save Budget",
                            style:
                            const TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _deleteBudget(
      String id,
      ) async {
    final repo = ref.read(
      budgetRepositoryProvider,
    );

    await repo.deleteBudget(id);

    ref.invalidate(
      budgetStreamProvider,
    );
  }

  double _spentAmount(
      String categoryId,
      List transactions,
      ) {
    return transactions
        .where(
          (t) =>
      t.categoryId ==
          categoryId &&
          t.type == 'expense',
    )
        .fold(
      0.0,
          (a, b) => a + b.amount,
    );
  }

  CategoryModel? _findCategory(
      List<CategoryModel> categories,
      String id,
      ) {
    try {
      return categories.firstWhere(
            (c) => c.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(
      budgetStreamProvider,
    );

    final transactionsAsync = ref.watch(
      transactionStreamProvider,
    );

    final categoriesAsync = ref.watch(
      categoryStreamProvider,
    );

    final month = DateFormat(
      'MMMM yyyy',
    ).format(
      ref.watch(
        currentMonthProvider,
      ),
    );

    return Scaffold(
      backgroundColor:
      AppConstants.darkBg,

      floatingActionButton:
      FloatingActionButton(
        backgroundColor:
        AppConstants.primary,

        onPressed: () =>
            _openSheet(),

        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: SafeArea(
        child: budgetsAsync.when(
          loading: () =>
          const LoadingWidget(),

          error: (e, s) => const Center(
            child: Text(
              "Error loading budgets",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          data: (budgets) {
            return transactionsAsync.when(
              loading: () =>
              const LoadingWidget(),

              error: (e, s) =>
              const Center(
                child: Text(
                  "Transaction error",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),

              data: (transactions) {
                return categoriesAsync.when(
                  loading: () =>
                  const LoadingWidget(),

                  error: (e, s) =>
                  const Center(
                    child: Text(
                      "Category error",
                      style: TextStyle(
                        color:
                        Colors.white,
                      ),
                    ),
                  ),

                  data: (categories) {
                    return SingleChildScrollView(
                      physics:
                      const BouncingScrollPhysics(),

                      padding:
                      const EdgeInsets.all(
                        20,
                      ),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                                  children: [
                                    const Text(
                                      "Budgets",
                                      style:
                                      TextStyle(
                                        color:
                                        Colors
                                            .white,
                                        fontSize:
                                        30,
                                        fontWeight:
                                        FontWeight
                                            .w800,
                                      ),
                                    ),

                                    const SizedBox(
                                        height:
                                        4),

                                    Text(
                                      month,
                                      style:
                                      const TextStyle(
                                        color:
                                        Colors
                                            .white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding:
                                const EdgeInsets.all(
                                  12,
                                ),

                                decoration:
                                BoxDecoration(
                                  color:
                                  AppConstants
                                      .primary,

                                  borderRadius:
                                  BorderRadius.circular(
                                    18,
                                  ),
                                ),

                                child:
                                const Icon(
                                  Icons
                                      .wallet_rounded,
                                  color: Colors
                                      .white,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 24),

                          if (budgets.isEmpty)
                            Container(
                              width:
                              double.infinity,

                              padding:
                              const EdgeInsets.symmetric(
                                vertical:
                                60,
                              ),

                              decoration:
                              BoxDecoration(
                                color:
                                AppConstants
                                    .darkCard,

                                borderRadius:
                                BorderRadius.circular(
                                  28,
                                ),
                              ),

                              child: Column(
                                children: const [
                                  Icon(
                                    Icons
                                        .account_balance_wallet_outlined,
                                    size:
                                    60,
                                    color: Colors
                                        .white24,
                                  ),

                                  SizedBox(
                                      height:
                                      16),

                                  Text(
                                    "No budgets yet",
                                    style:
                                    TextStyle(
                                      color: Colors
                                          .white54,
                                      fontSize:
                                      16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,

                              physics:
                              const NeverScrollableScrollPhysics(),

                              itemCount:
                              budgets.length,

                              separatorBuilder:
                                  (_, __) =>
                              const SizedBox(
                                height: 16,
                              ),

                              itemBuilder:
                                  (context, i) {
                                final b =
                                budgets[i];

                                final spent =
                                _spentAmount(
                                  b.categoryId,
                                  transactions,
                                );

                                final progress =
                                (spent /
                                    b.limitAmount)
                                    .clamp(
                                  0.0,
                                  1.0,
                                );

                                final category =
                                _findCategory(
                                  categories,
                                  b.categoryId,
                                );

                                return Container(
                                  padding:
                                  const EdgeInsets.all(
                                    18,
                                  ),

                                  decoration:
                                  BoxDecoration(
                                    color:
                                    AppConstants
                                        .darkCard,

                                    borderRadius:
                                    BorderRadius.circular(
                                      24,
                                    ),

                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors
                                            .black
                                            .withOpacity(
                                          0.15,
                                        ),

                                        blurRadius:
                                        24,

                                        offset:
                                        const Offset(
                                          0,
                                          10,
                                        ),
                                      ),
                                    ],
                                  ),

                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius:
                                            24,

                                            backgroundColor:
                                            _hexToColor(
                                              category
                                                  ?.color ??
                                                  '#4F46E5',
                                            ),

                                            child:
                                            Icon(
                                              IconHelper
                                                  .getIconData(
                                                category
                                                    ?.icon ??
                                                    'wallet',
                                              ),

                                              color:
                                              Colors
                                                  .white,
                                            ),
                                          ),

                                          const SizedBox(
                                              width:
                                              14),

                                          Expanded(
                                            child:
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,

                                              children: [
                                                Text(
                                                  category?.name ??
                                                      "Category",

                                                  style:
                                                  const TextStyle(
                                                    color:
                                                    Colors.white,

                                                    fontSize:
                                                    17,

                                                    fontWeight:
                                                    FontWeight.w700,
                                                  ),
                                                ),

                                                const SizedBox(
                                                    height:
                                                    4),

                                                Text(
                                                  "Budget Limit \$${b.limitAmount.toStringAsFixed(0)}",

                                                  style:
                                                  const TextStyle(
                                                    color:
                                                    Colors.white54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          PopupMenuButton<
                                              String>(
                                            color:
                                            AppConstants
                                                .darkCard,

                                            icon:
                                            const Icon(
                                              Icons
                                                  .more_vert,
                                              color:
                                              Colors.white,
                                            ),

                                            onSelected:
                                                (
                                                value,
                                                ) {
                                              if (value ==
                                                  'edit') {
                                                _openSheet(
                                                  budget:
                                                  b,
                                                );
                                              } else {
                                                _deleteBudget(
                                                  b.id,
                                                );
                                              }
                                            },

                                            itemBuilder:
                                                (
                                                context,
                                                ) =>
                                            [
                                              const PopupMenuItem(
                                                value:
                                                'edit',

                                                child:
                                                Text(
                                                  "Edit",
                                                  style:
                                                  TextStyle(
                                                    color:
                                                    Colors.white,
                                                  ),
                                                ),
                                              ),

                                              const PopupMenuItem(
                                                value:
                                                'delete',

                                                child:
                                                Text(
                                                  "Delete",
                                                  style:
                                                  TextStyle(
                                                    color:
                                                    Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                          height:
                                          20),

                                      ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(
                                          20,
                                        ),

                                        child:
                                        LinearProgressIndicator(
                                          value:
                                          progress,

                                          minHeight:
                                          12,

                                          backgroundColor:
                                          Colors
                                              .white10,

                                          color: progress >
                                              0.85
                                              ? Colors
                                              .red
                                              : AppConstants
                                              .primary,
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                          16),

                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,

                                        children: [
                                          Text(
                                            "Spent \$${spent.toStringAsFixed(0)}",

                                            style:
                                            const TextStyle(
                                              color:
                                              Colors.white70,
                                            ),
                                          ),

                                          Text(
                                            "${(progress * 100).toStringAsFixed(0)}%",

                                            style:
                                            TextStyle(
                                              color: progress >
                                                  0.85
                                                  ? Colors
                                                  .red
                                                  : Colors
                                                  .white,

                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                          const SizedBox(
                              height: 100),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _hexToColor(
      String hex,
      ) {
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