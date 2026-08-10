import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_provider.dart';

void main() {
  // Asegurar la inicialización de bindings de Flutter antes de bases de datos
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // ProviderScope es necesario para usar Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const textTheme = TextTheme();
    final materialTheme = MaterialTheme(textTheme);
    
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Gestor Gastos',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
