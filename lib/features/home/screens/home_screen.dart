import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harmoney/features/transaction/screens/split_bill_screen.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/transaction_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/screens/settings_screen.dart';
import '../../transaction/screens/transaction_screen.dart';
import '../../savings/screens/saving_screen.dart';
import '../../report/screens/report_screen.dart';
import '../../transaction/screens/create_transaction_screen.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomeContent(),
    TransactionScreen(),
    SavingScreen(),
    ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionTypeModal(context),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            index: 0,
            currentIndex: _currentIndex,
            onTap: () => setState(() => _currentIndex = 0),
          ),
          _NavItem(
            icon: Icons.receipt_long_rounded,
            label: 'Transactions',
            index: 1,
            currentIndex: _currentIndex,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          const SizedBox(width: 48), // space for FAB
          _NavItem(
            icon: Icons.savings_rounded,
            label: 'Savings',
            index: 2,
            currentIndex: _currentIndex,
            onTap: () => setState(() => _currentIndex = 2),
          ),
          _NavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Report',
            index: 3,
            currentIndex: _currentIndex,
            onTap: () => setState(() => _currentIndex = 3),
          ),
        ],
      ),
    );
  }

  void _showTransactionTypeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TransactionTypeModal(),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.textHint,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isActive ? AppColors.primary : AppColors.textHint,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// Modal pilih tipe transaksi
class _TransactionTypeModal extends StatelessWidget {
  const _TransactionTypeModal();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Make Transaction', style: AppTextStyles.headingMedium),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _TransactionTypeItem(
            label: 'Expense',
            icon: Icons.arrow_upward_rounded,
            color: AppColors.expense,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CreateTransactionScreen(type: 'expense'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _TransactionTypeItem(
            label: 'Income',
            icon: Icons.arrow_downward_rounded,
            color: AppColors.income,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateTransactionScreen(type: 'income'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _TransactionTypeItem(
            label: 'Transfer',
            icon: Icons.arrow_forward_rounded,
            color: AppColors.transfer,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CreateTransactionScreen(type: 'transfer'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _TransactionTypeItem(
            label: 'Split Bill',
            icon: Icons.receipt_rounded,
            color: AppColors.splitBill,
            onTap: () {
              Navigator.pop(context); // tutup modal dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SplitBillScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TransactionTypeItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TransactionTypeItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.labelLarge.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

// Home content (tab pertama)
class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final wallets = ref.watch(walletsProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final totalSavings = ref.watch(totalSavingsProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);
    final savings = ref.watch(savingsProvider);
    final isVisible = ref.watch(balanceVisibleProvider);

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Top bar
            Row(
              children: [
                // Avatar + name
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.cardBackground,
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'User',
                        style: AppTextStyles.labelLarge,
                      ),
                      Text(user?.email ?? '', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                // Settings icon
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total expense header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total expenses for ${DateFormat('MMMM').format(DateTime.now())}',
                        style: AppTextStyles.bodySmall,
                      ),
                      GestureDetector(
                        onTap: () => ref
                            .read(balanceVisibleProvider.notifier)
                            .update((s) => !s),
                        child: Icon(
                          isVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Total expense amount
                  Text(
                    isVisible
                        ? currencyFormat.format(totalExpense)
                        : 'Rp ******',
                    style: AppTextStyles.amountLarge,
                  ),

                  const SizedBox(height: 4),

                  // Badge persentase
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 12,
                          color: AppColors.expense,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '12% Last Week',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.expense,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Total Balance',
                        value: isVisible
                            ? currencyFormat.format(totalBalance)
                            : 'Rp ******',
                      ),
                      _StatItem(
                        icon: Icons.savings_rounded,
                        label: 'Savings',
                        value: isVisible
                            ? currencyFormat.format(totalSavings)
                            : 'Rp ******',
                      ),
                      wallets.when(
                        data: (list) => _StatItem(
                          icon: Icons.wallet_rounded,
                          label: 'Your Wallet',
                          value: '${list.length} Wallet',
                        ),
                        loading: () => _StatItem(
                          icon: Icons.wallet_rounded,
                          label: 'Your Wallet',
                          value: '...',
                        ),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Saving Goals section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saving Goals', style: AppTextStyles.headingMedium),
                Text(
                  'Detail',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            savings.when(
              data: (list) => list.isEmpty
                  ? _EmptyState(message: 'No saving goals yet')
                  : Column(
                      children: list
                          .take(2)
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _SavingGoalCard(saving: s),
                            ),
                          )
                          .toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),

            const SizedBox(height: 24),

            // Recent Transactions section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transaction', style: AppTextStyles.headingMedium),
                Text(
                  'Detail',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            recentTransactions.isEmpty
                ? _EmptyState(message: 'No transactions yet')
                : Column(
                    children: recentTransactions
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TransactionCard(transaction: t),
                          ),
                        )
                        .toList(),
                  ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// Stat item widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.labelMedium,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// Saving goal card
class _SavingGoalCard extends StatelessWidget {
  final saving;

  const _SavingGoalCard({required this.saving});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.savings_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(saving.name, style: AppTextStyles.labelMedium),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${saving.daysLeft} Days Left',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    '${saving.progressPercentage.toStringAsFixed(0)}%',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: saving.progressPercentage / 100,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currencyFormat.format(saving.currentAmount),
                style: AppTextStyles.bodySmall,
              ),
              Text(
                currencyFormat.format(saving.targetAmount),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Transaction card
class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final isExpense = transaction.type == TransactionType.expense;
    final isIncome = transaction.type == TransactionType.income;

    final color = isExpense
        ? AppColors.expense
        : isIncome
        ? AppColors.income
        : AppColors.transfer;

    final prefix = isExpense
        ? '- '
        : isIncome
        ? '+ '
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpense
                  ? Icons.arrow_upward_rounded
                  : isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_forward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Transaction',
                  style: AppTextStyles.labelMedium,
                ),
                Text(
                  DateFormat('MMMM dd, yyyy').format(transaction.date),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '$prefix${currencyFormat.format(transaction.amount)}',
            style: AppTextStyles.labelMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, style: AppTextStyles.bodyMedium),
      ),
    );
  }
}
