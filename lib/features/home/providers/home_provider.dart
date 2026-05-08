import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/wallet_model.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/models/saving_model.dart';
import '../../../core/repositories/wallet_repository.dart';
import '../../../core/repositories/transaction_repository.dart';
import '../../../core/repositories/saving_repository.dart';
import '../../../core/mock/mock_wallet_repository.dart';
import '../../../core/mock/mock_transaction_repository.dart';
import '../../../core/mock/mock_saving_repository.dart';
import '../../auth/providers/auth_provider.dart';

// Repository providers
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return MockWalletRepository();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return MockTransactionRepository();
});

final savingRepositoryProvider = Provider<SavingRepository>((ref) {
  return MockSavingRepository();
});

// Wallet providers
final walletsProvider = FutureProvider<List<WalletModel>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return ref.watch(walletRepositoryProvider).getWallets(user.id);
});

final totalBalanceProvider = Provider<double>((ref) {
  final wallets = ref.watch(walletsProvider);
  return wallets.maybeWhen(
    data: (list) => list.fold(0.0, (sum, w) => sum + w.balance),
    orElse: () => 0.0,
  );
});

// Transaction providers
final transactionsProvider = FutureProvider<List<TransactionModel>>((
  ref,
) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return ref.watch(transactionRepositoryProvider).getTransactions(user.id);
});

final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.maybeWhen(
    data: (list) => list.take(5).toList(),
    orElse: () => [],
  );
});

final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.maybeWhen(
    data: (list) => list
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount),
    orElse: () => 0.0,
  );
});

final totalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.maybeWhen(
    data: (list) => list
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount),
    orElse: () => 0.0,
  );
});

// Saving providers
final savingsProvider = FutureProvider<List<SavingModel>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return ref.watch(savingRepositoryProvider).getSavings(user.id);
});

final totalSavingsProvider = Provider<double>((ref) {
  final savings = ref.watch(savingsProvider);
  return savings.maybeWhen(
    data: (list) => list.fold(0.0, (sum, s) => sum + s.currentAmount),
    orElse: () => 0.0,
  );
});

// Balance visibility toggle
final balanceVisibleProvider = StateProvider<bool>((ref) => true);
