import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class BalanceDisplay extends StatelessWidget {
  final Color? backgroundColor;
  final String title;
  final String? currency;
  final String value;
  final bool obsucre;
  const BalanceDisplay(
      {Key? key,
      this.currency,
      required this.value,
      this.obsucre = true,
      this.backgroundColor,
      required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final kioskBlue = context.theme.colorScheme.primary;
    return CustomContainer(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
      padding: EdgeInsets.all(16.r),
      color: backgroundColor ?? context.theme.canvasColor,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: AutoSizeText(
              title,
              style: context.theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.normal,
                // color: kioskBlue
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Row(children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: AutoSizeText(
                    currency ?? getCurrency(context),
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    style: context.theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold, color: kioskBlue),
                  ),
                ),
              ),
              5.w.width,
              SizedBox(
                child: AutoSizeText(
                  obsucre ? "*" * value.length : value,
                  style: context.theme.textTheme.titleLarge!
                      .copyWith(color: kioskBlue),
                ),
              )
            ]),
          )
        ],
      ),
    );
  }
}
