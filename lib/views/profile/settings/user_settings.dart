import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/settings/user_settings_cubit.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({Key? key}) : super(key: key);

  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context,
          title: LocaleKeys.settings.tr(),
          showNewsAndPromo: false,
          subTitle: LocaleKeys.profile.tr(),
          showNotifications: false,
          showBackArrow: true),
      body: BlocBuilder<UserSettingsCubit, UserSettingsState>(
        builder: (context, state) {
          final offlineMode = state.offlineMode;
          final loginWithBio = state.loginWithBiometrics;
          final darkMode = state.darkMode;
          final lightMode = state.lightMode;
          final systemTheme = state.systemThemeMode;
          return ListView(
            children: [
              20.h.height,
              SecurityWidget(
                title: LocaleKeys.security.tr(),
                children: [
                  5.h.height,
                  SettingsTile(
                    LocaleKeys.autoLoginWithBiometric.tr(),
                    onChanged: (_) {
                      context
                          .read<UserSettingsCubit>()
                          .toggleLoginWithBiometrics();
                    },
                    onTap: () {
                      context
                          .read<UserSettingsCubit>()
                          .toggleLoginWithBiometrics();
                    },
                    isToggled: loginWithBio,
                    icon: Icons.fingerprint,
                  ),
                  SettingsTile(
                    LocaleKeys.offlineMode.tr(),
                    onChanged: (_) {
                      context.read<UserSettingsCubit>().toggleOfflineMode();
                    },
                    onTap: () {
                      context.read<UserSettingsCubit>().toggleOfflineMode();
                    },
                    isToggled: offlineMode,
                    icon: Icons.fingerprint,
                  ),
                  5.h.height,
                ],
              ),
              10.h.height,
              SecurityWidget(
                title: LocaleKeys.theme.tr(),
                children: [
                  5.h.height,
                  SettingsTile(
                    LocaleKeys.darkMode.tr(),
                    onChanged: (_) {
                      context
                          .read<UserSettingsCubit>()
                          .toggleTheme(ThemeMode.dark);
                    },
                    onTap: () {
                      context
                          .read<UserSettingsCubit>()
                          .toggleTheme(ThemeMode.dark);
                    },
                    isToggled: darkMode,
                    icon: Icons.dark_mode,
                  ),
                  SettingsTile(
                    LocaleKeys.lightMode.tr(),
                    onChanged: (_) {
                      context
                          .read<UserSettingsCubit>()
                          .toggleTheme(ThemeMode.light);
                    },
                    onTap: () {
                      context
                          .read<UserSettingsCubit>()
                          .toggleTheme(ThemeMode.light);
                    },
                    isToggled: lightMode,
                    icon: Icons.light_mode,
                  ),
                  SettingsTile(
                    LocaleKeys.sameAsSystem.tr(),
                    onChanged: (_) {
                      context
                          .read<UserSettingsCubit>()
                          .toggleTheme(ThemeMode.system);
                    },
                    onTap: () {
                      context
                          .read<UserSettingsCubit>()
                          .toggleTheme(ThemeMode.system);
                    },
                    isToggled: systemTheme,
                    icon: Icons.schedule,
                  ),
                  5.h.height,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class SecurityWidget extends StatelessWidget {
  final List<Widget> children;
  final String title;

  const SecurityWidget({
    Key? key,
    required this.children,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 2.h),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        CustomContainer(
          alignment: Alignment.center,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 5.h),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
