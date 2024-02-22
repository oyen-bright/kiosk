import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/offline/offline_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';

showMaterialBanner(BuildContext context,
    {bool isSyncing = false,
    bool syncDone = false,
    bool errorSync = false,
    String errorMessage = ""}) {
  return MaterialBanner(
      content: AutoSizeText(
        isSyncing
            ? LocaleKeys.syncing.tr()
            : errorSync
                ? LocaleKeys.anErrorOccured.tr() + " " + errorMessage
                : syncDone
                    ? LocaleKeys.syncDone.tr()
                    : LocaleKeys.offlineMode.tr(),
        maxLines: 3,
        // style: context.theme.textTheme.bodyMedium!.copyWith(color: kioskBlue),
      ),
      leading: FittedBox(
        child: Builder(builder: (_) {
          if (isSyncing) {
            return Platform.isIOS
                ? const CupertinoActivityIndicator(
                    radius: 15,
                  )
                : const SizedBox(
                    height: 15, width: 15, child: CircularProgressIndicator());
          }
          if (syncDone) {
            return const Icon(
              Icons.done,
              color: Colors.green,
            );
          }
          return Icon(
            Icons.error,
            color: errorSync ? Colors.red : null,
          );
        }),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      backgroundColor: context.theme.scaffoldBackgroundColor,
      elevation: 0,
      actions: [
        Row(
          children: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: Text(
                LocaleKeys.okay.tr(),
              ),
            ),
            errorSync
                ? TextButton(
                    onPressed: () {
                      context.read<OfflineCubit>().connected();
                    },
                    child: Text(
                      LocaleKeys.retry.tr(),
                      maxLines: 1,
                    ))
                : Container()
          ],
        )
      ]);
}
