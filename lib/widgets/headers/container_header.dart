import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class ContainerHeader extends StatelessWidget {
  const ContainerHeader(
      {Key? key,
      this.title,
      required this.subTitle,
      this.showHeader = true,
      this.centerText = false})
      : super(key: key);

  final String? title;
  final String? subTitle;
  final bool centerText;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        15.h.height,
        if (showHeader)
          SizedBox(
            width: double.infinity,
            child: Text(
              title!,
              textAlign: centerText ? TextAlign.center : TextAlign.left,
              style: context.theme.textTheme.titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        if (showHeader) 10.h.height,
        SizedBox(
          width: double.infinity,
          child: AutoSizeText(
            subTitle!,
            textAlign: centerText ? TextAlign.center : TextAlign.left,
            style: context.theme.textTheme.bodySmall,
          ),
        ),
        25.h.height,
      ],
    );
  }
}
