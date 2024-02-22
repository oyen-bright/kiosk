import 'dart:io';

import 'package:flutter/material.dart';

class ImageFileController extends ValueNotifier<File?> {
  ImageFileController(File? initialValue) : super(initialValue);
  void clear() {
    value = null;
  }
}
