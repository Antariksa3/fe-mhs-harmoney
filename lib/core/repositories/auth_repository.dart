import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  });
}
