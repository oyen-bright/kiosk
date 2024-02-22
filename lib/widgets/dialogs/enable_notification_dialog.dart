import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/cubits/settings/user_settings_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';

Future<bool?> enableNotificationDialog(
  BuildContext context,
) async {
  final title = LocaleKeys.enableNotifications.tr();
  final message = LocaleKeys
      .byEnablingnotificationsyoullreceivealertsaboutnewsalesandotherimportantupdatesrelatedtoyourbusiness
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
                LocaleKeys.cancel.tr(),
                style: TextStyle(color: context.theme.colorScheme.primary),
              ),
              onPressed: () {
                context.popView();
                context.read<UserSettingsCubit>().disableNotification();
              },
            ),
            CupertinoDialogAction(
                child: Text(
                  LocaleKeys.enable.tr(),
                  style: TextStyle(color: context.theme.colorScheme.primary),
                ),
                onPressed: () {
                  context.popView(value: true);
                  AwesomeNotifications().requestPermissionToSendNotifications();
                }),
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
              onPressed: () {
                context.popView();
                context.read<UserSettingsCubit>().disableNotification();
              },
              child: Text(LocaleKeys.cancel.tr()),
            ),
            TextButton(
              onPressed: () {
                context.popView(value: true);
                AwesomeNotifications().requestPermissionToSendNotifications();
              },
              child: Text(
                LocaleKeys.enable.tr(),
              ),
            ),
          ],
        );
      },
    );
  }
}
