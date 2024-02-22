import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showSnackBar(BuildContext context, String info, {SnackBarAction? action}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      info,
      textAlign: TextAlign.center,
    ),
    elevation: 10,
    // duration: const Duration(seconds: 30),
    behavior: SnackBarBehavior.floating,
    // action: action ??
    //     SnackBarAction(
    //       label: LocaleKeys.ok.tr(),
    //       onPressed: () {
    //         ScaffoldMessenger.of(context).removeCurrentSnackBar();
    //       },
    //     ),
    margin: EdgeInsets.only(bottom: 20.h, left: 10.w, right: 10.w),
  ));
}
