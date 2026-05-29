// lib/widgets/category_chip.dart
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../utils/icon_helper.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;
  final bool isSelected;

  const CategoryChip({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(category.name),
      avatar: Icon(
        IconHelper.getIconData(category.icon),
        size: 18,
      ),
      backgroundColor:
          Color(int.parse(category.color.replaceFirst('#', '0xFF')))
              .withOpacity(0.2),
      selectedColor: Color(int.parse(category.color.replaceFirst('#', '0xFF')))
          .withOpacity(0.5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
      selected: isSelected,
      onSelected: onTap != null ? (_) => onTap!() : null,
    );
  }
}
