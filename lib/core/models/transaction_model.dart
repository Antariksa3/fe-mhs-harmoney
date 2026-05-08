import 'category_model.dart';

enum TransactionType { expense, income, transfer }

class TransactionModel {
  final String id;
  final String userId;
  final String walletId;
  final String? toWalletId; // untuk transfer
  final String categoryId;
  final TransactionType type;
  final double amount;
  final String? description;
  final DateTime date;
  final String? billImagePath;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.walletId,
    this.toWalletId,
    required this.categoryId,
    required this.type,
    required this.amount,
    this.description,
    required this.date,
    this.billImagePath,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'],
        userId: json['userId'],
        walletId: json['walletId'],
        toWalletId: json['toWalletId'],
        categoryId: json['categoryId'],
        type: TransactionType.values.byName(json['type']),
        amount: (json['amount'] as num).toDouble(),
        description: json['description'],
        date: DateTime.parse(json['date']),
        billImagePath: json['billImagePath'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'walletId': walletId,
    'toWalletId': toWalletId,
    'categoryId': categoryId,
    'type': type.name,
    'amount': amount,
    'description': description,
    'date': date.toIso8601String(),
    'billImagePath': billImagePath,
  };
}
