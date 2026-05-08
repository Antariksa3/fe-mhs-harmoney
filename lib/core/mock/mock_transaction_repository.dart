import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: 'trx-001',
      userId: 'user-001',
      walletId: 'wallet-001',
      categoryId: 'cat-001',
      type: TransactionType.expense,
      amount: 72000,
      description: 'Starbucks Coffee',
      date: DateTime(2026, 3, 21),
    ),
    TransactionModel(
      id: 'trx-002',
      userId: 'user-001',
      walletId: 'wallet-002',
      categoryId: 'cat-001',
      type: TransactionType.expense,
      amount: 50000,
      description: 'Makan Siang',
      date: DateTime(2026, 3, 21),
    ),
    TransactionModel(
      id: 'trx-003',
      userId: 'user-001',
      walletId: 'wallet-002',
      categoryId: 'cat-income-001',
      type: TransactionType.income,
      amount: 7500000,
      description: 'Salary',
      date: DateTime(2026, 3, 1),
    ),
  ];

  @override
  Future<List<TransactionModel>> getTransactions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _transactions.where((t) => t.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newTransaction = TransactionModel(
      id: const Uuid().v4(),
      userId: transaction.userId,
      walletId: transaction.walletId,
      toWalletId: transaction.toWalletId,
      categoryId: transaction.categoryId,
      type: transaction.type,
      amount: transaction.amount,
      description: transaction.description,
      date: transaction.date,
    );
    _transactions.add(newTransaction);
    return newTransaction;
  }

  @override
  Future<TransactionModel> updateTransaction(
    TransactionModel transaction,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index == -1) throw Exception('Transaction not found');
    _transactions[index] = transaction;
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _transactions.removeWhere((t) => t.id == transactionId);
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _transactions
        .where(
          (t) =>
              t.userId == userId &&
              t.date.isAfter(start) &&
              t.date.isBefore(end),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
