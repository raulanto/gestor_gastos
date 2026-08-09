import '../entities/account.dart';

abstract class AccountRepository {
  Future<List<Account>> getAccounts();
  Future<Account> createAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(int id);
}
