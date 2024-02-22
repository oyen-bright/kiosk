import 'package:flutter/material.dart';

Color generateDarkModeColor(Color color) {
  double luminance = color.computeLuminance();

  // Use a threshold luminance value to determine whether the color is light or dark.
  // This value may need to be adjusted based on your specific use case.
  const double threshold = 0.5;

  if (luminance > threshold) {
    // The color is light, so darken it for dark mode.
    return Color.fromRGBO(
      (color.red * 0.8).round(),
      (color.green * 0.8).round(),
      (color.blue * 0.8).round(),
      1.0,
    );
  } else {
    // The color is dark, so lighten it for dark mode.
    return Color.fromRGBO(
      (color.red * 1.2).round(),
      (color.green * 1.2).round(),
      (color.blue * 1.2).round(),
      1.0,
    );
  }
}
