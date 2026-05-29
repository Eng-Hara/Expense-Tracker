import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:smart_spend/providers/auth_provider.dart';

import '../models/transaction_model.dart';

import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';

import '../services/transaction_repository.dart';

import '../utils/constants.dart';

class AddTransactionSheet
    extends ConsumerStatefulWidget {
  const AddTransactionSheet({
    super.key,
  });

  @override
  ConsumerState<AddTransactionSheet>
  createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState
    extends ConsumerState<
        AddTransactionSheet> {
  final _formKey =
  GlobalKey<FormState>();

  String _type = 'expense';

  String? _categoryId;

  final _amountController =
  TextEditingController();

  final _noteController =
  TextEditingController();

  DateTime _selectedDate =
  DateTime.now();

  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_categoryId == null) {
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null ||
        amount <= 0) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref
          .read(authStateProvider)
          .valueOrNull;

      if (user == null) return;

      final repo = ref.read(
        transactionRepositoryProvider,
      );

      final transaction =
      TransactionModel(
        id: '',
        userId: user.id,
        categoryId: _categoryId!,
        amount: amount,
        type: _type,
        note:
        _noteController.text.trim(),
        date: _selectedDate,
        createdAt: DateTime.now(),
      );

      await repo.addTransaction(
          transaction);

      ref.invalidate(
          transactionStreamProvider);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text('Error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final categoriesAsync =
    ref.watch(
      categoryStreamProvider,
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppConstants.darkBg
            : Colors.white,

        borderRadius:
        const BorderRadius.vertical(
          top: Radius.circular(34),
        ),
      ),

      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: 18,
        bottom:
        MediaQuery.of(context)
            .viewInsets
            .bottom +
            28,
      ),

      child: SingleChildScrollView(
        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              // ================= HANDLE =================

              Center(
                child: Container(
                  width: 60,
                  height: 6,

                  decoration:
                  BoxDecoration(
                    color: isDark
                        ? Colors.white24
                        : Colors.black12,

                    borderRadius:
                    BorderRadius
                        .circular(50),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ================= TITLE =================

              Text(
                "Add Transaction",

                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : AppConstants
                      .textDark,

                  fontSize: 26,

                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(height: 24),

              // ================= TYPE =================

              Container(
                padding:
                const EdgeInsets.all(
                    6),

                decoration:
                BoxDecoration(
                  color: isDark
                      ? AppConstants
                      .darkCard
                      : AppConstants
                      .lightBg,

                  borderRadius:
                  BorderRadius
                      .circular(20),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child:
                      _typeButton(
                        title:
                        "Expense",

                        icon:
                        Icons
                            .arrow_upward_rounded,

                        value:
                        "expense",

                        color:
                        AppConstants
                            .danger,

                        isDark:
                        isDark,
                      ),
                    ),

                    const SizedBox(
                        width: 8),

                    Expanded(
                      child:
                      _typeButton(
                        title:
                        "Income",

                        icon:
                        Icons
                            .arrow_downward_rounded,

                        value:
                        "income",

                        color:
                        AppConstants
                            .success,

                        isDark:
                        isDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= AMOUNT =================

              TextFormField(
                controller:
                _amountController,

                keyboardType:
                TextInputType.number,

                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black,
                ),

                validator: (v) {
                  if (v == null ||
                      v.isEmpty) {
                    return 'Enter amount';
                  }

                  return null;
                },

                decoration:
                const InputDecoration(
                  hintText:
                  "Enter amount",

                  prefixIcon: Icon(
                    Icons
                        .attach_money_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ================= CATEGORY =================

              categoriesAsync.when(
                data: (categories) {
                  return DropdownButtonFormField<
                      String>(
                    value: _categoryId,

                    dropdownColor:
                    isDark
                        ? AppConstants
                        .darkCard
                        : Colors.white,

                    decoration:
                    const InputDecoration(
                      hintText:
                      "Select category",

                      prefixIcon: Icon(
                        Icons
                            .grid_view_rounded,
                      ),
                    ),

                    items:
                    categories.map((c) {
                      return DropdownMenuItem(
                        value: c.id,

                        child: Text(
                          c.name,
                        ),
                      );
                    }).toList(),

                    onChanged: (v) {
                      setState(() {
                        _categoryId = v;
                      });
                    },
                  );
                },

                loading: () =>
                const Center(
                  child:
                  CircularProgressIndicator(),
                ),

                error: (e, s) =>
                const Text(
                  "Error loading categories",
                ),
              ),

              const SizedBox(height: 18),

              // ================= DATE =================

              GestureDetector(
                onTap: () async {
                  final picked =
                  await showDatePicker(
                    context: context,
                    initialDate:
                    _selectedDate,

                    firstDate:
                    DateTime(2020),

                    lastDate:
                    DateTime.now(),
                  );

                  if (picked != null) {
                    setState(() {
                      _selectedDate =
                          picked;
                    });
                  }
                },

                child: Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),

                  decoration:
                  BoxDecoration(
                    color: isDark
                        ? AppConstants
                        .darkCard
                        : Colors.white,

                    borderRadius:
                    BorderRadius
                        .circular(18),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .calendar_month_rounded,

                        color: isDark
                            ? Colors.white70
                            : Colors.black54,
                      ),

                      const SizedBox(
                          width: 14),

                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [
                          Text(
                            "Transaction Date",

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
                            DateFormat
                                .yMMMMd()
                                .format(
                              _selectedDate,
                            ),

                            style:
                            TextStyle(
                              color: isDark
                                  ? Colors
                                  .white
                                  : Colors
                                  .black,

                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ================= NOTE =================

              TextField(
                controller:
                _noteController,

                maxLines: 3,

                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black,
                ),

                decoration:
                const InputDecoration(
                  hintText:
                  "Add note (optional)",

                  alignLabelWithHint:
                  true,

                  prefixIcon: Padding(
                    padding:
                    EdgeInsets.only(
                        bottom: 55),

                    child: Icon(
                      Icons
                          .notes_rounded,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ================= BUTTON =================

              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton(
                  onPressed:
                  _isLoading
                      ? null
                      : _saveTransaction,

                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,

                    child:
                    CircularProgressIndicator(
                      color:
                      Colors.white,

                      strokeWidth:
                      2,
                    ),
                  )
                      : const Text(
                    "Save Transaction",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeButton({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final selected =
        _type == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _type = value;
        });
      },

      child: AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 250,
        ),

        padding:
        const EdgeInsets.symmetric(
          vertical: 16,
        ),

        decoration: BoxDecoration(
          color: selected
              ? color
              : Colors.transparent,

          borderRadius:
          BorderRadius.circular(
              16),
        ),

        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Icon(
              icon,

              size: 20,

              color: selected
                  ? Colors.white
                  : color,
            ),

            const SizedBox(width: 8),

            Text(
              title,

              style: TextStyle(
                color: selected
                    ? Colors.white
                    : color,

                fontWeight:
                FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}