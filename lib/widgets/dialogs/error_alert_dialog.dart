import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future dialogSetup(
  BuildContext context, {
  required String title,
  Color? color,
  required String? information,
  IconData icon = Icons.info,
}) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          titlePadding: EdgeInsets.zero,
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                10.h.height,
                Icon(
                  icon,
                  size: 70.r,
                  color: color,
                ),
                10.h.height,
                SizedBox(
                  width: double.infinity,
                  child: AutoSizeText(title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: context.theme.textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
                10.h.height,
                SizedBox(
                  width: double.infinity,
                  child: AutoSizeText(
                    information.toString(),
                    style: context.theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                25.h.height,
                ElevatedButton(
                    onPressed: () {
                      context.popView();
                    },
                    child: Text(LocaleKeys.continuE.tr().toUpperCase())),
              ],
            ),
          ),
        );
      });
}

Future anErrorOccurredDialog(BuildContext context,
    {String? title, String? error}) {
  return dialogSetup(
    context,
    title: title ?? LocaleKeys.anErrorOccured.tr(),
    information: error ?? LocaleKeys.anErrorOccuredPleaseTryAgain.tr(),
    icon: Icons.error,
  );
}

Future successfulDialog(BuildContext context,
    {String? title, required String res, Color? color}) {
  return dialogSetup(
    context,
    color: color,
    icon: MdiIcons.checkDecagram,
    title: title ?? LocaleKeys.success.tr(),
    information: res,
  );
}

Future offlineDialog(BuildContext context, {String? title, String? res}) {
  return dialogSetup(
    context,
    icon: MdiIcons.connection,
    title: title ?? LocaleKeys.noInternetConnection.tr(),
    information: res ??
        LocaleKeys.youReCurrentlyOnOfflineModePleaseConnectToInternetToContinue
            .tr(),
  );
}
