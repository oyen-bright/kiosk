import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/constant_color.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/widgets/.widgets.dart';

class StockReportInfoCard extends StatelessWidget {
  final void Function() callback;
  final Color backgroundColor;
  final String value;
  final String title;
  const StockReportInfoCard(
      {Key? key,
      required this.callback,
      required this.title,
      required this.backgroundColor,
      required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: callback,
        child: CustomContainer(
          height: 150.w,
          width: 150.w,
          margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
          padding: EdgeInsets.all(16.r),
          color: backgroundColor,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: AutoSizeText(
                    value,
                    maxLines: 1,
                    style: context.theme.textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold, color: kioskBlue),
                  ),
                  alignment: Alignment.center,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: AutoSizeText(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: context.theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              )
            ],
          ),
        ));
  }
}
