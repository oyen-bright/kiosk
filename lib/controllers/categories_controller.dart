import 'package:flutter/material.dart';

class CategoriesController extends ValueNotifier<List<int>> {
  CategoriesController([List<int>? initialValue]) : super(initialValue ?? []);
  void clear() {
    value = [];
  }

  void add(int item) {
    value = List.from(value)..add(item);
  }

  void remove(int valueToRemove) {
    value = List.from(value)..remove(valueToRemove);
  }

  void removeAtIndex(int index) {
    if (index >= 0 && index < value.length) {
      value = List.from(value)..removeAt(index);
    }
  }
}
