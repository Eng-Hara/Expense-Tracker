import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../utils/icon_helper.dart';

class BudgetCard extends StatelessWidget {
  final CategoryModel category;
  final double limit;
  final double spent;
  final double remaining;
  final double percent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetCard({
    super.key,
    required this.category,
    required this.limit,
    required this.spent,
    required this.remaining,
    required this.percent,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(
                      int.parse(category.color.replaceFirst('#', '0xFF'))),
                  child: Icon(IconHelper.getIconData(category.icon),
                      color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Budget: \$${limit.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey.shade300,
                color: percent > 0.9 ? Colors.red : Colors.teal),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Spent: \$${spent.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12)),
                Text('Remaining: \$${remaining.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
