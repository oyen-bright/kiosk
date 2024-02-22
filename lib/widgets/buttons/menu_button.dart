import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/theme_extention.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class MenuButton extends StatelessWidget {
  final void Function() callback;
  final dynamic iconData;
  final String title;
  final bool isImage;

  const MenuButton(
      {Key? key,
      required this.iconData,
      required this.title,
      this.isImage = true,
      required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: CustomContainer(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 0.w),
        height: 73.w,
        width: 73.w,
        color: context.theme.primaryColorLight,
        child: Column(
          children: [
            2.h.height,
            Expanded(
              flex: 3,
              child: isImage
                  ? Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.asset(
                        iconData.toString(),
                        fit: BoxFit.contain,
                        color: context.theme.colorScheme.primary,
                      ),
                    )
                  : FittedBox(
                      fit: BoxFit.cover,
                      child: Icon(
                        iconData,
                      ),
                    ),
            ),
            2.h.height,
            Expanded(
                flex: 4,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 0.6.w, vertical: 0.5.h),
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    title,
                    maxFontSize: context.theme.textTheme.labelMedium!.fontSize!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize:
                        context.theme.textTheme.labelMedium!.fontSize! - 3,
                    style: context.theme.textTheme.labelMedium!
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
