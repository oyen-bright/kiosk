import 'dart:async';

import 'package:badges/badges.dart' as bg;
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/blocs/.blocs.dart';
import 'package:kiosk/constants/.constants.dart' as k;
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/notification_bloc.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/settings.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/cart/cart.dart';
import 'package:kiosk/views/home/home.dart';
import 'package:kiosk/views/inventory/inventory.dart';
import 'package:kiosk/views/profile/profile.dart';
import 'package:kiosk/views/virtual_card/cards.dart';
import 'package:kiosk/widgets/dialogs/enable_notification_dialog.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';
import 'package:url_launcher/url_launcher.dart';

class KioskNavigator extends StatefulWidget {
  const KioskNavigator({Key? key}) : super(key: key);

  @override
  State<KioskNavigator> createState() => _KioskNavigatorState();
}

class _KioskNavigatorState extends State<KioskNavigator> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // _actionSubscription = AwesomeNotifications()
    //     .actionStream
    //     .asBroadcastStream()
    //     .listen((receivedNotification) {
    //   print(receivedNotification.payload);
    //   if (receivedNotification.channelKey == 'Kiosk') {
    //     if (receivedNotification.payload != null) {
    //       if (receivedNotification.payload!.containsKey('link')) {
    //         launchUrl(Uri.parse(receivedNotification.payload!['link']!),
    //             mode: LaunchMode.inAppWebView);
    //       } else {}
    //     }
    //   }
    // });

    final isNotificationEnabled =
        context.read<UserSettingsCubit>().state.notificationEnabled;

    if (AppSettings.isHuaweiDevice) {
      context.read<SubscriptionHuaweiCubit>().updateSubscriptionStatus(
          context.read<UserLoginCubit>().state.userPermissions);
    } else {
      context.read<SubscriptionCubit>().updateSubscriptionStatus(
          context.read<UserLoginCubit>().state.userPermissions);
    }

    if (isNotificationEnabled == null) {
      checkAndRequestNotificationPermissions(_firebaseMessaging);
    }
    _firebaseMessaging.getToken().then((token) {
      if (token != null) {
        context.read<UserRepository>().deviceId(deviceId: token);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void performActionOnNotification(Map<String, dynamic> data) {
    if (data.containsKey('link')) {
      launchUrl(Uri.parse(data['link']), mode: LaunchMode.inAppWebView);
    } else {}
  }

  Future<void> checkAndRequestNotificationPermissions(
      FirebaseMessaging _firebaseMessaging) async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      enableNotificationDialog(context);
    }
  }

  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      const KioskHome(),
      const Inventory(),
      const Cart(),
      const Cards(),
      const Profile()
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(int cartCount) {
    final kioskBlue = context.theme.colorScheme.primary;
    return [
      PersistentBottomNavBarItem(
        icon: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ImageIcon(
                const AssetImage("assets/images/home_bottom_nav.png"),
                color: kioskBlue,
              ),
            ),
            2.5.h.height,
            Material(
              child: Text(
                LocaleKeys.home.tr(),
                style: TextStyle(
                    fontSize: 10.sp, color: CupertinoColors.systemGrey),
              ),
            )
          ],
        ),
        inactiveIcon: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Expanded(
              child: ImageIcon(
                AssetImage("assets/images/home_bottom_nav.png"),
                color: CupertinoColors.systemGrey,
              ),
            ),
            2.5.h.height,
            Material(
              child: Text(
                LocaleKeys.home.tr(),
                style: TextStyle(
                    fontSize: 10.sp, color: CupertinoColors.systemGrey),
              ),
            )
          ],
        ),
        activeColorPrimary: kioskBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ImageIcon(
                const AssetImage("assets/images/inventory_bottom_nav.png"),
                color: kioskBlue,
              ),
            ),
            2.5.h.height,
            Material(
              child: Text(
                LocaleKeys.inventory.tr(),
                style: TextStyle(
                    fontSize: 10.sp, color: CupertinoColors.systemGrey),
              ),
            )
          ],
        ),
        inactiveIcon: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Expanded(
              child: ImageIcon(
                AssetImage("assets/images/inventory_bottom_nav.png"),
                color: CupertinoColors.systemGrey,
              ),
            ),
            2.5.h.height,
            Material(
              child: Text(
                LocaleKeys.inventory.tr(),
                style: TextStyle(
                    fontSize: 10.sp, color: CupertinoColors.systemGrey),
              ),
            )
          ],
        ),
        activeColorPrimary: const Color(0xFF0000BC),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Builder(builder: (context) {
          final count = context.watch<CartBloc>().state.cartCounter;
          if (count == 0) {
            return Icon(
              Icons.shopping_cart,
              color: k.kioskBlue,
              size: 30.r,
            );
          }

          return bg.Badge(
            badgeColor: context.theme.colorScheme.primary,
            badgeContent: Text(count.toString(),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            child: Icon(
              Icons.shopping_cart,
              color: k.kioskBlue,
              size: 30.r,
            ),
          );
        }),
        inactiveIcon: Builder(builder: (context) {
          final count = context.watch<CartBloc>().state.cartCounter;

          if (count == 0) {
            return Icon(
              Icons.shopping_cart,
              color: CupertinoColors.systemGrey,
              size: 30.r,
            );
          }
          return bg.Badge(
            badgeColor: context.theme.colorScheme.primary,
            badgeContent: Text(count.toString(),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            child: Icon(
              Icons.shopping_cart,
              color: CupertinoColors.systemGrey,
              size: 25.r,
            ),
          );
        }),
        title: (LocaleKeys.cart.tr()),
        activeColorPrimary: const Color(0xFFF8C130),
        activeColorSecondary: kioskBlue,
        textStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ImageIcon(
                const AssetImage("assets/images/card_bottom_nav.png"),
                color: kioskBlue,
              ),
            ),
            2.5.h.height,
            Material(
              child: Text(
                LocaleKeys.cards.tr(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                    color: CupertinoColors.systemGrey),
              ),
            )
          ],
        ),
        inactiveIcon: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Expanded(
              child: ImageIcon(
                AssetImage("assets/images/card_bottom_nav.png"),
                color: CupertinoColors.systemGrey,
              ),
            ),
            2.5.h.height,
            Material(
              child: Text(
                LocaleKeys.cards.tr(),
                style: TextStyle(
                    fontSize: 10.sp,
                    color: CupertinoColors.systemGrey,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        activeColorSecondary: CupertinoColors.activeBlue,
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ImageIcon(
                const AssetImage("assets/images/profile_bottom_nav.png"),
                color: kioskBlue,
              ),
            ),
            2.5.h.height,
            Material(
              child: Text(
                LocaleKeys.profile.tr(),
                maxLines: 2,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                    color: CupertinoColors.systemGrey),
              ),
            )
          ],
        ),
        inactiveIcon: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Expanded(
              child: ImageIcon(
                AssetImage("assets/images/profile_bottom_nav.png"),
                color: CupertinoColors.systemGrey,
              ),
            ),
            2.5.h.height,
            Material(
              child: Text(
                LocaleKeys.profile.tr(),
                maxLines: 2,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                    color: CupertinoColors.systemGrey),
              ),
            )
          ],
        ),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  Widget build(BuildContext contextN) {
    var counter = 0;

    return StreamBuilder<Map<String, dynamic>>(
        stream: NotificationsBloc.instance.notificationStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> notificationData = snapshot.data!;

            performActionOnNotification(notificationData);
          }

          return _Providers(
              child: _OfflineListener(
            contextN,
            child: ShowCaseWidget(
              blurValue: 1,
              onFinish: () {
                context
                    .read<ShowBottomNavCubit>()
                    .toggleShowBottomNav(showNav: true, fromm: "Navigation");
              },
              autoPlayDelay: const Duration(seconds: 3),
              builder: Builder(builder: (context) {
                final loadingCubitStatus =
                    context.watch<LoadingCubit>().state.status;
                final showBottomNav =
                    context.watch<ShowBottomNavCubit>().state.showNav;

                final showNav =
                    loadingCubitStatus == Status.loading || !showBottomNav;

                return PersistentTabView(
                  context,
                  controller: _controller,
                  hideNavigationBar: showNav,
                  screens: _buildScreens(),
                  items: _navBarsItems(counter),
                  confineInSafeArea: true,
                  navBarHeight: 65.h,
                  backgroundColor: context
                      .theme.colorScheme.background, // Default is Colors.white.
                  handleAndroidBackButtonPress: true, // Default is true.
                  resizeToAvoidBottomInset:
                      true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
                  stateManagement: false, // Default is true.
                  hideNavigationBarWhenKeyboardShows:
                      true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
                  decoration: NavBarDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    colorBehindNavBar: context.theme.scaffoldBackgroundColor,
                  ),
                  popAllScreensOnTapOfSelectedTab: true,
                  popActionScreens: PopActionScreensType.all,
                  itemAnimationProperties: const ItemAnimationProperties(
                    // Navigation Bar's items animation properties.
                    duration: Duration(milliseconds: 200),
                    curve: Curves.ease,
                  ),
                  screenTransitionAnimation: const ScreenTransitionAnimation(
                    // Screen transition animation on change of selected tab.
                    animateTabTransition: true,
                    curve: Curves.ease,
                    duration: Duration(milliseconds: 200),
                  ),
                  navBarStyle: NavBarStyle
                      .style15, // Choose the nav bar style with this property.
                );
              }),
            ),
          ));
        });
  }
}

class _Providers extends StatelessWidget {
  const _Providers({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartRegisterProductBloc>(
            lazy: false,
            create: (context) => CartRegisterProductBloc(
                registerProductsBloc: context.read<RegisterProductsBloc>(),
                cartBloc: context.read<CartBloc>())),
        BlocProvider<SalesCubit>(
          lazy: false,
          create: (context) =>
              SalesCubit(userRepository: context.read<UserRepository>()),
          child: Container(),
        ),
        BlocProvider<StockReportCubit>(
          lazy: false,
          create: (context) => StockReportCubit(
              registerProductsBloc: context.read<RegisterProductsBloc>(),
              salesReportCubit: context.read<SalesReportCubit>()),
          child: Container(),
        ),
      ],
      child: child,
    );
  }
}

class _OfflineListener extends StatelessWidget {
  const _OfflineListener(
    this.contextN, {
    required this.child,
  });
  final Widget child;
  final BuildContext contextN;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OfflineCubit, OfflineState>(
      listener: (context, state) {
        switch (state.offlineStatus) {
          case OfflineStatus.isSyncing:
            contextN.showBanner(
              isSyncing: true,
            );

            break;
          case OfflineStatus.isSynced:
            contextN.showBanner(
              syncDone: true,
            );
            context.read<ProductsCubit>().getUsersProducts();
            context.read<SalesCubit>().loadSales();
            context.read<SalesReportCubit>().getSaleReport();
            break;
          case OfflineStatus.error:
            contextN.showBanner(
                errorSync: true, errorMessage: state.errorMessage);

            break;
          case OfflineStatus.connected:
            ScaffoldMessenger.of(contextN).removeCurrentMaterialBanner();
            break;
          case OfflineStatus.offlineMode:
            contextN.showBanner();
            break;
          case OfflineStatus.initial:
            break;
          default:
        }
      },
      child: child,
    );
  }
}
