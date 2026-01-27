import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A custom theme extension to define app-specific colors.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  /// A custom color example.
  final Color? customColor;

  /// Creates an instance of [AppColorsExtension].
  const AppColorsExtension({this.customColor});

  @override
  AppColorsExtension copyWith({Color? customColor}) {
    return .new(customColor: customColor ?? this.customColor);
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    // Checks if the other extension is of the same type.
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      // Interpolates between the current and other customColor.
      customColor: Color.lerp(customColor, other.customColor, t),
    );
  }
}

/// Defines the light and dark themes for both Material and Cupertino.
class AppThemes {
  /// The Material light theme configuration.
  static final ThemeData materialLightTheme = .light(useMaterial3: true);

  /// The Material dark theme configuration.
  static final ThemeData materialDarkTheme = .dark(useMaterial3: true);

  /// The default dark Cupertino theme data.
  static const darkDefaultCupertinoTheme = CupertinoThemeData(
    brightness: .dark,
  );

  /// The Cupertino dark theme based on the Material dark theme.
  static final cupertinoDarkTheme = MaterialBasedCupertinoThemeData(
    materialTheme: materialDarkTheme.copyWith(
      cupertinoOverrideTheme: .new(
        brightness: Brightness.dark,
        barBackgroundColor: darkDefaultCupertinoTheme.barBackgroundColor,
      ),
    ),
  );

  /// The Cupertino light theme based on the Material light theme.
  static final cupertinoLightTheme = MaterialBasedCupertinoThemeData(
    materialTheme: materialLightTheme,
  );
}
