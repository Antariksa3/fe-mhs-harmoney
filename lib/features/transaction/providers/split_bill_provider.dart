import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/split_bill_model.dart';

class SplitBillNotifier extends StateNotifier<SplitBillState> {
  SplitBillNotifier() : super(const SplitBillState());

  void initWithSelf(String userName) {
    if (state.friends.any((f) => f.id == 'self')) return;
    final me = SplitBillFriend(id: 'self', name: userName);
    state = state.copyWith(friends: [me, ...state.friends]);
  }

  // --- Friends ---
  void addFriend(String name) {
    final friend = SplitBillFriend(id: const Uuid().v4(), name: name.trim());
    state = state.copyWith(friends: [...state.friends, friend]);
  }

  void editFriend(String friendId, String newName) {
    state = state.copyWith(
      friends: state.friends
          .map((f) => f.id == friendId ? f.copyWith(name: newName.trim()) : f)
          .toList(),
    );
  }

  void removeFriend(String friendId) {
    // Hapus friend juga dari semua item yang assign ke dia
    final updatedItems = state.items.map((item) {
      return item.copyWith(
        assignedFriendIds: item.assignedFriendIds
            .where((id) => id != friendId)
            .toList(),
      );
    }).toList();

    state = state.copyWith(
      friends: state.friends.where((f) => f.id != friendId).toList(),
      items: updatedItems,
    );
  }

  // --- Items ---
  void addItem(String name, double price, int quantity) {
    final item = SplitBillItem(
      id: const Uuid().v4(),
      name: name.trim(),
      price: price,
      quantity: quantity,
      assignedFriendIds: const [],
    );
    state = state.copyWith(items: [...state.items, item]);
  }

  void updateItem(
    String itemId,
    String name,
    double price,
    int quantity,
    List<String> assignedFriendIds,
  ) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id != itemId) return item;
        return item.copyWith(
          name: name.trim(),
          price: price,
          quantity: quantity,
          assignedFriendIds: assignedFriendIds,
        );
      }).toList(),
    );
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != itemId).toList(),
    );
  }

  void reset() => state = const SplitBillState();
}

final splitBillProvider =
    StateNotifierProvider.autoDispose<SplitBillNotifier, SplitBillState>(
      (ref) => SplitBillNotifier(),
    );
