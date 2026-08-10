import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

class PinNotifier extends AsyncNotifier<String?> {
  static const _pinKey = 'user_pin';

  @override
  Future<String?> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return prefs.getString(_pinKey);
  }

  Future<void> setPin(String pin) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_pinKey, pin);
    state = AsyncData(pin);
  }

  Future<void> removePin() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.remove(_pinKey);
    state = const AsyncData(null);
  }
}

final pinProvider = AsyncNotifierProvider<PinNotifier, String?>(() {
  return PinNotifier();
});
