import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/models/wallet_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../home/providers/home_provider.dart';
import '../providers/transaction_provider.dart';

// Map categoryId → nama (sama seperti di report_screen)
const _categoryNames = {
  'cat-001': 'Food & Beverage',
  'cat-002': 'Transportation',
  'cat-003': 'Education',
  'cat-004': 'Shopping',
  'cat-005': 'Health',
  'cat-006': 'Entertainment',
  'cat-income-001': 'Salary',
  'cat-income-002': 'Business',
  'cat-income-003': 'Freelance',
  'cat-income-004': 'Investment',
  'cat-income-005': 'Bonus',
  'cat-transfer-001': 'Bank',
  'cat-transfer-002': 'E-Wallet',
  'cat-transfer-003': 'Cash',
};

class TransactionDetailScreen extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  Color get _typeColor {
    switch (transaction.type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.transfer:
        return AppColors.transfer;
      default:
        return AppColors.expense;
    }
  }

  IconData get _typeIcon {
    switch (transaction.type) {
      case TransactionType.income:
        return Icons.arrow_downward_rounded;
      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
      default:
        return Icons.arrow_upward_rounded;
    }
  }

  String get _typeLabel {
    switch (transaction.type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.transfer:
        return 'Transfer';
      default:
        return 'Expense';
    }
  }

  String get _amountPrefix {
    switch (transaction.type) {
      case TransactionType.income:
        return '+ Rp';
      case TransactionType.transfer:
        return '→ Rp';
      default:
        return '- Rp';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat('#,###', 'id_ID');
    final wallets = ref.watch(walletsProvider).valueOrNull ?? [];

    final wallet = wallets.firstWhere(
      (w) => w.id == transaction.walletId,
      orElse: () => wallets.isNotEmpty
          ? wallets.first
          : WalletModel(
              id: transaction.walletId,
              userId: '',
              name: 'Unknown Wallet',
              balance: 0,
            ),
    );

    final toWallet = transaction.toWalletId != null
        ? wallets.firstWhere(
            (w) => w.id == transaction.toWalletId,
            orElse: () => WalletModel(
              id: transaction.toWalletId!,
              userId: '',
              name: 'Unknown Wallet',
              balance: 0,
            ),
          )
        : null;

    final categoryName = _categoryNames[transaction.categoryId] ?? 'Others';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text('Detail', style: AppTextStyles.headingMedium),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => _showDeleteDialog(context, ref),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(Icons.delete_outline, color: AppColors.error),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // --- Amount card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _typeColor.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _typeColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_typeIcon, color: _typeColor, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _typeLabel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_amountPrefix${formatter.format(transaction.amount.toInt())}',
                    style: AppTextStyles.amountLarge.copyWith(
                      color: _typeColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Detail rows ---
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: categoryName,
                  ),
                  _Divider(),
                  _DetailRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: transaction.type == TransactionType.transfer
                        ? 'From Wallet'
                        : 'Wallet',
                    value: wallet.name,
                  ),
                  if (toWallet != null) ...[
                    _Divider(),
                    _DetailRow(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'To Wallet',
                      value: toWallet.name,
                    ),
                  ],
                  _Divider(),
                  _DetailRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'Date',
                    value: DateFormat(
                      'EEEE, dd MMMM yyyy',
                    ).format(transaction.date),
                  ),
                  if (transaction.description != null &&
                      transaction.description!.isNotEmpty) ...[
                    _Divider(),
                    _DetailRow(
                      icon: Icons.notes_rounded,
                      label: 'Description',
                      value: transaction.description!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            AppButton(
              label: 'Delete Transaction',
              backgroundColor: AppColors.error,
              onPressed: () => _showDeleteDialog(context, ref),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Transaction', style: AppTextStyles.headingMedium),
        content: Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // --- MULAI LOGIKA REFUND SALDO ---
              final wallets = ref.read(walletsProvider).valueOrNull ?? [];
              final walletRepo = ref.read(walletRepositoryProvider);
              final sourceWallet = wallets.firstWhere(
                (w) => w.id == transaction.walletId,
                // Fallback jika tidak ditemukan
                orElse: () => WalletModel(
                  id: transaction.walletId,
                  userId: '',
                  name: 'Unknown',
                  balance: 0,
                ),
              );

              if (sourceWallet.id != transaction.walletId)
                return; // Keamanan tambahan

              if (transaction.type == TransactionType.expense) {
                // Refund expense (tambah saldo kembali)
                await walletRepo.updateWallet(
                  sourceWallet.copyWith(
                    balance: sourceWallet.balance + transaction.amount,
                  ),
                );
              } else if (transaction.type == TransactionType.income) {
                // Refund income (tarik kembali saldo)
                await walletRepo.updateWallet(
                  sourceWallet.copyWith(
                    balance: sourceWallet.balance - transaction.amount,
                  ),
                );
              } else if (transaction.type == TransactionType.transfer) {
                // Refund transfer (kembalikan ke dompet asal, tarik dari tujuan)
                await walletRepo.updateWallet(
                  sourceWallet.copyWith(
                    balance: sourceWallet.balance + transaction.amount,
                  ),
                );

                if (transaction.toWalletId != null) {
                  final targetWallet = wallets.firstWhere(
                    (w) => w.id == transaction.toWalletId,
                  );
                  await walletRepo.updateWallet(
                    targetWallet.copyWith(
                      balance: targetWallet.balance - transaction.amount,
                    ),
                  );
                }
              }
              // --- SELESAI LOGIKA REFUND ---

              // Hapus transaksi aslinya
              await ref
                  .read(transactionRepositoryProvider)
                  .deleteTransaction(transaction.id);

              ref.invalidate(transactionsProvider);
              ref.invalidate(walletsProvider);

              if (context.mounted) {
                Navigator.pop(context); // tutup dialog
                Navigator.pop(context); // kembali ke list
              }
            },
            child: Text(
              'Delete',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodyMedium),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.divider,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
