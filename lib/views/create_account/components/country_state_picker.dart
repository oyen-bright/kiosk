import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<Map?> countryStatePicker(BuildContext context, List<Map> states) async {
  if (Platform.isAndroid) {
    return await showMaterialModalBottomSheet(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => SafeArea(child: _body(context, states)));
  } else {
    return await showCupertinoModalBottomSheet(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => _body(context, states));
  }
}

Material _body(BuildContext context, List<Map<dynamic, dynamic>> states) {
  return Material(
      child: Column(
    mainAxisSize: MainAxisSize.min,
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
      Expanded(
          child: ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (_, index) => const Divider(
          thickness: 1,
        ),
        itemCount: states.length,
        itemBuilder: (context, index) {
          return ListTile(
            dense: false,
            visualDensity: VisualDensity.compact,
            title: Text(states[index]['province']),
            onTap: () {
              context.popView(value: states[index]);
            },
          );
        },
      )),
    ],
  ));
}
