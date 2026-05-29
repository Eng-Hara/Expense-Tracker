import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final String type;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.type,
    this.note,
    required this.date,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      categoryId: (json['category_id'] ?? '').toString(),
      amount: (json['amount'] as num).toDouble(),
      type: (json['type'] ?? '').toString(),
      note: json['note']?.toString(),
      date: DateTime.parse(json['date'].toString()),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    // 🔴 HARD VALIDATION
    if (userId.isEmpty || categoryId.isEmpty) {
      throw Exception(
        'Invalid TransactionModel: userId/categoryId empty',
      );
    }

    return {
      // ✅ NEVER send empty UUID
      if (id.isNotEmpty) 'id': id,

      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'note': note,
      'date': date.toIso8601String().split('T')[0],

      // ❌ DON'T send created_at manually
      // PostgreSQL handles it automatically
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    categoryId,
    amount,
    type,
  ];
}