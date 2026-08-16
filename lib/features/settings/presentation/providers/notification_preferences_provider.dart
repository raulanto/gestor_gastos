import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/notification_preference.dart';
import '../../data/repositories/notification_preference_repository.dart';

final notificationPreferenceRepositoryProvider =
    Provider<NotificationPreferenceRepository>((ref) {
      final db = ref.watch(appDatabaseProvider);
      return NotificationPreferenceRepository(db);
    });

final notificationPreferencesProvider =
    FutureProvider<List<NotificationPreference>>((ref) async {
      final repo = ref.watch(notificationPreferenceRepositoryProvider);
      return await repo.getPreferences();
    });

final notificationPreferenceNotifierProvider =
    AsyncNotifierProvider<
      NotificationPreferenceNotifier,
      List<NotificationPreference>
    >(() {
      return NotificationPreferenceNotifier();
    });

class NotificationPreferenceNotifier
    extends AsyncNotifier<List<NotificationPreference>> {
  @override
  Future<List<NotificationPreference>> build() async {
    final repo = ref.watch(notificationPreferenceRepositoryProvider);
    return await repo.getPreferences();
  }

  Future<void> updatePreference(NotificationPreference pref) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(notificationPreferenceRepositoryProvider);
      await repo.updatePreference(pref);
      return await repo.getPreferences();
    });
  }
}
