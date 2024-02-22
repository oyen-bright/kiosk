import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart' as bg;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/constant_color.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/user.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/grettings.dart';
import 'package:kiosk/views/Ads/promos_discounts.dart';
import 'package:kiosk/views/notifications/notifications.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

part 'appbar_actions.dart';
part 'appbar_back_button.dart';
part 'appbar_button.dart';

dynamic _buildAppBar(BuildContext context, String? title, List<Widget>? actions,
    String? subTitle, bool showSubtitle,
    {bool showNewsandPromo = true,
    bool showBackArrow = true,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? titleColor,
    void Function()? onTap,
    bool sliverAppbar = false,
    PreferredSizeWidget? bottom,
    bool showNotifications = true}) {
  return sliverAppbar
      ? SliverAppBar(
          floating: true,
          snap: true,
          foregroundColor: foregroundColor,
          backgroundColor:
              backgroundColor ?? context.theme.scaffoldBackgroundColor,
          title: AppBarTitle(
            titleColor: titleColor,
            showSubtitle: showSubtitle,
            title: title,
            subTitle: subTitle,
          ),
          actions: actions ??
              [
                AppBarActions(
                  showNewsandPromo: showNewsandPromo,
                  showNotifications: showNotifications,
                ),
                SizedBox(width: 3.w),
              ],
          leading: showBackArrow
              ? AppBarBackButton(
                  onTap: onTap,
                )
              : Padding(
                  padding: EdgeInsets.only(left: 20.w, top: 0.h, bottom: 0.h),
                  child: const Icon(
                    Icons.store,
                    color: Color.fromRGBO(0, 0, 118, 1),
                    size: 40,
                  ),
                ),
        )
      : AppBar(
          automaticallyImplyLeading: false,
          leadingWidth: 55.w,
          foregroundColor: foregroundColor,
          backgroundColor:
              backgroundColor ?? context.theme.scaffoldBackgroundColor,
          elevation: 0,
          bottom: bottom,
          titleSpacing: showBackArrow ? -10.w : 10.w,
          centerTitle: false,
          title: AppBarTitle(
            titleColor: titleColor,
            showSubtitle: showSubtitle,
            title: title,
            subTitle: subTitle,
          ),
          actions: actions ??
              [
                AppBarActions(
                  showNewsandPromo: showNewsandPromo,
                  showNotifications: showNotifications,
                ),
                SizedBox(width: 3.w),
              ],
          leading: showBackArrow
              ? AppBarBackButton(
                  onTap: onTap,
                )
              : Padding(
                  padding: EdgeInsets.only(left: 20.w, top: 0.h, bottom: 0.h),
                  child: Icon(
                    Icons.store,
                    color: context.theme.colorScheme.primary,
                    size: 40,
                  ),
                ),
        );
}

dynamic customAppBar(BuildContext context,
    {String? title,
    List<Widget>? actions,
    String? subTitle,
    bool showSubtitle = true,
    bool showNewsAndPromo = true,
    bool showBackArrow = true,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? titleColor,
    void Function()? onTap,
    bool sliverAppbar = false,
    PreferredSizeWidget? bottom,
    bool showNotifications = true}) {
  return _buildAppBar(
    context,
    title,
    actions,
    subTitle,
    showSubtitle,
    showNewsandPromo: showNewsAndPromo,
    showBackArrow: showBackArrow,
    foregroundColor: foregroundColor,
    backgroundColor: backgroundColor,
    titleColor: titleColor,
    onTap: onTap,
    sliverAppbar: sliverAppbar,
    bottom: bottom,
    showNotifications: showNotifications,
  );
}

class AppBarTitle extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final bool showSubtitle;
  final Color? titleColor;

  const AppBarTitle({
    Key? key,
    required this.title,
    required this.showSubtitle,
    required this.subTitle,
    this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        final currentUser = state.currentUser!;
        final isOffline = context.watch<OfflineCubit>().state.offlineStatus ==
            OfflineStatus.offlineMode;

        final greetingText = title ?? "${greeting()["Greetings"]}";
        final subtitleText =
            showSubtitle ? _buildSubtitleText(currentUser, isOffline) : null;

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            6.h.height,
            AutoSizeText(
              greetingText.toUpperCase().titleCase,
              style: context.theme.textTheme.titleMedium!
                  .copyWith(fontWeight: FontWeight.bold, color: titleColor),
            ),
            if (subtitleText != null) ...[
              SizedBox(height: 2.h),
              AutoSizeText(subtitleText,
                  style: context.theme.textTheme.titleSmall!
                      .copyWith(color: Colors.grey)),
            ],
            6.h.height,
          ],
        );
      },
    );
  }

  String _buildSubtitleText(User currentUser, bool isOffline) {
    if (subTitle != null) {
      return subTitle!.titleCase;
    }

    final name = currentUser.merchantBusinessName ?? currentUser.name;
    return isOffline
        ? LocaleKeys.offlineMode.tr()
        : LocaleKeys.hi.tr() + ", $name";
  }
}
