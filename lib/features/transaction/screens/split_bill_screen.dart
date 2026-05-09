import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harmoney/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/split_bill_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/split_bill_provider.dart';
import 'split_bill_result_screen.dart';

class SplitBillScreen extends ConsumerStatefulWidget {
  const SplitBillScreen({super.key});

  @override
  ConsumerState<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends ConsumerState<SplitBillScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splitBillProvider.notifier).reset();
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(splitBillProvider.notifier).initWithSelf(user.fullName);
      }
    });
  }

  @override
  void dispose() {
    ref.read(splitBillProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(splitBillProvider);
    final notifier = ref.read(splitBillProvider.notifier);

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
        title: Text('Split Bill', style: AppTextStyles.headingMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // --- Add Friend ---
            Text('Add Friend', style: AppTextStyles.labelLarge),
            const SizedBox(height: 16),
            _FriendsList(state: state, notifier: notifier),

            const SizedBox(height: 24),

            // --- Warning ---
            Row(
              children: [
                Icon(Icons.error, color: AppColors.warning, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please make sure the transaction data is correct!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- Items ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items', style: AppTextStyles.labelLarge),
                GestureDetector(
                  onTap: () => _showAddItemModal(context, ref),
                  child: Row(
                    children: [
                      Icon(Icons.add, color: AppColors.primary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Add Item',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (state.items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No items yet. Tap "+ Add Item" to start.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...state.items.map(
                (item) => _ItemCard(
                  item: item,
                  friends: state.friends,
                  onTap: () => _showManageItemModal(context, ref, item),
                ),
              ),

            const SizedBox(height: 28),

            // --- Upload & Scan ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.upload_rounded,
                      color: AppColors.textSecondary,
                    ),
                    label: Text(
                      'Upload Bill',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.document_scanner_rounded,
                      color: AppColors.textSecondary,
                    ),
                    label: Text(
                      'Scan Bill',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            AppButton(
              label: 'Split Now',
              onPressed: (state.friends.isEmpty || state.items.isEmpty)
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SplitBillResultScreen(state: state),
                      ),
                    ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showAddItemModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddItemModal(
        onAdd: (name, price, qty) =>
            ref.read(splitBillProvider.notifier).addItem(name, price, qty),
      ),
    );
  }

  void _showManageItemModal(
    BuildContext context,
    WidgetRef ref,
    SplitBillItem item,
  ) {
    final state = ref.read(splitBillProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManageItemModal(
        item: item,
        friends: state.friends,
        onSave: (name, price, qty, assignedIds) => ref
            .read(splitBillProvider.notifier)
            .updateItem(item.id, name, price, qty, assignedIds),
        onDelete: () =>
            ref.read(splitBillProvider.notifier).removeItem(item.id),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Friends List
// ─────────────────────────────────────────

class _FriendsList extends StatelessWidget {
  final SplitBillState state;
  final SplitBillNotifier notifier;

  const _FriendsList({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FriendAvatar(
            label: 'Add',
            initial: '+',
            isAddButton: true,
            onTap: () => _showAddFriendModal(context),
          ),
          const SizedBox(width: 12),
          ...state.friends.map(
            (friend) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _FriendAvatar(
                label: friend.id == 'self' ? 'You' : friend.name,
                initial: friend.name[0].toUpperCase(),
                isSelf: friend.id == 'self',
                onTap: () => _showEditFriendModal(context, friend),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddFriendModal(onAdd: notifier.addFriend),
    );
  }

  void _showEditFriendModal(BuildContext context, SplitBillFriend friend) {
    if (friend.id == 'self') return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditFriendModal(
        friend: friend,
        onSave: (name) => notifier.editFriend(friend.id, name),
        onDelete: () => notifier.removeFriend(friend.id),
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  final String label;
  final String initial;
  final bool isAddButton;
  final bool isSelf;
  final VoidCallback onTap;

  const _FriendAvatar({
    required this.label,
    required this.initial,
    required this.onTap,
    this.isAddButton = false,
    this.isSelf = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isAddButton
                      ? AppColors.primaryMuted
                      : AppColors.cardBackground,
                  shape: BoxShape.circle,
                  border: isAddButton
                      ? null
                      : Border.all(
                          color: isSelf ? AppColors.primary : AppColors.primary,
                          width: isSelf ? 2 : 1.5,
                        ),
                ),
                child: Center(
                  child: isAddButton
                      ? Icon(Icons.add, color: AppColors.primary)
                      : Text(
                          initial,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ),
              // Badge "You"
              if (isSelf)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: isSelf ? FontWeight.w700 : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Item Card
// ─────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final SplitBillItem item;
  final List<SplitBillFriend> friends;
  final VoidCallback onTap;

  const _ItemCard({
    required this.item,
    required this.friends,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final assignedFriends = friends
        .where((f) => item.assignedFriendIds.contains(f.id))
        .toList();
    final formatter = NumberFormat('#,###', 'id_ID');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.quantity}x  ${item.name}',
                    style: AppTextStyles.labelMedium,
                  ),
                  if (assignedFriends.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: assignedFriends
                          .map(
                            (f) => Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  f.name[0].toUpperCase(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              'Rp${formatter.format(item.totalPrice.toInt())}',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.expense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Add Friend Modal
// ─────────────────────────────────────────

class _AddFriendModal extends StatefulWidget {
  final void Function(String name) onAdd;
  const _AddFriendModal({required this.onAdd});

  @override
  State<_AddFriendModal> createState() => _AddFriendModalState();
}

class _AddFriendModalState extends State<_AddFriendModal> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ModalWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 4),
          _PersonIcon(initial: '+'),
          const SizedBox(height: 12),
          Text('Add Friend', style: AppTextStyles.headingMedium),
          const SizedBox(height: 24),
          _NameField(controller: _controller, maxLength: 10),
          const SizedBox(height: 24),
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (_, __, ___) => AppButton(
              label: 'Add',
              onPressed: _controller.text.trim().isEmpty
                  ? null
                  : () {
                      widget.onAdd(_controller.text);
                      Navigator.pop(context);
                    },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Edit Friend Modal
// ─────────────────────────────────────────

class _EditFriendModal extends StatefulWidget {
  final SplitBillFriend friend;
  final void Function(String name) onSave;
  final VoidCallback onDelete;

  const _EditFriendModal({
    required this.friend,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_EditFriendModal> createState() => _EditFriendModalState();
}

class _EditFriendModalState extends State<_EditFriendModal> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.friend.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ModalWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  widget.onDelete();
                  Navigator.pop(context);
                },
                child: Icon(Icons.delete_outline, color: AppColors.error),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _PersonIcon(initial: widget.friend.name[0].toUpperCase()),
          const SizedBox(height: 12),
          Text('Edit Friend', style: AppTextStyles.headingMedium),
          const SizedBox(height: 24),
          _NameField(controller: _controller, maxLength: 10),
          const SizedBox(height: 24),
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (_, __, ___) => AppButton(
              label: 'Save',
              onPressed: _controller.text.trim().isEmpty
                  ? null
                  : () {
                      widget.onSave(_controller.text);
                      Navigator.pop(context);
                    },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Add Item Modal
// ─────────────────────────────────────────

class _AddItemModal extends StatefulWidget {
  final void Function(String name, double price, int qty) onAdd;
  const _AddItemModal({required this.onAdd});

  @override
  State<_AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends State<_AddItemModal> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ModalWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Add Item', style: AppTextStyles.headingMedium),
          const SizedBox(height: 24),
          _ItemNameField(controller: _nameController),
          const SizedBox(height: 20),
          _PriceQtyRow(
            priceController: _priceController,
            qtyController: _qtyController,
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Add',
            onPressed: () {
              final name = _nameController.text.trim();
              final priceRaw = _priceController.text.replaceAll('.', '');
              final qty = int.tryParse(_qtyController.text) ?? 0;
              final price = double.tryParse(priceRaw) ?? 0;
              if (name.isEmpty || price <= 0 || qty <= 0) return;
              widget.onAdd(name, price, qty);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Manage Item Modal
// ─────────────────────────────────────────

class _ManageItemModal extends StatefulWidget {
  final SplitBillItem item;
  final List<SplitBillFriend> friends;
  final void Function(
    String name,
    double price,
    int qty,
    List<String> assignedIds,
  )
  onSave;
  final VoidCallback onDelete;

  const _ManageItemModal({
    required this.item,
    required this.friends,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_ManageItemModal> createState() => _ManageItemModalState();
}

class _ManageItemModalState extends State<_ManageItemModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _qtyController;
  late List<String> _assignedIds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(
      text: NumberFormat('#,###', 'id_ID').format(widget.item.price.toInt()),
    );
    _qtyController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _assignedIds = List.from(widget.item.assignedFriendIds);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ModalWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.onDelete();
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Manage Item', style: AppTextStyles.headingMedium),
          const SizedBox(height: 24),
          _ItemNameField(controller: _nameController),
          const SizedBox(height: 20),
          _PriceQtyRow(
            priceController: _priceController,
            qtyController: _qtyController,
          ),

          // Shared with
          if (widget.friends.isNotEmpty) ...[
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Shared with', style: AppTextStyles.labelLarge),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (_, setInner) => Column(
                children: widget.friends.map((friend) {
                  final isSelected = _assignedIds.contains(friend.id);
                  return GestureDetector(
                    onTap: () => setInner(() {
                      isSelected
                          ? _assignedIds.remove(friend.id)
                          : _assignedIds.add(friend.id);
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                          width: isSelected ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? AppColors.cardBackground.withOpacity(0.3)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.cardBackground
                                  : AppColors.divider,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                friend.name[0].toUpperCase(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(friend.name, style: AppTextStyles.bodyLarge),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 24),
          AppButton(
            label: 'Save',
            onPressed: () {
              final name = _nameController.text.trim();
              final priceRaw = _priceController.text.replaceAll('.', '');
              final qty = int.tryParse(_qtyController.text) ?? 0;
              final price = double.tryParse(priceRaw) ?? 0;
              if (name.isEmpty || price <= 0 || qty <= 0) return;
              widget.onSave(name, price, qty, _assignedIds);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Reusable small widgets
// ─────────────────────────────────────────

class _ModalWrapper extends StatelessWidget {
  final Widget child;
  const _ModalWrapper({required this.child});

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
        child: child,
      ),
    );
  }
}

class _PersonIcon extends StatelessWidget {
  final String initial;
  const _PersonIcon({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  const _NameField({required this.controller, required this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.primary)),
          ),
          child: TextField(
            controller: controller,
            maxLength: maxLength,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Add Name',
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textHint,
              ),
              border: InputBorder.none,
              counterText: '',
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, __) => Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${value.text.length}/$maxLength',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemNameField extends StatelessWidget {
  final TextEditingController controller;
  const _ItemNameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Item Name', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.primary)),
          ),
          child: TextField(
            controller: controller,
            maxLength: 20,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Add Item Name',
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textHint,
              ),
              border: InputBorder.none,
              counterText: '',
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, __) => Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${value.text.length}/20',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceQtyRow extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController qtyController;

  const _PriceQtyRow({
    required this.priceController,
    required this.qtyController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.primary)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Rp',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Add Nominal',
                          hintStyle: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textHint,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          final clean = value.replaceAll('.', '');
                          if (clean.isEmpty) return;
                          final formatted = NumberFormat(
                            '#,###',
                            'id_ID',
                          ).format(int.tryParse(clean) ?? 0);
                          priceController.value = TextEditingValue(
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
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quantity', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.primary)),
                ),
                child: TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Add Quantity',
                    hintStyle: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
