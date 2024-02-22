import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  /// Unfocus any currently focused input field.
  ///
  /// This method can be used to dismiss the keyboard or remove focus from an input field.
  ///
  /// Usage:
  /// ```dart
  /// context.unFocus();
  /// ```
  void unFocus() {
    FocusScope.of(this).unfocus();
  }
}
