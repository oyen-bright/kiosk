import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/widgets/.widgets.dart';

class ConButton extends StatelessWidget {
  final String title;
  final void Function() callback;
  final Color? backgroundColor;
  final Color textColor;

  const ConButton(
      {Key? key,
      required this.title,
      required this.callback,
      this.textColor = Colors.white,
      this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: CustomContainer(
          alignment: Alignment.center,
          height: 50.h,
          width: double.infinity,
          color: backgroundColor,
          child: AutoSizeText(title,
              style: context.theme.textTheme.titleMedium!
                  .copyWith(fontWeight: FontWeight.bold, color: textColor))),
    );
  }
}
