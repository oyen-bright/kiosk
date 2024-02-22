import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:group_button/group_button.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/theme/app_theme.dart';
import 'package:kiosk/views/intro/onboarding.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class SelectLanguage extends StatelessWidget {
  const SelectLanguage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            18.h.height,
            Text(
              "Select Language".toUpperCase(),
              style: context.theme.textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            18.h.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Wrap(children: [
                GroupButton(
                  options: groupButtonOption(context,
                      groupingType: GroupingType.column,
                      buttonWidth: double.infinity),
                  buttons: const [
                    "English",
                    "Français",
                    "Español",
                    "Portuguese",
                    "Yorùbá",
                    "Igbo",
                    "Hausa",
                    "Pidgin English"
                  ],
                  onSelected: (index, selected) async {
                    if (selected) {
                      switch (index) {
                        case 0:
                          await context.setLocale(const Locale('en'));
                          break;
                        case 1:
                          await context.setLocale(const Locale('fr'));
                          break;
                        case 2:
                          await context.setLocale(const Locale('es'));
                          break;
                        case 3:
                          await context.setLocale(const Locale('pt'));
                          break;
                        case 4:
                          await context.setLocale(const Locale('yo'));
                          break;
                        case 5:
                          await context.setLocale(const Locale('ig'));
                          break;
                        case 6:
                          await context.setLocale(const Locale('ha'));
                          break;
                        case 7:
                          await context.setLocale(const Locale('pd'));
                          break;
                      }
                      context.pushView(const OnboardingView());
                    }
                  },
                  isRadio: true,
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
