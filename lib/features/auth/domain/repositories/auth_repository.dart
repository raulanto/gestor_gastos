import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> getSavedUser();
  Future<User> saveUser(String username);
  Future<User> updateProfile(int id, String username, String? photoPath);
}
