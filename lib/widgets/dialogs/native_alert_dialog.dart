import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';

Future nativeAlertDialog(BuildContext context, String message,
    [String? title]) {
  if (Platform.isIOS) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title ?? LocaleKeys.error.tr()),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text(
                LocaleKeys.ok.tr(),
                style: TextStyle(color: context.theme.colorScheme.primary),
              ),
              onPressed: () => context.popView(),
            ),
          ],
        );
      },
    );
  } else {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title ?? LocaleKeys.error.tr()),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => context.popView(),
              child: Text(LocaleKeys.ok.tr()),
            ),
          ],
        );
      },
    );
  }
}
