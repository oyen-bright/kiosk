import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as date_picker_pro;
import 'package:kiosk/theme/app_theme.dart';

Future datePicker(BuildContext context,
    {bool agreementDate = false, bool hasMaxTime = true}) async {
  if (agreementDate) {
    return await date_picker_pro.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      onConfirm: (date) {
        return date;
      },
      theme: datePickerTheme(context),
      currentTime: DateTime.now(),
    );
  }
  return await date_picker_pro.DatePicker.showDatePicker(
    context,
    showTitleActions: true,
    minTime: DateTime(1800, 1, 1),
    maxTime: hasMaxTime ? DateTime.now() : null,
    onConfirm: (date) {
      return date.toString().substring(0, 10);
    },
    theme: datePickerTheme(context),
    currentTime: DateTime.now(),
  );
}
