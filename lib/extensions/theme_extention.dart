import 'package:flutter/material.dart';

extension CustomThemeExtension on BuildContext {
  /// Retrieve the current theme data from the context.
  ///
  /// Usage:
  /// ```dart
  /// ThemeData themeData = context.theme;
  /// ```
  ThemeData get theme => Theme.of(this);
}
