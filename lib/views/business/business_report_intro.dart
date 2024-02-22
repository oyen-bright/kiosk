import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/theme/orange_theme.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:nice_intro/intro_screen.dart';

import 'business_report.dart';

class BuisnessPlan extends StatelessWidget {
  const BuisnessPlan({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future onDone({bool updateLocalStorage = true}) async {
      if (updateLocalStorage) {
        context
            .read<UserSettingsCubit>()
            .toggleOnboarding(isBusinessPlan: true);
      }
      context
          .read<ShowBottomNavCubit>()
          .toggleShowBottomNav(showNav: true, fromm: "BusinessReport");

      context.pushView(const BusinessReportView(), replaceView: true);
    }

    List<IntroScreen> pages = [
      IntroScreen(
        title: LocaleKeys.generateBusinessReport.tr(),
        imageAsset: 'assets/images/Business_plan.png',
        description:
            LocaleKeys.generateABusinessPlanForYourStoreQuickAndEasily.tr(),
        headerBgColor: context.theme.colorScheme.background,
      ),
      IntroScreen(
        title: LocaleKeys.analyseBusinessPlan.tr(),
        headerBgColor: context.theme.colorScheme.background,
        imageAsset: 'assets/images/analystics.png',
        description: LocaleKeys.analyzeYourBusinessPlanForYourStore.tr(),
      ),
    ];
    var onboardingScreen = introScreens(
      context,
      () => onDone(),
      skipText: LocaleKeys.skip.tr(),
      slides: pages,
    );

    return Builder(builder: (context) {
      if (!context
          .read<UserSettingsCubit>()
          .state
          .showBusinessPlanIntroScreen) {
        return const BusinessReportView();
      }
      context
          .read<ShowBottomNavCubit>()
          .toggleShowBottomNav(showNav: false, fromm: "BusinessReport");

      return WillPopScope(
        onWillPop: () async {
          context
              .read<ShowBottomNavCubit>()
              .toggleShowBottomNav(showNav: true, fromm: "BusinessReport");

          return true;
        },
        child: Scaffold(
            body: SafeArea(
                top: false,
                left: false,
                right: false,
                child: onboardingScreen)),
      );
    });
  }
}
