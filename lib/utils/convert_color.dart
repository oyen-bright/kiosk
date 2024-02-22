import 'package:flutter/material.dart';

Color? parseColor(String colorString) {
  RegExp exp = RegExp(r'rgb\((\d+),\s*(\d+),\s*(\d+)\)');

  if (exp.firstMatch(colorString) != null) {
    Match match = exp.firstMatch(colorString)!;

    int red = int.parse(match.group(1)!);
    int green = int.parse(match.group(2)!);
    int blue = int.parse(match.group(3)!);

    return Color.fromARGB(255, red, green, blue);
  }
  return null;
}

bool isVeryDark(Color? color) {
  // calculate the perceived brightness of the color

  if (color == null) {
    return false;
  }
  double brightness = color.computeLuminance();

  // set a threshold value for very dark colors
  double threshold = 0.15;

  // return true if the brightness is below the threshold
  return brightness < threshold;
}
