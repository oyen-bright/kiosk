import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class BalanceDisplayLarge extends StatelessWidget {
  final Color? backgroundColor;
  final String title;
  final String? currency;
  final String value;
  const BalanceDisplayLarge({
    Key? key,
    this.backgroundColor,
    required this.value,
    this.currency,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: backgroundColor ?? context.theme.canvasColor,
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
      padding: EdgeInsets.all(16.0.r),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: AutoSizeText(
              title,
              style: context.theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.normal,
                color: context.theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                AutoSizeText(
                  value,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  style: context.theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
                5.w.width,
                Expanded(
                  child: AutoSizeText(
                    currency ?? getCurrency(context),
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    style: context.theme.textTheme.titleLarge!
                        .copyWith(color: context.theme.colorScheme.primary),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
