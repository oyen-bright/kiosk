import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/login/login.dart';

Future<void> subscriptionDialog(
  BuildContext context,
) async {
  final title = LocaleKeys.activateSubscription.tr();
  final message = LocaleKeys
      .inOrderToActivateSubscriptionYouHaveToReLoginDoYouWantToReLoginNow
      .tr();
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
              onPressed: () async {
                context.read<UserRepository>().userLogout();
                await context.read<LocalStorage>().userLogout();
                context.pushView(const LogIn(), clearStack: true);
              },
            )
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
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => context.popView(),
              child: Text(LocaleKeys.no.tr()),
            ),
            TextButton(
              onPressed: () async {
                context.read<UserRepository>().userLogout();
                await context.read<LocalStorage>().userLogout();
                context.pushView(const LogIn(), clearStack: true);
              },
              child: Text(LocaleKeys.yes.tr()),
            ),
          ],
        );
      },
    );
  }
}
