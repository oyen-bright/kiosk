import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/.constants.dart';
import 'package:kiosk/extensions/.extensions.dart';

class LoadingWidget extends StatelessWidget {
  final String? title;
  final Color? backgroundColor;
  final bool isLinear;
  const LoadingWidget({
    this.title,
    this.backgroundColor,
    this.isLinear = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLinear) {
      return LinearProgressIndicator(
        // color: Color.fromRGBO(0, 0, 188, 1),
        backgroundColor: context.theme.primaryColorLight,
      );
    }
    return SizedBox(
      height: 1.sh,
      width: 1.sw,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          color: backgroundColor ?? Colors.transparent,
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                CircularProgressIndicator(
                    color: backgroundColor ?? kioskBlue,
                    backgroundColor: kioskYellow),
                Builder(builder: (_) {
                  if (title == null) {
                    return Container();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Material(
                      color: Colors.transparent,
                      child: AutoSizeText(
                        title!,
                        style: context.theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                })
              ])),
        ),
      ),
    );
  }
}
