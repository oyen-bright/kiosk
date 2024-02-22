import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/product_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<bool?> deleteCategoryBottomSheet(
    BuildContext contextT, int categoryId) async {
  return await showCupertinoModalBottomSheet(
      useRootNavigator: false,
      barrierColor: Colors.black87,
      backgroundColor: contextT.theme.canvasColor,
      context: contextT,
      builder: (context) {
        return Container(
          margin: EdgeInsets.only(bottom: 50.h),
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildAppBar(context),
              10.h.height,
              Icon(
                Icons.warning_rounded,
                size: 80.r,
                color: Colors.red,
              ),
              5.h.height,
              _buildDescription(context),
              Container(
                margin: EdgeInsets.only(top: 20.h, left: 22.w, right: 22.w),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    try {
                      await context
                          .read<ProductRepository>()
                          .deleteCategory(categoryId: categoryId);
                      context.snackBar(
                          LocaleKeys.categoryDeletedSuccessfully.tr());
                      context.popView(value: true);
                    } catch (e) {
                      context.snackBar(e.toString());
                      context.popView();
                    }
                  },
                  child: Text(
                    LocaleKeys.deleteCategory.tr().toUpperCase(),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

Widget _buildAppBar(BuildContext context) {
  if (Platform.isIOS) {
    return CupertinoNavigationBar(
      previousPageTitle: LocaleKeys.back.tr(),
      middle: Text(LocaleKeys.deleteCategory.tr()),
    );
  }
  return AppBar(
    centerTitle: true,
    elevation: 0,
    leading: IconButton(
        onPressed: () => context.popView(), icon: const Icon(Icons.arrow_back)),
    title: Text(LocaleKeys.deleteCategory.tr()),
  );
}

Widget _buildDescription(BuildContext context) {
  return Material(
    color: context.theme.canvasColor,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      width: double.infinity,
      child: AutoSizeText(
          LocaleKeys.areYouSureYouWantToDeleteThisCategoryAndAllItSProducts
              .tr(),
          textAlign: TextAlign.center,
          style: context.theme.textTheme.bodyMedium!),
    ),
  );
}
