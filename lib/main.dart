import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'core/routing/app_router.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  // Asegurar la inicialización de bindings de Flutter antes de bases de datos
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();

  runApp(
    // ProviderScope es necesario para usar Riverpod
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final colorSchemeName = ref.watch(colorSchemeProvider);

    ThemeData lightTheme;
    ThemeData darkTheme;

    if (colorSchemeName == 'original') {
      const textTheme = TextTheme();
      final materialTheme = MaterialTheme(textTheme);
      lightTheme = materialTheme.light();
      darkTheme = materialTheme.dark();
    } else {
      final scheme = FlexScheme.values.firstWhere(
        (e) => e.toString() == colorSchemeName,
        orElse: () => FlexScheme.materialBaseline,
      );
      lightTheme = FlexThemeData.light(scheme: scheme, useMaterial3: true);
      darkTheme = FlexThemeData.dark(scheme: scheme, useMaterial3: true);
    }

    return MaterialApp.router(
      title: 'Gestor Gastos',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
