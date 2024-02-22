import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/.constants.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<String?> businessCategoryPicker(BuildContext context) async {
  if (Platform.isAndroid) {
    return await showMaterialModalBottomSheet(
      barrierColor: Colors.black87,
      context: context,
      builder: (context) => Container(
          color: context.theme.canvasColor,
          child: const SafeArea(
            child: _Body(),
          )),
    );
  } else {
    return await showCupertinoModalBottomSheet(
        barrierColor: Colors.black87,
        context: context,
        builder: (context) => Container(
            color: context.theme.canvasColor,
            child: const Material(
                child: SafeArea(
              child: _Body(),
            ))));
  }
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = categoriesName;
    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          color: context.theme.canvasColor.darken(1),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    context.popView();
                  },
                  child: Text(LocaleKeys.cancel.tr(),
                      style: context.theme.textTheme.titleMedium!
                          .copyWith(color: context.theme.colorScheme.primary))),
              // TextButton(
              //     onPressed: () {},
              //     child: Text(LocaleKeys.done.tr(),
              //         style: context.theme.textTheme.titleMedium!))
            ],
          ),
        ),
        for (var i in data)
          ListTile(
              onTap: () {
                context.popView(value: i["Data"]);
              },
              title: Text(
                i["Title"],
              )),
        20.h.height,
      ],
    );
  }
}
