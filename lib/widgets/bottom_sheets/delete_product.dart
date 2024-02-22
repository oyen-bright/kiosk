import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<bool?> deleteProductBottomSheet(
    BuildContext context, String productId, String productName) async {
  return await showCupertinoModalBottomSheet(
      useRootNavigator: true,
      barrierColor: Colors.black87,
      backgroundColor: context.theme.canvasColor,
      context: context,
      builder: (context) {
        return Container(
          margin: EdgeInsets.only(bottom: 50.h),
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildAppBar(context, productName),
              20.h.height,
              Icon(
                Icons.warning_rounded,
                size: 80.r,
                color: Colors.red,
              ),
              15.h.height,
              _buildDescription(context),
              Container(
                  margin: EdgeInsets.only(
                      top: 15.h, left: 25.w, right: 25.w, bottom: 15.h),
                  width: double.infinity,
                  child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        context.popView(value: true);
                      },
                      child: Text(
                        LocaleKeys.delete.tr().toUpperCase(),
                      ))),
            ],
          ),
        );
      });
}

Material _buildDescription(BuildContext context) {
  return Material(
    color: context.theme.canvasColor,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      width: double.infinity,
      child: AutoSizeText(LocaleKeys.areYouSureYouWantToDeleteThisProduct.tr(),
          textAlign: TextAlign.center,
          style: context.theme.textTheme.bodyMedium!),
    ),
  );
}

Widget _buildAppBar(BuildContext context, String productName) {
  if (Platform.isIOS) {
    return CupertinoNavigationBar(
      previousPageTitle: LocaleKeys.back.tr(),
      middle: Text(LocaleKeys.delete.tr() + " $productName"),
    );
  }
  return AppBar(
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
        onPressed: () => context.popView(), icon: const Icon(Icons.arrow_back)),
    title: Text(LocaleKeys.delete.tr() + " $productName"),
  );
}
