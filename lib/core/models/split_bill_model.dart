class SplitBillFriend {
  final String id;
  final String name;

  const SplitBillFriend({required this.id, required this.name});

  SplitBillFriend copyWith({String? name}) =>
      SplitBillFriend(id: id, name: name ?? this.name);
}

class SplitBillItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final List<String> assignedFriendIds;

  const SplitBillItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.assignedFriendIds,
  });

  double get totalPrice => price * quantity;

  double get pricePerPerson =>
      assignedFriendIds.isEmpty ? 0 : totalPrice / assignedFriendIds.length;

  SplitBillItem copyWith({
    String? name,
    double? price,
    int? quantity,
    List<String>? assignedFriendIds,
  }) => SplitBillItem(
    id: id,
    name: name ?? this.name,
    price: price ?? this.price,
    quantity: quantity ?? this.quantity,
    assignedFriendIds: assignedFriendIds ?? this.assignedFriendIds,
  );
}

class SplitBillState {
  final List<SplitBillFriend> friends;
  final List<SplitBillItem> items;

  const SplitBillState({this.friends = const [], this.items = const []});

  SplitBillState copyWith({
    List<SplitBillFriend>? friends,
    List<SplitBillItem>? items,
  }) => SplitBillState(
    friends: friends ?? this.friends,
    items: items ?? this.items,
  );

  // Total tagihan per friend
  Map<String, double> get totalsPerFriend {
    final totals = {for (final f in friends) f.id: 0.0};
    for (final item in items) {
      if (item.assignedFriendIds.isEmpty) continue;
      for (final friendId in item.assignedFriendIds) {
        totals[friendId] = (totals[friendId] ?? 0) + item.pricePerPerson;
      }
    }
    return totals;
  }

  // Items beserta share harga untuk 1 friend
  List<MapEntry<SplitBillItem, double>> getItemsForFriend(String friendId) {
    return items
        .where((item) => item.assignedFriendIds.contains(friendId))
        .map((item) => MapEntry(item, item.pricePerPerson))
        .toList();
  }
}
