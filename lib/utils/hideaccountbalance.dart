import 'package:flutter/material.dart';

String hideAccBalance(BuildContext context, String data,
    {required bool hideBalance}) {
  if (hideBalance) {
    return "*" * data.length;
  } else {
    return data;
  }
}
