import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';

Future<bool?> costPriceSalePriceDialog(
  BuildContext context,
) async {
  final title = LocaleKeys.warning.tr() + " !";
  final message =
      LocaleKeys.yourSalesPriceIsLowerThanYourCostPriceDoYouWantToProceed.tr() +
          "? ";

  if (Platform.isIOS) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text(
                LocaleKeys.no.tr(),
                style: TextStyle(color: context.theme.colorScheme.primary),
              ),
              onPressed: () => context.popView(),
            ),
            CupertinoDialogAction(
                child: Text(
                  LocaleKeys.yes.tr(),
                  style: TextStyle(color: context.theme.colorScheme.primary),
                ),
                onPressed: () => context.popView(value: true)),
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
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => context.popView(),
              child: Text(LocaleKeys.no.tr()),
            ),
            TextButton(
              onPressed: () => context.popView(value: true),
              child: Text(LocaleKeys.yes.tr()),
            ),
          ],
        );
      },
    );
  }
}
