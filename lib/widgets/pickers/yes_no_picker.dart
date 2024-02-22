import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<bool?> yesNoPicker(BuildContext context) async {
  if (Platform.isAndroid) {
    return await showMaterialModalBottomSheet(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => const SafeArea(
        top: false,
        child: _Body(),
      ),
    );
  } else {
    return await showCupertinoModalBottomSheet(
        context: context,
        barrierColor: Colors.black54,
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
                    Navigator.pop(context);
                  },
                  child: Text(LocaleKeys.cancel.tr(),
                      style: context.theme.textTheme.titleMedium!
                          .copyWith(color: context.theme.colorScheme.primary))),
            ],
          ),
        ),
        ListTile(
            onTap: () {
              context.popView(value: true);
            },
            title: const Text(
              "Yes",
            )),
        ListTile(
            onTap: () {
              context.popView(value: false);
            },
            title: const Text(
              "No",
            )),
        20.h.height,
      ],
    );
  }
}
