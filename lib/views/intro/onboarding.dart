import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';
import 'package:kiosk/theme/app_theme.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:nice_intro/nice_intro.dart';

import 'welcome_view.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future onDone() async {
      context.read<LocalStorage>().writeIsFirstLunch(false);
      context.pushView(const WelcomeView(), clearStack: true);
    }

    List<IntroScreen> pages = [
      IntroScreen(
        title: LocaleKeys.quickAndEasy.tr(),
        imageAsset: 'assets/images/intro2.png',
        description: LocaleKeys.secureQRScanningTechnologyForSafe.tr(),
        headerBgColor: context.theme.colorScheme.background,
      ),
      IntroScreen(
        title: LocaleKeys.supportLocal.tr(),
        headerBgColor: context.theme.colorScheme.background,
        imageAsset: 'assets/images/intro3.png',
        description: LocaleKeys.supportsYourLocalInfo.tr(),
      ),
    ];
    var onboardingScreen = introScreens(context, () => onDone(),
        skipText: LocaleKeys.skip.tr(), slides: pages);

    return Scaffold(
        body: SafeArea(
            top: false, left: false, right: false, child: onboardingScreen));
  }
}
