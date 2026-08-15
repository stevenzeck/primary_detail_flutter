import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

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

  /// The Cupertino dark theme.
  static const cupertinoDarkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
  );

  /// The Cupertino light theme.
  static const cupertinoLightTheme = CupertinoThemeData(
    brightness: Brightness.light,
  );
}
