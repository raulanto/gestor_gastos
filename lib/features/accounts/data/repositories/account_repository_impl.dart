import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountLocalDataSource _localDataSource;

  AccountRepositoryImpl(this._localDataSource);

  @override
  Future<List<Account>> getAccounts() async {
    return await _localDataSource.getAccounts();
  }

  @override
  Future<Account> createAccount(Account account) async {
    return await _localDataSource.createAccount(account);
  }

  @override
  Future<void> updateAccount(Account account) async {
    return await _localDataSource.updateAccount(account);
  }

  @override
  Future<void> deleteAccount(int id) async {
    return await _localDataSource.deleteAccount(id);
  }
}
