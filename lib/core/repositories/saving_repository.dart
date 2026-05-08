import '../models/saving_model.dart';

abstract class SavingRepository {
  Future<List<SavingModel>> getSavings(String userId);
  Future<SavingModel> addSaving(SavingModel saving);
  Future<SavingModel> updateSaving(SavingModel saving);
  Future<void> deleteSaving(String savingId);
}
