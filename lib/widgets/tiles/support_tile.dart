import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';

class SupportTile extends StatelessWidget {
  const SupportTile(this.title,
      {Key? key,
      this.iconBgColor,
      this.iconColor,
      this.onTap,
      required this.icon})
      : super(key: key);
  final String title;
  final Color? iconBgColor;
  final Color? iconColor;
  final IconData icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
      contentPadding: EdgeInsets.symmetric(horizontal: 19.w),
      horizontalTitleGap: 6.0,
      minLeadingWidth: 0,
      title: Text(
        title,
      ),
      trailing: Container(
          height: 28.w,
          width: 28.w,
          decoration: BoxDecoration(
              color: iconBgColor ??
                  context.theme.colorScheme.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(100.r)),
          child: Icon(
            Icons.arrow_forward_ios,
            color: iconColor ?? context.theme.colorScheme.primary,
          )),
      onTap: onTap,
      leading: Container(
        height: 40.h,
        color:
            iconBgColor ?? context.theme.colorScheme.primary.withOpacity(0.04),
        width: 40.w,
        child: Icon(
          icon,
          color: iconColor ?? context.theme.colorScheme.primary,
        ),
      ),
    );
  }
}
