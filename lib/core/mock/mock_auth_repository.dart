import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  static final _mockUser = UserModel(
    id: 'user-001',
    fullName: 'Ansel Setiawan',
    email: 'anselsetiawan@gmail.com',
    phoneNumber: '081211223344',
  );

  UserModel? _currentUser;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email == 'anselsetiawan@gmail.com' && password == 'Password1!') {
      _currentUser = _mockUser;
      return _mockUser;
    }
    throw Exception('Invalid email or password');
  }

  @override
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      id: const Uuid().v4(),
      fullName: fullName,
      email: email,
    );
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (currentPassword != 'Password1!') {
      throw Exception('Current password is incorrect');
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = _currentUser!.copyWith(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
    );
    return _currentUser!;
  }
}
