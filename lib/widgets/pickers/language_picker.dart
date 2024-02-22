import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Widget languagePicker(BuildContext context,
    Map<String, String> supportedLanguages, String currentLocale) {
  void onTap() {
    Platform.isIOS
        ? showBarModalBottomSheet(
            useRootNavigator: true,
            barrierColor: Colors.black87,
            context: context,
            builder: (context) => Container(
                color: context.theme.canvasColor,
                child: _Body(
                  supportedLanguages: supportedLanguages,
                )),
          )
        : showModalBottomSheet(
            useRootNavigator: true,
            barrierColor: Colors.black87,
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) => Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: context.theme.canvasColor,
                ),
                width: double.infinity,
                child: _Body(
                  supportedLanguages: supportedLanguages,
                )),
          );
  }

  return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Icon(
          Icons.language,
          color: context.theme.colorScheme.onBackground,
        ),
        5.w.width,
        Text(supportedLanguages[currentLocale]!,
            style: Theme.of(context).textTheme.titleMedium!),
        15.w.width,
      ]));
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
    required this.supportedLanguages,
  }) : super(key: key);

  final Map<String, String> supportedLanguages;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Wrap(
          children: [
            5.h.height,
            ...List.generate(supportedLanguages.length, (index) {
              List<Map<String, String>> data = [];
              supportedLanguages.forEach((k, v) => data.add({k: v}));

              final localeData = data[index];

              return ListTile(
                  horizontalTitleGap: 0.2,
                  onTap: () async {
                    await context.setLocale(Locale(localeData.keys
                        .toString()
                        .replaceAll("(", "")
                        .replaceAll(")", "")));
                    context.popView();
                  },
                  leading: const Icon(
                    Icons.language,
                  ),
                  title: Text(
                    localeData.values
                        .toString()
                        .replaceAll("(", "")
                        .replaceAll(")", ""),
                  ));
            }),
            Container(
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
