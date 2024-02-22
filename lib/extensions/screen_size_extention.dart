import 'package:flutter/material.dart';

extension ScreenSizeExtension on BuildContext {
  /// Get the height of the current screen.
  double get height => MediaQuery.of(this).size.height;

  /// Get the width of the current screen.
  double get width => MediaQuery.of(this).size.width;
}
