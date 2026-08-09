import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> getSavedUser();
  Future<User> saveUser(String username);
}
