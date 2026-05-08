import 'package:uuid/uuid.dart';
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';

class MockWalletRepository implements WalletRepository {
  final List<WalletModel> _wallets = [
    WalletModel(
      id: 'wallet-001',
      userId: 'user-001',
      name: 'Cash',
      balance: 100000,
    ),
    WalletModel(
      id: 'wallet-002',
      userId: 'user-001',
      name: 'BCA',
      balance: 120000,
    ),
    WalletModel(
      id: 'wallet-003',
      userId: 'user-001',
      name: 'Gopay',
      balance: 10000,
    ),
  ];

  @override
  Future<List<WalletModel>> getWallets(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _wallets.where((w) => w.userId == userId).toList();
  }

  @override
  Future<WalletModel> addWallet(WalletModel wallet) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newWallet = WalletModel(
      id: const Uuid().v4(),
      userId: wallet.userId,
      name: wallet.name,
      balance: wallet.balance,
    );
    _wallets.add(newWallet);
    return newWallet;
  }

  @override
  Future<WalletModel> updateWallet(WalletModel wallet) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _wallets.indexWhere((w) => w.id == wallet.id);
    if (index == -1) throw Exception('Wallet not found');
    _wallets[index] = wallet;
    return wallet;
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _wallets.removeWhere((w) => w.id == walletId);
  }

  @override
  Future<double> getTotalBalance(String userId) async {
    final wallets = await getWallets(userId);
    return wallets.fold<double>(0.0, (sum, w) => sum + w.balance);
  }
}
