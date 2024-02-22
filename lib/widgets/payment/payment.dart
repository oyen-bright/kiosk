import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/widgets/.widgets.dart';

class PaymentMethodWidget extends StatelessWidget {
  final void Function() callback;
  final String value;
  final String title;
  const PaymentMethodWidget(
      {Key? key,
      required this.callback,
      required this.title,
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
          color: context.theme.primaryColorLight,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  child: Image.asset(
                    value,
                    color: context.theme.colorScheme.primary,
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ));
  }
}
