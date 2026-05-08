import '../models/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getTransactions(String userId);
  Future<TransactionModel> addTransaction(TransactionModel transaction);
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String transactionId);
  Future<List<TransactionModel>> getTransactionsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  );
}
