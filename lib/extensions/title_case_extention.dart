extension TitleCaseExtension on String {
  /// Convert the first character of the string to uppercase.
  ///
  /// Usage:
  /// ```dart
  /// String title = "hello".titleCase;
  /// ```
  String get titleCase => this[0].toUpperCase() + substring(1);
}
