import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';

class ELearningWidget extends StatelessWidget {
  final VoidCallback callback;
  final String imageURL;
  final String dateDuration;
  final String title;

  const ELearningWidget({
    Key? key,
    required this.imageURL,
    required this.title,
    required this.dateDuration,
    required this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: CustomContainer(
        color: context.theme.primaryColorLight,
        height: 100.h,
        margin: EdgeInsets.symmetric(vertical: 10.h),
        padding: EdgeInsets.all(10.r),
        child: Row(
          children: [
            SizedBox(
              height: 60.w,
              width: 70.w,
              child: CachedNetworkImage(
                imageUrl: imageURL,
                fit: BoxFit.fitHeight,
                placeholder: (context, url) => Center(
                  child: Image.asset(
                    "assets/images/Group 3 Copy.png",
                    width: double.infinity,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                errorWidget: (context, url, error) => Image.asset(
                  "assets/images/Group 3 Copy.png",
                  fit: BoxFit.fitHeight,
                  width: double.infinity,
                ),
              ),
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        title,
                        maxLines: 2,
                        style: context.theme.textTheme.titleSmall,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    AutoSizeText(
                      "Kroon Kiosk : ${LocaleKeys.tutorials.tr()}",
                      maxLines: 1,
                      style: context.theme.textTheme.bodySmall,
                    ),
                    SizedBox(height: 5.h),
                    AutoSizeText(
                      dateDuration,
                      maxLines: 1,
                      style: context.theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
