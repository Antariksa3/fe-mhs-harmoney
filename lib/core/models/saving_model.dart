class SavingModel {
  final String id;
  final String userId;
  final String walletId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final String? iconPath;

  const SavingModel({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.endDate,
    this.iconPath,
  });

  double get progressPercentage =>
      (currentAmount / targetAmount * 100).clamp(0, 100);

  int get daysLeft => endDate.difference(DateTime.now()).inDays;

  factory SavingModel.fromJson(Map<String, dynamic> json) => SavingModel(
    id: json['id'],
    userId: json['userId'],
    walletId: json['walletId'],
    name: json['name'],
    targetAmount: (json['targetAmount'] as num).toDouble(),
    currentAmount: (json['currentAmount'] as num).toDouble(),
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    iconPath: json['iconPath'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'walletId': walletId,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'iconPath': iconPath,
  };
}
