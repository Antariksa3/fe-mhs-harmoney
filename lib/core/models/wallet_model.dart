class WalletModel {
  final String id;
  final String userId;
  final String name;
  final double balance;
  final String? iconPath;

  const WalletModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.balance,
    this.iconPath,
  });

  WalletModel copyWith({String? name, double? balance, String? iconPath}) {
    return WalletModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      iconPath: iconPath ?? this.iconPath,
    );
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    id: json['id'],
    userId: json['userId'],
    name: json['name'],
    balance: (json['balance'] as num).toDouble(),
    iconPath: json['iconPath'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'balance': balance,
    'iconPath': iconPath,
  };
}
