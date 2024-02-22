import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kiosk/blocs/.blocs.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/service/.services.dart';
import 'package:kiosk/settings.dart';
import 'package:kiosk/theme/orange_theme.dart';
import 'package:kiosk/views/login/login.dart';
import 'package:kiosk/views/navigator/navigation.dart';
import 'package:kiosk/views/select_language/select_language.dart';
import 'package:kiosk/views/update_required/update_required.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'constants/constant_color.dart';
import 'repositories/.repositories.dart';

class StartUp extends StatelessWidget {
  const StartUp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _httpClient = http.Client();
    final _connectivity = Connectivity();
    final _offlineStorage = Hive.box("offlineStorage");
    final _localAuthentication = LocalAuthentication();
    const _storage = FlutterSecureStorage();
    final _analytics = FirebaseAnalytics.instance;
    final _inAppPurchase = InAppPurchase.instance;

    return BlocProvider<InternetCubit>(
      lazy: false,
      create: (context) => InternetCubit(connectivity: _connectivity),
      child: Repositories(
        offlineStorage: _offlineStorage,
        httpClient: _httpClient,
        localAuthentication: _localAuthentication,
        storage: _storage,
        child: Providers(
            child: ScreenUtil(child: SmartRefresh(child:
                BlocBuilder<UserSettingsCubit, UserSettingsState>(
                    builder: (context, state) {
              final _darkmodeEnabled = state.darkMode;
              final _followSystemTheme = state.systemThemeMode;

              return MaterialApp(
                  navigatorObservers: [
                    FirebaseAnalyticsObserver(analytics: _analytics),
                  ],
                  scrollBehavior: const ScrollBehavior()
                      .copyWith(physics: const BouncingScrollPhysics()),
                  localizationsDelegates: [
                    ...GlobalMaterialLocalizations.delegates,
                    const CustomMaterialLocalization(),
                    const CustomCupertinoLocalizationDelegate(),
                    ...context.localizationDelegates,
                  ],
                  // localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  debugShowCheckedModeBanner: false,
                  title: 'KroonKiosk',
                  theme: orangeTheme(context),
                  darkTheme: orangeTheme(context, isDarkMode: true),
                  themeMode: _followSystemTheme
                      ? ThemeMode.system
                      : _darkmodeEnabled
                          ? ThemeMode.dark
                          : ThemeMode.light,
                  home: const Home());
            }))),
            inappPurchase: _inAppPurchase,
            localAuthentication: _localAuthentication,
            storage: _storage),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Future<void> retry(String error) async {
      await nativeAlertDialog(context, error);
      context.read<KioskVersionCubit>().checkKioskVersion();
    }

    return BlocConsumer<KioskVersionCubit, KioskVersionState>(
      listener: (BuildContext context, KioskVersionState state) async {
        final _userCubit = context.read<UserLoginCubit>();
        final _selectAccountCubit = context.read<SelectAccountCubit>();
        final _internetStatus = context.read<InternetCubit>().state.status;
        final _error = state.errorMessage;

        final _offlineMode =
            context.read<UserSettingsCubit>().state.offlineMode;

        if (state.status == KioskVersionStatus.error) {
          if (_internetStatus == InternetStatus.noInternet) {
            if (_offlineMode) {
              try {
                await _userCubit.userLogin(
                    isOfflineLogin: true, usersEmail: "", usersPassword: "");
                await _selectAccountCubit.switchBusinessProfile(id: "");

                context.pushView(const KioskNavigator(), clearStack: true);
              } catch (e) {
                await retry(_error);
              }
            } else {
              await retry(_error);
            }
          } else {
            await retry(_error);
          }
        }
        if (state.status == KioskVersionStatus.loaded &&
            state.updateAvailable) {
          context.pushView(const UpdateRequired(), clearStack: true);
        }
      },
      builder: (context, state) {
        final noUpdate = state.status == KioskVersionStatus.loaded &&
            state.updateAvailable == false;
        final isFirstLunch =
            context.read<LocalStorage>().readIsFirstLunch() == null;

        if (noUpdate) {
          if (isFirstLunch) {
            return const SelectLanguage();
          }

          return const LogIn();
        }
        return const SplashScreen();
      },
    );
  }
}

class ScreenUtil extends StatelessWidget {
  const ScreenUtil({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => SmartRefresh(
        child: child,
      ),
    );
  }
}

class SmartRefresh extends StatelessWidget {
  const SmartRefresh({
    required this.child,
    Key? key,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
        headerBuilder: () => const ClassicHeader(), child: child);
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kioskYellow,
      child: Center(
          child: Image.asset(
        "assets/images/splashIcon.png",
        scale: 4,
      )),
    );
  }
}

class Repositories extends StatelessWidget {
  const Repositories({
    Key? key,
    required this.offlineStorage,
    required this.httpClient,
    required this.localAuthentication,
    required this.storage,
    required this.child,
  }) : super(key: key);

  final Box offlineStorage;
  final http.Client httpClient;
  final LocalAuthentication localAuthentication;
  final FlutterSecureStorage storage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(providers: [
      RepositoryProvider<LocalStorage>(
        lazy: false,
        create: (context) => LocalStorage(offlineData: offlineStorage),
      ),
      RepositoryProvider<UserServices>(
        create: (context) => UserServices(
            httpClient: httpClient,
            internetCubit: context.read<InternetCubit>(),
            localStorage: context.read<LocalStorage>()),
      ),
      RepositoryProvider<UserRepository>(
        create: (context) =>
            UserRepository(userServices: context.read<UserServices>()),
      ),
      RepositoryProvider<ProductRepository>(
        create: (context) =>
            ProductRepository(userServices: context.read<UserServices>()),
      ),
      RepositoryProvider<TransactionRepository>(
        create: (context) =>
            TransactionRepository(userServices: context.read<UserServices>()),
      )
    ], child: child);
  }
}

class Providers extends StatelessWidget {
  const Providers({
    Key? key,
    required this.localAuthentication,
    required this.storage,
    required this.child,
    required this.inappPurchase,
  }) : super(key: key);

  final LocalAuthentication localAuthentication;
  final FlutterSecureStorage storage;
  final Widget child;
  final InAppPurchase inappPurchase;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<UserSettingsCubit>(
          lazy: false,
          create: (context) => UserSettingsCubit(
              localStorage: context.read<LocalStorage>(),
              localAuthentication: localAuthentication)),
      BlocProvider<LoadingCubit>(
        create: (context) => LoadingCubit(),
      ),
      BlocProvider<OfflineCubit>(
        create: (context) => OfflineCubit(
            internetCubit: context.read<InternetCubit>(),
            localStorage: context.read<LocalStorage>(),
            userRepository: context.read<UserRepository>()),
        child: Container(),
      ),
      BlocProvider<KioskVersionCubit>(
        create: (context) => KioskVersionCubit(
            kioskVersionRepository: context.read<UserRepository>()),
      ),
      BlocProvider<ShowBottomNavCubit>(
        create: (context) => ShowBottomNavCubit(),
      ),
      BlocProvider<UserLoginCubit>(
        create: (context) => UserLoginCubit(
            localStorage: context.read<LocalStorage>(),
            flutterSecureStorage: storage,
            userRepository: context.read<UserRepository>()),
      ),
      BlocProvider<SelectAccountCubit>(
        create: (context) => SelectAccountCubit(
          userRepository: context.read<UserRepository>(),
        ),
      ),
      BlocProvider<SalesReportCubit>(
        lazy: false,
        create: (context) => SalesReportCubit(
            userRepository: context.read<UserRepository>(),
            selectAccountCubit: context.read<SelectAccountCubit>()),
      ),
      BlocProvider<UserCubit>(
        lazy: false,
        create: (context) => UserCubit(
            userRepository: context.read<UserRepository>(),
            selectAccountCubit: context.read<SelectAccountCubit>(),
            userLoginCubit: context.read<UserLoginCubit>()),
      ),
      BlocProvider<ProductsCubit>(
        create: (context) => ProductsCubit(
          productRepository: context.read<ProductRepository>(),
        ),
      ),
      BlocProvider<RegisterProductsBloc>(
        create: (context) =>
            RegisterProductsBloc(productsCubit: context.read<ProductsCubit>()),
        child: Container(),
      ),
      BlocProvider<CartBloc>(
        create: (context) => CartBloc(
            salesReportCubit: context.read<SalesReportCubit>(),
            localStorage: context.read<LocalStorage>(),
            productRepository: context.read<ProductRepository>(),
            loadingCubit: context.read<LoadingCubit>(),
            registerProductsBloc: context.read<RegisterProductsBloc>()),
        child: Container(),
      ),
      BlocProvider<AddtocartCubit>(
        create: (context) => AddtocartCubit(cartBloc: context.read<CartBloc>()),
      ),
      BlocProvider<ProductCategoriesCubit>(
        create: (context) => ProductCategoriesCubit(
            productRepository: context.read<ProductRepository>()),
        child: Container(),
      ),
      BlocProvider<AddItemCubit>(
        create: (context) => AddItemCubit(
            loadingCubit: context.read<LoadingCubit>(),
            productRepository: context.read<ProductRepository>()),
        child: Container(),
      ),
      BlocProvider<NotificationCubit>(
        create: (context) => NotificationCubit(
            localStorage: context.read<LocalStorage>(),
            userRepository: context.read<UserRepository>()),
        child: Container(),
      ),
      BlocProvider<PaymentMethodCubit>(
        create: (context) => PaymentMethodCubit(
            userCubit: context.read<UserCubit>(),
            localStorage: context.read<LocalStorage>()),
        child: Container(),
      ),
      BlocProvider<WorkerCubit>(
        create: (context) =>
            WorkerCubit(userRepository: context.read<UserRepository>()),
        child: Container(),
      ),
      BlocProvider<BusinessReportCubit>(
        create: (context) =>
            BusinessReportCubit(userRepository: context.read<UserRepository>()),
        child: Container(),
      ),
      AppSettings.isHuaweiDevice
          ? BlocProvider<SubscriptionHuaweiCubit>(
              create: (context) => SubscriptionHuaweiCubit(
                  userLoginCubit: context.read<UserLoginCubit>(),
                  userRepository: context.read<UserRepository>(),
                  localStorage: context.read<LocalStorage>()),
              child: Container(),
            )
          : BlocProvider<SubscriptionCubit>(
              create: (context) => SubscriptionCubit(
                  userCubit: context.read<UserCubit>(),
                  userLoginCubit: context.read<UserLoginCubit>(),
                  userRepository: context.read<UserRepository>(),
                  inAppPurchase: inappPurchase,
                  localStorage: context.read<LocalStorage>()),
              child: Container(),
            )
    ], child: child);
  }
}

class CustomMaterialLocalization
    extends LocalizationsDelegate<MaterialLocalizations> {
  const CustomMaterialLocalization();

  @override
  bool isSupported(Locale locale) {
    return ['yo', 'ig', 'ha', 'pd'].contains(locale.languageCode);
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return DefaultMaterialLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(CustomMaterialLocalization old) => false;
}

class CustomCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const CustomCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['yo', 'ig', 'ha', 'pd'].contains(locale.languageCode);
  }

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return DefaultCupertinoLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(CustomCupertinoLocalizationDelegate old) => false;
}
