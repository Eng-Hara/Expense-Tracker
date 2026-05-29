import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';

import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';

import '../services/category_repository.dart';

import '../utils/constants.dart';
import '../utils/icon_helper.dart';

import '../widgets/loading_widget.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() =>
      _CategoriesScreenState();
}

class _CategoriesScreenState
    extends ConsumerState<CategoriesScreen> {
  final _nameController = TextEditingController();

  String _selectedColor = '#4F46E5';
  String _selectedIcon = 'fastfood';

  String? _editingId;
  bool _isEditing = false;

  final List<String> _colors = [
    '#4F46E5',
    '#22C55E',
    '#F97316',
    '#EF4444',
    '#A855F7',
    '#06B6D4',
    '#EAB308',
    '#14B8A6',
  ];

  void _openSheet({CategoryModel? category}) {
    if (category != null) {
      _isEditing = true;
      _editingId = category.id;
      _nameController.text = category.name;
      _selectedColor = category.color;
      _selectedIcon = category.icon;
    } else {
      _isEditing = false;
      _editingId = null;
      _nameController.clear();
      _selectedColor = '#4F46E5';
      _selectedIcon = 'fastfood';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConstants.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                    20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      _isEditing
                          ? "Edit Category"
                          : "New Category",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Category Name",
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                        ),
                        prefixIcon: const Icon(
                          Icons.category_rounded,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: AppConstants.darkBg,
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select Color",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _colors.map((color) {
                          final selected =
                              _selectedColor == color;

                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _selectedColor = color;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(
                                  milliseconds: 250),
                              margin:
                              const EdgeInsets.only(
                                  right: 12),
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Color(
                                  int.parse(
                                    color.replaceFirst(
                                      '#',
                                      '0xff',
                                    ),
                                  ),
                                ),
                                shape: BoxShape.circle,
                                border: selected
                                    ? Border.all(
                                  color:
                                  Colors.white,
                                  width: 3,
                                )
                                    : null,
                              ),
                              child: selected
                                  ? const Icon(
                                Icons.check,
                                color:
                                Colors.white,
                                size: 18,
                              )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select Icon",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                      IconHelper.iconOptions.map((icon) {
                        final selected =
                            _selectedIcon == icon;

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedIcon = icon;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 250),
                            padding:
                            const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppConstants.primary
                                  : AppConstants.darkBg,
                              borderRadius:
                              BorderRadius.circular(
                                  18),
                              border: Border.all(
                                color: selected
                                    ? Colors.transparent
                                    : Colors.white10,
                              ),
                            ),
                            child: Icon(
                              IconHelper.getIconData(
                                  icon),
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          AppConstants.primary,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                                18),
                          ),
                        ),
                        onPressed: _saveCategory,
                        child: Text(
                          _isEditing
                              ? "Update Category"
                              : "Create Category",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveCategory() async {
    final authState = ref.read(authStateProvider);

    final userId = authState.value?.id;

    if (userId == null) return;

    final repo =
    ref.read(categoryRepositoryProvider);

    final category = CategoryModel(
      id: _editingId ?? '',
      userId: userId,
      name: _nameController.text.trim(),
      color: _selectedColor,
      icon: _selectedIcon,
      createdAt: DateTime.now(),
    );

    try {
      if (_isEditing) {
        await repo.updateCategory(category);
      } else {
        await repo.addCategory(category);
      }

      ref.invalidate(categoryStreamProvider);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  Future<void> _delete(String id) async {
    final repo =
    ref.read(categoryRepositoryProvider);

    await repo.deleteCategory(id);

    ref.invalidate(categoryStreamProvider);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync =
    ref.watch(categoryStreamProvider);

    return Scaffold(
      backgroundColor: AppConstants.darkBg,

      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const LoadingWidget(),

          error: (e, s) => Center(
            child: Text(
              "Error loading categories",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ),

          data: (categories) {
            return SingleChildScrollView(
              physics:
              const BouncingScrollPhysics(),

              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Categories',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () => _openSheet(),

                        child: Container(
                          padding:
                          const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color:
                            AppConstants.primary,

                            borderRadius:
                            BorderRadius.circular(
                                18),

                            boxShadow: [
                              BoxShadow(
                                color: AppConstants
                                    .primary
                                    .withOpacity(0.25),

                                blurRadius: 20,

                                offset:
                                const Offset(
                                    0, 10),
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (categories.isEmpty)
                    Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 60,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.darkCard,
                        borderRadius:
                        BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: const [
                          Icon(
                            Icons
                                .category_outlined,
                            size: 48,
                            color: Colors.white38,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No categories yet',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
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
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final c = categories[index];

                        return Container(
                          padding:
                          const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color:
                            AppConstants.darkCard,
                            borderRadius:
                            BorderRadius.circular(
                                22),
                          ),

                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                Color(
                                  int.parse(
                                    c.color.replaceFirst(
                                      '#',
                                      '0xff',
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  IconHelper
                                      .getIconData(
                                      c.icon),
                                  color:
                                  Colors.white,
                                ),
                              ),

                              const SizedBox(
                                  width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      c.name,
                                      style:
                                      const TextStyle(
                                        color: Colors
                                            .white,
                                        fontSize: 16,
                                        fontWeight:
                                        FontWeight
                                            .w700,
                                      ),
                                    ),
                                    const SizedBox(
                                        height: 4),
                                    Text(
                                      c.icon,
                                      style:
                                      const TextStyle(
                                        color: Colors
                                            .white38,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color:
                                  Colors.white70,
                                ),
                                onPressed: () =>
                                    _openSheet(
                                      category: c,
                                    ),
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _delete(c.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 120),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}