import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AppThemes {
  static final materialLightTheme = ThemeData.light(useMaterial3: true);
  static final materialDarkTheme = ThemeData.dark(useMaterial3: true);

  static const darkDefaultCupertinoTheme = CupertinoThemeData(
    brightness: Brightness.dark,
  );

  static final cupertinoDarkTheme = MaterialBasedCupertinoThemeData(
    materialTheme: materialDarkTheme.copyWith(
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: Brightness.dark,
        barBackgroundColor: darkDefaultCupertinoTheme.barBackgroundColor,
        textTheme: CupertinoTextThemeData(
          primaryColor: Colors.white,
          navActionTextStyle: darkDefaultCupertinoTheme
              .textTheme
              .navActionTextStyle
              .copyWith(color: const Color(0xF0F9F9F9)),
          navLargeTitleTextStyle: darkDefaultCupertinoTheme
              .textTheme
              .navLargeTitleTextStyle
              .copyWith(color: const Color(0xF0F9F9F9)),
        ),
      ),
    ),
  );

  static final cupertinoLightTheme = MaterialBasedCupertinoThemeData(
    materialTheme: materialLightTheme,
  );
}
