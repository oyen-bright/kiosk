import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/constant_color.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/widgets/.widgets.dart';

class LogoButton extends StatelessWidget {
  final String title;
  final String imageAddress;
  final void Function()? callback;
  final Color backgroundColor;
  final Color textColor;
  final double? imageHeight;

  const LogoButton({
    Key? key,
    required this.imageAddress,
    this.imageHeight,
    required this.title,
    this.callback,
    this.textColor = Colors.white,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: CustomContainer(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 5.h),
        width: double.infinity,
        color: backgroundColor,
        child: Row(
          children: [
            Container(
              alignment: Alignment.centerRight,
              height: imageHeight ?? 40.w,
              padding: EdgeInsets.symmetric(vertical: 4.h),
              width: imageHeight ?? 40.w,
              child: Image.asset(
                imageAddress,
                color: kioskBlue,
                fit: BoxFit.fitHeight,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: AutoSizeText(
                  title,
                  textAlign: TextAlign.center,
                  minFontSize: 10,
                  maxLines: 1,
                  style: context.theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
