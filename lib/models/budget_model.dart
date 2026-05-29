import 'package:equatable/equatable.dart';

class BudgetModel extends Equatable {
  final String id;
  final String userId;
  final String categoryId;
  final double limitAmount;
  final DateTime month;
  final DateTime createdAt;

  const BudgetModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.createdAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      categoryId: (json['category_id'] ?? '').toString(),
      limitAmount: (json['limit_amount'] as num).toDouble(),
      month: DateTime.parse(json['month'].toString()),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    // 🔴 HARD SAFETY CHECK (prevents UUID error)
    if (userId.isEmpty || categoryId.isEmpty) {
      throw Exception("Invalid BudgetModel: userId or categoryId is empty");
    }

    return {
      'user_id': userId,
      'category_id': categoryId,
      'limit_amount': limitAmount,
      // safer full timestamp for Postgres
      'month': month.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, categoryId, month];
}