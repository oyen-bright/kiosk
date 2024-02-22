import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/theme_extention.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile(this.title,
      {Key? key,
      this.iconBgColor,
      this.iconColor,
      this.onTap,
      this.disabled = false,
      required this.icon,
      required this.onChanged,
      required this.isToggled})
      : super(key: key);
  final String title;
  final Color? iconBgColor;
  final Color? iconColor;
  final IconData icon;
  final bool isToggled;
  final bool disabled;
  final void Function()? onTap;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
      contentPadding: EdgeInsets.symmetric(horizontal: 19.w),
      horizontalTitleGap: 6.0,
      minLeadingWidth: 0,
      title: Text(
        title,
        style: context.theme.textTheme.titleSmall,
      ),
      onTap: null,
      leading: Container(
        height: 40.w,
        color:
            iconBgColor ?? context.theme.colorScheme.primary.withOpacity(0.04),
        width: 40.w,
        child: Icon(
          icon,
          color: iconColor ?? context.theme.colorScheme.primary,
        ),
      ),
      trailing: SizedBox(
          child: Platform.isAndroid
              ? Switch(
                  activeColor: context.theme.colorScheme.primary,
                  value: isToggled,
                  onChanged: onChanged,
                )
              : CupertinoSwitch(
                  activeColor: context.theme.colorScheme.primary,
                  value: isToggled,
                  onChanged: onChanged,
                )),
    );
  }
}
