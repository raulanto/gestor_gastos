import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _themeModeKey = 'themeMode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedMode = prefs.getString(_themeModeKey);
    if (savedMode != null) {
      return ThemeMode.values.firstWhere(
        (e) => e.toString() == savedMode,
        orElse: () => ThemeMode.system,
      );
    }
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    ref.read(sharedPreferencesProvider).setString(_themeModeKey, mode.toString());
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ColorSchemeNotifier extends Notifier<String> {
  static const _colorSchemeKey = 'colorScheme';

  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_colorSchemeKey) ?? 'original';
  }

  void setScheme(String schemeName) {
    state = schemeName;
    ref.read(sharedPreferencesProvider).setString(_colorSchemeKey, schemeName);
  }
}

final colorSchemeProvider = NotifierProvider<ColorSchemeNotifier, String>(() {
  return ColorSchemeNotifier();
});

class AppBackgroundNotifier extends Notifier<String> {
  static const _bgKey = 'app_background';

  static const availableBackgrounds = [
    'assets/images/home_bg.jpg',
    'assets/images/bg1.jpg',
    'assets/images/bg2.jpg',
    'assets/images/bg3.jpg',
    'assets/images/bg4.jpg',
    'assets/images/bg5.jpg',
    'assets/images/bg6.jpg',
  ];

  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_bgKey) ?? 'assets/images/home_bg.jpg';
  }

  void nextBackground() {
    int currentIndex = availableBackgrounds.indexOf(state);
    if (currentIndex == -1) currentIndex = 0;
    int nextIndex = (currentIndex + 1) % availableBackgrounds.length;
    final newBg = availableBackgrounds[nextIndex];
    state = newBg;
    ref.read(sharedPreferencesProvider).setString(_bgKey, newBg);
  }

  void previousBackground() {
    int currentIndex = availableBackgrounds.indexOf(state);
    if (currentIndex == -1) currentIndex = 0;
    int prevIndex = (currentIndex - 1 + availableBackgrounds.length) % availableBackgrounds.length;
    final newBg = availableBackgrounds[prevIndex];
    state = newBg;
    ref.read(sharedPreferencesProvider).setString(_bgKey, newBg);
  }
}

final appBackgroundProvider = NotifierProvider<AppBackgroundNotifier, String>(() {
  return AppBackgroundNotifier();
});
