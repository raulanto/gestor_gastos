import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

// Providers de inyección de dependencias
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AuthLocalDataSource(db);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(localDataSource);
});

// Provider de Estado (Notifier)
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<User?> {
  late AuthRepository _repository;

  @override
  FutureOr<User?> build() async {
    _repository = ref.watch(authRepositoryProvider);
    return await _repository.getSavedUser();
  }

  Future<void> login(String username) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _repository.saveUser(username);
    });
  }
}
