import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/slidable/slidable.dart';

class PaymentTile extends StatelessWidget {
  const PaymentTile(
      {Key? key,
      this.onPressed,
      required this.onSwitch,
      this.onTap,
      required this.icon,
      required this.title,
      this.isToggled = false})
      : super(key: key);

  final VoidCallback? onTap;
  final Function onSwitch;
  final IconData icon;
  final String title;
  final bool isToggled;
  final Function(BuildContext)? onPressed;

  @override
  Widget build(BuildContext context) {
    return KioskSlidable(
      label: LocaleKeys.edit.tr(),
      icon: Icons.edit,
      slidableAction: SlidableAction(
        onPressed: onPressed,
        autoClose: true,
        icon: Icons.delete,
        backgroundColor: Colors.red,
        label: LocaleKeys.delete.tr(),
      ),
      child: Container(
        alignment: Alignment.centerLeft,
        height: 60.h,
        margin: EdgeInsets.symmetric(vertical: 2.h),
        child: ListTile(
          style: ListTileStyle.drawer,
          horizontalTitleGap: -7,
          title: Text(
            title.toUpperCase(),
          ),
          trailing: SizedBox(
              height: 28.h,
              width: 28.w,
              child: Platform.isAndroid
                  ? Switch(
                      activeColor: context.theme.colorScheme.primary,
                      value: isToggled,
                      onChanged: (bool value) {
                        onSwitch();
                      },
                    )
                  : CupertinoSwitch(
                      activeColor: context.theme.colorScheme.primary,
                      value: isToggled,
                      onChanged: (val) {
                        onSwitch();
                      })),
          onTap: onTap,
        ),
      ),
    );
  }
}
