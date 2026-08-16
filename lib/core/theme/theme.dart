import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff415f91),
      surfaceTint: Color(0xff415f91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd6e3ff),
      onPrimaryContainer: Color(0xff284777),
      secondary: Color(0xff565f71),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffdae2f9),
      onSecondaryContainer: Color(0xff3e4759),
      tertiary: Color(0xff705575),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfffad8fd),
      onTertiaryContainer: Color(0xff573e5c),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff191c20),
      onSurfaceVariant: Color(0xff44474e),
      outline: Color(0xff74777f),
      outlineVariant: Color(0xffc4c6d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff001b3e),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff284777),
      secondaryFixed: Color(0xffdae2f9),
      onSecondaryFixed: Color(0xff131c2b),
      secondaryFixedDim: Color(0xffbec6dc),
      onSecondaryFixedVariant: Color(0xff3e4759),
      tertiaryFixed: Color(0xfffad8fd),
      onTertiaryFixed: Color(0xff28132e),
      tertiaryFixedDim: Color(0xffddbce0),
      onTertiaryFixedVariant: Color(0xff573e5c),
      surfaceDim: Color(0xffd9d9e0),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffededf4),
      surfaceContainerHigh: Color(0xffe7e8ee),
      surfaceContainerHighest: Color(0xffe2e2e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff133665),
      surfaceTint: Color(0xff415f91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff506da0),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff2e3647),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff646d80),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff452e4a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff7f6484),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff0f1116),
      onSurfaceVariant: Color(0xff33363e),
      outline: Color(0xff4f525a),
      outlineVariant: Color(0xff6a6d75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xff506da0),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff375586),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff646d80),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff4c5567),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff7f6484),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff654c6b),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc5c6cd),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffe7e8ee),
      surfaceContainerHigh: Color(0xffdcdce3),
      surfaceContainerHighest: Color(0xffd1d1d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff032b5b),
      surfaceTint: Color(0xff415f91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff2a497a),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff232c3d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff41495b),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3a2440),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff59405e),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff292c33),
      outlineVariant: Color(0xff464951),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xff2a497a),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff0e3262),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff41495b),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff2a3344),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff59405e),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff412a47),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb8b8bf),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f0f7),
      surfaceContainer: Color(0xffe2e2e9),
      surfaceContainerHigh: Color(0xffd3d4db),
      surfaceContainerHighest: Color(0xffc5c6cd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffaac7ff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff0a305f),
      primaryContainer: Color(0xff284777),
      onPrimaryContainer: Color(0xffd6e3ff),
      secondary: Color(0xffbec6dc),
      onSecondary: Color(0xff283141),
      secondaryContainer: Color(0xff3e4759),
      onSecondaryContainer: Color(0xffdae2f9),
      tertiary: Color(0xffddbce0),
      onTertiary: Color(0xff3f2844),
      tertiaryContainer: Color(0xff573e5c),
      onTertiaryContainer: Color(0xfffad8fd),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff111318),
      onSurface: Color(0xffe2e2e9),
      onSurfaceVariant: Color(0xffc4c6d0),
      outline: Color(0xff8e9099),
      outlineVariant: Color(0xff44474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff415f91),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff001b3e),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff284777),
      secondaryFixed: Color(0xffdae2f9),
      onSecondaryFixed: Color(0xff131c2b),
      secondaryFixedDim: Color(0xffbec6dc),
      onSecondaryFixedVariant: Color(0xff3e4759),
      tertiaryFixed: Color(0xfffad8fd),
      onTertiaryFixed: Color(0xff28132e),
      tertiaryFixedDim: Color(0xffddbce0),
      onTertiaryFixedVariant: Color(0xff573e5c),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff191c20),
      surfaceContainer: Color(0xff1d2024),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff33353a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffaac7ff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff0a305f),
      primaryContainer: Color(0xff284777),
      onPrimaryContainer: Color(0xffd6e3ff),
      secondary: Color(0xffbec6dc),
      onSecondary: Color(0xff283141),
      secondaryContainer: Color(0xff3e4759),
      onSecondaryContainer: Color(0xffdae2f9),
      tertiary: Color(0xffddbce0),
      onTertiary: Color(0xff3f2844),
      tertiaryContainer: Color(0xff573e5c),
      onTertiaryContainer: Color(0xfffad8fd),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff111318),
      onSurface: Color(0xffe2e2e9),
      onSurfaceVariant: Color(0xffc4c6d0),
      outline: Color(0xff8e9099),
      outlineVariant: Color(0xff44474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff415f91),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff001b3e),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff284777),
      secondaryFixed: Color(0xffdae2f9),
      onSecondaryFixed: Color(0xff131c2b),
      secondaryFixedDim: Color(0xffbec6dc),
      onSecondaryFixedVariant: Color(0xff3e4759),
      tertiaryFixed: Color(0xfffad8fd),
      onTertiaryFixed: Color(0xff28132e),
      tertiaryFixedDim: Color(0xffddbce0),
      onTertiaryFixedVariant: Color(0xff573e5c),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff191c20),
      surfaceContainer: Color(0xff1d2024),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff33353a),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffaac7ff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff0a305f),
      primaryContainer: Color(0xff284777),
      onPrimaryContainer: Color(0xffd6e3ff),
      secondary: Color(0xffbec6dc),
      onSecondary: Color(0xff283141),
      secondaryContainer: Color(0xff3e4759),
      onSecondaryContainer: Color(0xffdae2f9),
      tertiary: Color(0xffddbce0),
      onTertiary: Color(0xff3f2844),
      tertiaryContainer: Color(0xff573e5c),
      onTertiaryContainer: Color(0xfffad8fd),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff111318),
      onSurface: Color(0xffe2e2e9),
      onSurfaceVariant: Color(0xffc4c6d0),
      outline: Color(0xff8e9099),
      outlineVariant: Color(0xff44474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff415f91),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff001b3e),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff284777),
      secondaryFixed: Color(0xffdae2f9),
      onSecondaryFixed: Color(0xff131c2b),
      secondaryFixedDim: Color(0xffbec6dc),
      onSecondaryFixedVariant: Color(0xff3e4759),
      tertiaryFixed: Color(0xfffad8fd),
      onTertiaryFixed: Color(0xff28132e),
      tertiaryFixedDim: Color(0xffddbce0),
      onTertiaryFixedVariant: Color(0xff573e5c),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff191c20),
      surfaceContainer: Color(0xff1d2024),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff33353a),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) {
    final baseTextTheme = textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      fontFamily: 'SFProRounded',
      textTheme: baseTextTheme.apply(fontFamily: 'SFProRounded'),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
    );
  }

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
