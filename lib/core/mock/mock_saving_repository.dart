import 'package:uuid/uuid.dart';
import '../models/saving_model.dart';
import '../repositories/saving_repository.dart';

class MockSavingRepository implements SavingRepository {
  final List<SavingModel> _savings = [
    SavingModel(
      id: 'saving-001',
      userId: 'user-001',
      walletId: 'wallet-002',
      name: 'Iphone 17 Pro Max',
      targetAmount: 20500000,
      currentAmount: 18500000,
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 3, 22),
    ),
    SavingModel(
      id: 'saving-002',
      userId: 'user-001',
      walletId: 'wallet-001',
      name: 'Liburan Bali',
      targetAmount: 5000000,
      currentAmount: 2000000,
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 6, 30),
    ),
  ];

  @override
  Future<List<SavingModel>> getSavings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _savings.where((s) => s.userId == userId).toList();
  }

  @override
  Future<SavingModel> addSaving(SavingModel saving) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newSaving = SavingModel(
      id: const Uuid().v4(),
      userId: saving.userId,
      walletId: saving.walletId,
      name: saving.name,
      targetAmount: saving.targetAmount,
      currentAmount: saving.currentAmount,
      startDate: saving.startDate,
      endDate: saving.endDate,
    );
    _savings.add(newSaving);
    return newSaving;
  }

  @override
  Future<SavingModel> updateSaving(SavingModel saving) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _savings.indexWhere((s) => s.id == saving.id);
    if (index == -1) throw Exception('Saving not found');
    _savings[index] = saving;
    return saving;
  }

  @override
  Future<void> deleteSaving(String savingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _savings.removeWhere((s) => s.id == savingId);
  }
}
