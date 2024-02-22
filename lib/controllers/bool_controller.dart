import 'package:flutter/material.dart';

class MyBoolController extends ValueNotifier<bool> {
  MyBoolController(bool? initialValue) : super(initialValue ?? false);

  void toggle() {
    value = !value;
  }
}
