import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import '../../../../../core/theme/theme_provider.dart';
import 'theme_mode_selector.dart';


class SettingsThemeCard extends ConsumerWidget {
  const SettingsThemeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = ref.watch(colorSchemeProvider);
    final theme = Theme.of(context);

    // Paleta curada de esquemas de color
    final List<Map<String, dynamic>> predefinedSchemes = [
      {'name': 'Original', 'scheme': 'original', 'color': const Color(0xff415f91)},
      {'name': 'Predeterminado', 'scheme': FlexScheme.materialBaseline.toString(), 'color': FlexColor.materialBaselineLightPrimary},
      {'name': 'Índigo', 'scheme': FlexScheme.indigo.toString(), 'color': FlexColor.indigoLightPrimary},
      {'name': 'Verde', 'scheme': FlexScheme.green.toString(), 'color': FlexColor.greenLightPrimary},
      {'name': 'Rosa', 'scheme': FlexScheme.sakura.toString(), 'color': FlexColor.sakuraLightPrimary},
      {'name': 'Naranja', 'scheme': FlexScheme.mango.toString(), 'color': FlexColor.mangoLightPrimary},
      {'name': 'Rojo', 'scheme': FlexScheme.mandyRed.toString(), 'color': FlexColor.mandyRedLightPrimary},
      {'name': 'Aqua', 'scheme': FlexScheme.aquaBlue.toString(), 'color': FlexColor.aquaBlueLightPrimary},
      {'name': 'Azul Profundo', 'scheme': FlexScheme.deepBlue.toString(), 'color': FlexColor.deepBlueLightPrimary},
      {'name': 'Berenjena', 'scheme': FlexScheme.ebonyClay.toString(), 'color': FlexColor.ebonyClayLightPrimary},
      {'name': 'Oro', 'scheme': FlexScheme.gold.toString(), 'color': FlexColor.goldLightPrimary},
      {'name': 'Wasabi', 'scheme': FlexScheme.wasabi.toString(), 'color': FlexColor.wasabiLightPrimary},
      {'name': 'Tiburón', 'scheme': FlexScheme.shark.toString(), 'color': FlexColor.sharkLightPrimary},
      {'name': 'Expreso', 'scheme': FlexScheme.espresso.toString(), 'color': FlexColor.espressoLightPrimary},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apariencia',
          style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.brightness_6, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 16),
                    Text(
                      'Modo',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ThemeModeSelector(
                    currentMode: themeMode,
                    onChanged: (newMode) {
                      ref.read(themeModeProvider.notifier).setThemeMode(newMode);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(Icons.color_lens, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 16),
                    Text(
                      'Color',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: predefinedSchemes.length,
                    itemBuilder: (context, index) {
                      final item = predefinedSchemes[index];
                      final isSelected = colorScheme == item['scheme'];
                      final color = item['color'] as Color;

                      return GestureDetector(
                        onTap: () {
                          ref.read(colorSchemeProvider.notifier).setScheme(item['scheme'] as String);
                        },
                        child: Container(
                          width: 50,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.onSurface : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                            ],
                          ),
                          child: isSelected
                              ? Icon(Icons.check, color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
