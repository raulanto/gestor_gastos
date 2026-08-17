import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'core/routing/app_router.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/notifications/notification_service.dart';
import 'core/home_widget/home_widget_data_provider.dart';
import 'core/home_widget/home_widget_service.dart';
import 'package:workmanager/workmanager.dart';
import 'core/background/background_task_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  Workmanager().initialize(callbackDispatcher);

  Workmanager().registerPeriodicTask(
    "daily_check_task",
    "dailyTask",
    frequency: const Duration(hours: 24),
    initialDelay: const Duration(minutes: 15),
  );

  runApp(
    // ProviderScope es necesario para usar Riverpod
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const MyApp(),
    ),
  );
}

/// Resuelve el color primario del tema claro para el [colorSchemeName] dado,
/// sin construir el [ThemeData] completo. Se usa para mantener el widget de
/// balance general sincronizado con el mismo color que ve el usuario en la
/// app, incluso cuando el cambio de tema ocurre sin nuevos datos financieros.
Color _resolvePrimaryColor(String colorSchemeName) {
  if (colorSchemeName == 'original') {
    const textTheme = TextTheme();
    return MaterialTheme(textTheme).light().colorScheme.primary;
  }
  final scheme = FlexScheme.values.firstWhere(
    (e) => e.toString() == colorSchemeName,
    orElse: () => FlexScheme.materialBaseline,
  );
  return FlexThemeData.light(
    scheme: scheme,
    useMaterial3: true,
    fontFamily: 'SFProRounded',
  ).colorScheme.primary;
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ProviderSubscription<AsyncValue<HomeWidgetSnapshotData>>?
  _homeWidgetSubscription;

  @override
  void initState() {
    super.initState();
    _homeWidgetSubscription =
        ref.listenManual<AsyncValue<HomeWidgetSnapshotData>>(
          homeWidgetSnapshotDataProvider,
          (previous, next) {
            next.whenData((data) {
              HomeWidgetService.updateSnapshot(
                backgroundAsset: data.backgroundAsset,
                primaryColor: _resolvePrimaryColor(data.colorSchemeName),
                balance: data.balance,
                income: data.income,
                expense: data.expense,
              );
            });
          },
          fireImmediately: true,
        );
  }

  @override
  void dispose() {
    _homeWidgetSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      lightTheme = FlexThemeData.light(
        scheme: scheme,
        useMaterial3: true,
        fontFamily: 'SFProRounded',
      );
      darkTheme = FlexThemeData.dark(
        scheme: scheme,
        useMaterial3: true,
        fontFamily: 'SFProRounded',
      );
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
