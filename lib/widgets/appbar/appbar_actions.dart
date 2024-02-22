part of 'custom_appbar.dart';

class AppBarActions extends StatelessWidget {
  final bool showNewsandPromo;
  final bool showNotifications;

  const AppBarActions({
    Key? key,
    this.showNewsandPromo = true,
    this.showNotifications = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final notificationCount = state.newNotificationCount;
        return Row(
          children: [
            if (showNewsandPromo) _buildNewsPromosButton(context),
            5.w.width,
            if (showNotifications)
              _buildNotificationsButton(notificationCount, context),
            10.w.width,
          ],
        );
      },
    );
  }

  Widget _buildNewsPromosButton(BuildContext context) {
    return AppbarButton(
      child: LocaleKeys.newsPromos.tr(),
      callback: () {
        context.pushView(const PromosAds());
      },
    );
  }

  Widget _buildNotificationsButton(
      int notificationCount, BuildContext context) {
    return AppbarButton(
      showBadge: notificationCount > 0,
      badgeCount: notificationCount,
      child: Image.asset("assets/images/notificationIcon.png"),
      callback: () {
        context.pushView(const Notifications());
      },
    );
  }
}
