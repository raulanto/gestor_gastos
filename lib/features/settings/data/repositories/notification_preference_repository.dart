import '../../../../core/database/app_database.dart';
import '../../domain/entities/notification_preference.dart';

class NotificationPreferenceRepository {
  final AppDatabase appDb;

  NotificationPreferenceRepository(this.appDb);

  Future<List<NotificationPreference>> getPreferences() async {
    final db = await appDb.database;
    final maps = await db.query('notification_preferences');
    
    // Create default preferences if they don't exist
    if (maps.isEmpty) {
      await _initializeDefaultPreferences();
      final newMaps = await db.query('notification_preferences');
      return newMaps.map((m) => NotificationPreference.fromMap(m)).toList();
    }
    
    return maps.map((m) => NotificationPreference.fromMap(m)).toList();
  }

  Future<NotificationPreference?> getPreference(String type) async {
    final db = await appDb.database;
    final maps = await db.query(
      'notification_preferences',
      where: 'type = ?',
      whereArgs: [type],
    );
    if (maps.isNotEmpty) {
      return NotificationPreference.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updatePreference(NotificationPreference pref) async {
    final db = await appDb.database;
    
    final existing = await getPreference(pref.type);
    if (existing != null) {
      await db.update(
        'notification_preferences',
        pref.toMap(),
        where: 'type = ?',
        whereArgs: [pref.type],
      );
    } else {
      await db.insert('notification_preferences', pref.toMap());
    }
  }

  Future<void> _initializeDefaultPreferences() async {
    final defaults = [
      NotificationPreference(type: 'budget', isEnabled: true),
      NotificationPreference(type: 'savings', isEnabled: true),
      NotificationPreference(type: 'recurring', isEnabled: true),
      NotificationPreference(type: 'daily_reminder', isEnabled: false, timeOfDay: '20:00'),
      NotificationPreference(type: 'summary', isEnabled: true, timeOfDay: '09:00'),
    ];

    final db = await appDb.database;
    await db.transaction((txn) async {
      for (var pref in defaults) {
        await txn.insert('notification_preferences', pref.toMap());
      }
    });
  }
}
