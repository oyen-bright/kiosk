import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String subTitle;
  final double? padding;
  const ScreenHeader(
      {Key? key, required this.subTitle, required this.title, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding ?? 25.w),
      child: Column(
        children: [
          15.h.height,
          SizedBox(
            width: double.infinity,
            child: AutoSizeText(
              title,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          20.h.height,
          Center(
            child: SizedBox(
              width: double.infinity,
              child: AutoSizeText(
                subTitle,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
