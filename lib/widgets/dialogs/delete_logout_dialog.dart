import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';
import 'package:kiosk/translations/locale_keys.g.dart';

Future<bool?> logoutDeleteDialog(BuildContext context,
    {bool isDeleteAccount = false}) async {
  final localStorage = context.read<LocalStorage>();
  final offlineCheckout = localStorage.readOfflineCheckOut();
  final offlineProducts = localStorage.readOfflineProducts();
  final hasOfflineData = offlineCheckout != null || offlineProducts != null;

  final title = LocaleKeys.warning.tr().toUpperCase();
  final content = isDeleteAccount
      ? LocaleKeys.areYouSureYouWantToDelete.tr() + " ?"
      : hasOfflineData
          ? LocaleKeys.youCurrentlyHaveSomeOflline.tr() +
              " ${LocaleKeys.continuE.tr()} ?"
          : LocaleKeys.youAreAboutToLogoutOfYour.tr() + " ?";

  if (Platform.isIOS) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
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
      barrierColor: Colors.black87,
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: Text(LocaleKeys.no.tr()),
              onPressed: () => context.popView(),
            ),
            TextButton(
                child: Text(LocaleKeys.yes.tr()),
                onPressed: () => context.popView(value: true)),
          ],
        );
      },
    );
  }
}
