import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._localDataSource);

  @override
  Future<User?> getSavedUser() async {
    return await _localDataSource.getUser();
  }

  @override
  Future<User> saveUser(String username) async {
    return await _localDataSource.saveUser(username);
  }
}
