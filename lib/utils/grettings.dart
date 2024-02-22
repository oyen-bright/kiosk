import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiosk/translations/locale_keys.g.dart';

Map<String, dynamic> greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return {
      "Greetings": LocaleKeys.goodMorning.tr(),
      "Icon": "M",
      "Color": [
        Colors.white,
        const Color(0xFFddd6f3),
        const Color(0xFFfaaca8),
      ]
    };
  }
  if (hour < 17) {
    return {
      "Greetings": LocaleKeys.goodAfternoon.tr(),
      "Icon": "MMM",
      "Color": [
        Colors.white,
        const Color(0xFFffc371),
        const Color(0xFFff5f6d),
      ]
    };
  }
  if (hour < 20) {
    return {
      "Greetings": LocaleKeys.goodEvening.tr(),
      "Icon": "MMMM",
      "Color": [
        Colors.white,
        const Color(0xFFf7bb97),
        const Color(0xFFdd5e89),
      ]
    };
  }
  return {
    "Greetings": LocaleKeys.goodEvening.tr(),
    "Icon": "MM",
    "Color": [
      Colors.white,
      const Color(0xFF4389A2),
      const Color.fromRGBO(1, 22, 46, 1),
    ]
  };
}
