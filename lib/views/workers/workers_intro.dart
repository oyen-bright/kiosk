import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/theme/orange_theme.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/workers/workers.dart';
import 'package:nice_intro/intro_screen.dart';

class WorkersIntro extends StatelessWidget {
  const WorkersIntro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future onDone({bool updateLocalStorage = true}) async {
      if (updateLocalStorage) {
        context.read<UserSettingsCubit>().toggleOnboarding();
      }
      context
          .read<ShowBottomNavCubit>()
          .toggleShowBottomNav(showNav: true, fromm: "Workers");
      context.pushView(const Workers(), replaceView: true);
    }

    List<IntroScreen> pages = [
      IntroScreen(
        title: LocaleKeys.quickAndEasy.tr(),
        imageAsset: 'assets/images/team.png',
        description: LocaleKeys.addWorkersToYourStoreQuickAndEasily.tr(),
        headerBgColor: context.theme.colorScheme.background,
      ),
      IntroScreen(
        title: LocaleKeys.createRemoveAndControl.tr(),
        headerBgColor: context.theme.colorScheme.background,
        imageAsset: 'assets/images/Hiring.png',
        description: LocaleKeys.createRemoveAndControlWorkersPrivileges.tr(),
      ),
    ];
    var onboardingScreen = introScreens(
      context,
      () => onDone(),
      skipText: LocaleKeys.skip.tr(),
      slides: pages,
    );
    return Builder(builder: (context) {
      if (!context.read<UserSettingsCubit>().state.showWorkerIntroScreen) {
        return const Workers();
      }

      context
          .read<ShowBottomNavCubit>()
          .toggleShowBottomNav(showNav: false, fromm: "Workers");
      return Scaffold(
          body: SafeArea(
              top: false, left: false, right: false, child: onboardingScreen));
    });
  }
}
