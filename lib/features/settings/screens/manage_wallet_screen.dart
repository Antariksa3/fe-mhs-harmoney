import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/wallet_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';

class ManageWalletScreen extends ConsumerWidget {
  const ManageWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider);
    final totalBalance = ref.watch(totalBalanceProvider);

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

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
        title: Text('Manage Wallet', style: AppTextStyles.headingMedium),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Wallet list
          Expanded(
            child: wallets.when(
              data: (list) => list.isEmpty
                  ? Center(
                      child: Text(
                        'No wallets yet.\nAdd your first wallet!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final wallet = list[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _WalletItem(
                            wallet: wallet,
                            onTap: () =>
                                _showEditWalletModal(context, ref, wallet),
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),

          // Bottom: total + add button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Balance', style: AppTextStyles.bodySmall),
                        Text(
                          currencyFormat.format(totalBalance),
                          style: AppTextStyles.amountMedium,
                        ),
                      ],
                    ),
                    wallets.when(
                      data: (list) => Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Total Wallet', style: AppTextStyles.bodySmall),
                          Text(
                            '${list.length}',
                            style: AppTextStyles.amountMedium,
                          ),
                        ],
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: '+ Add Wallet',
                  onPressed: () => _showAddWalletModal(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWalletModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WalletFormModal(
        title: 'Add Wallet',
        buttonLabel: 'Add',
        onSubmit: (name, balance) async {
          final user = ref.read(authProvider).user!;
          final wallet = WalletModel(
            id: const Uuid().v4(),
            userId: user.id,
            name: name,
            balance: balance,
          );
          await ref.read(walletRepositoryProvider).addWallet(wallet);
          ref.invalidate(walletsProvider);
        },
      ),
    );
  }

  void _showEditWalletModal(
    BuildContext context,
    WidgetRef ref,
    WalletModel wallet,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WalletFormModal(
        title: 'Edit Wallet',
        buttonLabel: 'Save',
        initialName: wallet.name,
        initialBalance: wallet.balance,
        showDelete: true,
        onSubmit: (name, balance) async {
          final updated = wallet.copyWith(name: name, balance: balance);
          await ref.read(walletRepositoryProvider).updateWallet(updated);
          ref.invalidate(walletsProvider);
        },
        onDelete: () async {
          await ref.read(walletRepositoryProvider).deleteWallet(wallet.id);
          ref.invalidate(walletsProvider);
        },
      ),
    );
  }
}

// Wallet list item
class _WalletItem extends StatelessWidget {
  final WalletModel wallet;
  final VoidCallback onTap;

  const _WalletItem({required this.wallet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(wallet.name, style: AppTextStyles.labelLarge)),
            Text(
              currencyFormat.format(wallet.balance),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Form modal untuk add & edit wallet
class _WalletFormModal extends ConsumerStatefulWidget {
  final String title;
  final String buttonLabel;
  final String? initialName;
  final double? initialBalance;
  final bool showDelete;
  final Future<void> Function(String name, double balance) onSubmit;
  final Future<void> Function()? onDelete;

  const _WalletFormModal({
    required this.title,
    required this.buttonLabel,
    this.initialName,
    this.initialBalance,
    this.showDelete = false,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  ConsumerState<_WalletFormModal> createState() => _WalletFormModalState();
}

class _WalletFormModalState extends ConsumerState<_WalletFormModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _balanceController = TextEditingController(
      text: widget.initialBalance != null
          ? NumberFormat(
              '#,###',
              'id_ID',
            ).format(widget.initialBalance!.toInt())
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.isEmpty) {
      _showError('Wallet name is required');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final rawBalance = _balanceController.text
          .replaceAll('.', '')
          .replaceAll(',', '');
      final balance = rawBalance.isEmpty ? 0.0 : double.parse(rawBalance);

      await widget.onSubmit(_nameController.text.trim(), balance);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError('Something went wrong');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    if (widget.onDelete == null) return;

    setState(() => _isLoading = true);
    try {
      await widget.onDelete!();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError('Failed to delete wallet');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: AppTextStyles.headingMedium),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Icon placeholder
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),

            const SizedBox(height: 24),

            // Wallet Name
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Wallet Name', style: AppTextStyles.labelLarge),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: AppTextStyles.bodyLarge,
              maxLength: 20,
              decoration: InputDecoration(
                hintText: 'Add Your Wallet Name',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textHint,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                counterStyle: AppTextStyles.bodySmall,
              ),
            ),

            const SizedBox(height: 16),

            // Balance
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.showDelete ? 'Edit Balance' : 'Initial Balance',
                style: AppTextStyles.labelLarge,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Rp',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _balanceController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Add Nominal',
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textHint,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      final clean = value
                          .replaceAll('.', '')
                          .replaceAll(',', '');
                      if (clean.isEmpty) return;
                      final formatted = NumberFormat(
                        '#,###',
                        'id_ID',
                      ).format(int.tryParse(clean) ?? 0);
                      _balanceController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Delete button (hanya saat edit)
            if (widget.showDelete) ...[
              GestureDetector(
                onTap: () => _showDeleteConfirm(context),
                child: Text(
                  'Delete Wallet',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            AppButton(
              label: widget.buttonLabel,
              isLoading: _isLoading,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Wallet', style: AppTextStyles.headingMedium),
        content: Text(
          'Are you sure you want to delete this wallet? This action cannot be undone.',
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
            onPressed: () {
              Navigator.pop(context); // close dialog
              _handleDelete();
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
