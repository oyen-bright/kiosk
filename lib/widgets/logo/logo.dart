import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/theme_extention.dart';

class AppbarLogo extends StatelessWidget {
  const AppbarLogo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5.h),
      height: 45.h,
      width: double.infinity,
      child: Image.asset(
        "assets/images/KIOSK TEXT.png",
        fit: BoxFit.fitHeight,
        color: context.theme.colorScheme.primary,
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
