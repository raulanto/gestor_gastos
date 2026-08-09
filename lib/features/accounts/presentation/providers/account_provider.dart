import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/account_local_data_source.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

final accountLocalDataSourceProvider = Provider<AccountLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AccountLocalDataSource(db);
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final localDataSource = ref.watch(accountLocalDataSourceProvider);
  return AccountRepositoryImpl(localDataSource);
});

final accountsProvider = AsyncNotifierProvider<AccountsNotifier, List<Account>>(() {
  return AccountsNotifier();
});

class AccountsNotifier extends AsyncNotifier<List<Account>> {
  late AccountRepository _repository;

  @override
  FutureOr<List<Account>> build() async {
    _repository = ref.watch(accountRepositoryProvider);
    return await _repository.getAccounts();
  }

  Future<void> loadAccounts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _repository.getAccounts();
    });
  }

  Future<void> addAccount(Account account) async {
    await _repository.createAccount(account);
    await loadAccounts();
  }

  Future<void> updateAccount(Account account) async {
    await _repository.updateAccount(account);
    await loadAccounts();
  }

  Future<void> deleteAccount(int id) async {
    await _repository.deleteAccount(id);
    await loadAccounts();
  }
}
