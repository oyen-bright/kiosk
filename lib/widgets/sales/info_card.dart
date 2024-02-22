import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/constant_color.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/widgets/.widgets.dart';

class SalesReportInfoCard extends StatelessWidget {
  final void Function() callback;
  final Color backgroundColor;
  final String value;
  final String title;
  final String currency;
  const SalesReportInfoCard(
      {Key? key,
      required this.callback,
      required this.title,
      required this.currency,
      required this.backgroundColor,
      required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: callback,
        child: CustomContainer(
          height: 80.h,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 0.h),
          padding: EdgeInsets.all(16.r),
          color: backgroundColor,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: AutoSizeText(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: context.theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text.rich(TextSpan(
                          text: currency,
                          style: context.theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: kioskBlue,
                          ),
                          children: <InlineSpan>[
                            TextSpan(
                                text: value,
                                style: context.theme.textTheme.titleLarge!
                                    .copyWith(
                                  color: kioskBlue,
                                ))
                          ])),
                    ),
                  ),
                  alignment: Alignment.center,
                ),
              ),
            ],
          ),
        ));
  }
}
