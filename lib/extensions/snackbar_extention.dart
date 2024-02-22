import 'package:flutter/material.dart';
import 'package:kiosk/widgets/snackbar/snackbar.dart';

extension SnackBarExtension on BuildContext {
  /// Show a snackbar with the provided [info] message and optional [action].
  ///
  /// Usage:
  /// ```dart
  /// context.snackBar('This is a snackbar message', SnackBarAction(
  ///   label: 'Action',
  ///   onPressed: () {
  ///     // Action logic here
  ///   },
  /// ));
  /// ```
  void snackBar(String info, [SnackBarAction? action]) {
    showSnackBar(this, info, action: action);
  }
}
