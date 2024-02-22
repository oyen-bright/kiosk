import 'dart:math';

import 'package:flutter/material.dart';

Color generateRandomColor() {
  Random random = Random();
  return Color.fromARGB(
    255, // Set alpha to 255, which means fully opaque
    random.nextInt(256), // Set red value
    random.nextInt(256), // Set green value
    random.nextInt(256), // Set blue value
  );
}
