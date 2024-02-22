import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';

class SocialTile extends StatelessWidget {
  const SocialTile(this.title,
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
      onTap: onTap,
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
    );
  }
}
