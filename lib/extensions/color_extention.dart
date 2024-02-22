import 'dart:ui';

extension ColorExtension on Color {
  /// Darken the color by a specified [percent].
  /// [percent] should be in the range of 1 to 100.
  Color darken([int percent = 40]) {
    assert(1 <= percent && percent <= 100);

    // Calculate the factor by which to reduce the color components.
    final value = 1 - percent / 100;

    // Calculate the new color values based on the reduction factor.
    return Color.fromARGB(
      alpha,
      (red * value).round(),
      (green * value).round(),
      (blue * value).round(),
    );
  }

  /// Lighten the color by a specified [percent].
  /// [percent] should be in the range of 1 to 100.
  Color lighten([int percent = 40]) {
    assert(1 <= percent && percent <= 100);

    // Calculate the factor by which to increase the color components.
    final value = percent / 100;

    // Calculate the new color values based on the increase factor.
    return Color.fromARGB(
      alpha,
      (red + ((255 - red) * value)).round(),
      (green + ((255 - green) * value)).round(),
      (blue + ((255 - blue) * value)).round(),
    );
  }

  /// Calculate the average color between this color and another [other] color.
  /// This function takes into account the alpha values of both colors.
  Color avg(Color other) {
    // Calculate the average values of red, green, blue, and alpha.
    final red = (this.red + other.red) ~/ 2;
    final green = (this.green + other.green) ~/ 2;
    final blue = (this.blue + other.blue) ~/ 2;
    final alpha = (this.alpha + other.alpha) ~/ 2;

    // Create a new color with the calculated average values.
    return Color.fromARGB(alpha, red, green, blue);
  }
}
