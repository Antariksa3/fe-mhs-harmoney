import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/transaction_model.dart';
import '../../home/providers/home_provider.dart';

// ─────────────────────────────────────────
// Search & Filter State
// ─────────────────────────────────────────

final transactionSearchProvider = StateProvider<String>((ref) => '');

final transactionFilterProvider = StateProvider<TransactionType?>(
  (ref) => null,
);

// ─────────────────────────────────────────
// Filtered Transactions
// Derived dari transactionsProvider + search + filter
// ─────────────────────────────────────────

final filteredTransactionListProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final search = ref.watch(transactionSearchProvider);
  final filter = ref.watch(transactionFilterProvider);

  return transactions.maybeWhen(
    data: (list) => list.where((t) {
      final matchSearch =
          search.isEmpty ||
          (t.description?.toLowerCase() ?? '').contains(search.toLowerCase());
      final matchFilter = filter == null || t.type == filter;
      return matchSearch && matchFilter;
    }).toList(),
    orElse: () => [],
  );
});

// ─────────────────────────────────────────
// Loading state dari transactionsProvider
// ─────────────────────────────────────────

final transactionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(transactionsProvider).isLoading;
});
