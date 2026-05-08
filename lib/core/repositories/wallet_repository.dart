import '../models/wallet_model.dart';

abstract class WalletRepository {
  Future<List<WalletModel>> getWallets(String userId);
  Future<WalletModel> addWallet(WalletModel wallet);
  Future<WalletModel> updateWallet(WalletModel wallet);
  Future<void> deleteWallet(String walletId);
  Future<double> getTotalBalance(String userId);
}
