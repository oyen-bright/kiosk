import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kiosk/app.dart';
import 'package:kiosk/observer/bloc_observer.dart';
import 'package:kiosk/service/.services.dart';

import 'constants/constant_color.dart';
import 'translations/codegen_loader.g.dart';

void main() async {
  runZonedGuarded(
    () async {
      // await Util.checkIfDateIsInitialized();
      GoogleFonts.config.allowRuntimeFetching = true;

      await Hive.initFlutter();
      await Future.wait([
        EasyLocalization.ensureInitialized(),
        GetStorage.init(),
        Firebase.initializeApp(),
        Hive.openBox('offlineStorage'),
        dotenv.load(fileName: ".env")
      ]);

      HttpOverrides.global = MyHttpOverrides();
      NotificationService.instance.start();
      Bloc.observer = AppBlocObserver();
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      awesomeNotificationInitialization();

      runApp(EasyLocalization(
          path: 'assets/translations',
          useOnlyLangCode: true,
          supportedLocales: const [
            Locale("en"),
            Locale("fr"),
            Locale("es"),
            Locale("pt"),
            Locale("ha"),
            Locale("ig"),
            Locale("yo"),
            Locale("pd")
          ],
          fallbackLocale: const Locale('en', 'US'),
          assetLoader: const CodegenLoader(),
          child: const StartUp()));
    },
    (Object error, StackTrace stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}

//Awesome NotificationInitialization
void awesomeNotificationInitialization() {
  AwesomeNotifications().initialize(
      "resource://drawable/ic_stat_kroon_icon_blue",
      [
        NotificationChannel(
            channelGroupKey: 'Kiosk',
            channelKey: 'Kiosk',
            channelName: 'Kiosk Notifications',
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
            importance: NotificationImportance.High,
            channelDescription: 'Kiosk Notifications',
            defaultColor: kioskYellow,
            ledColor: Colors.black)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);
}

//Http Overrides for badCertificates *Andriod phones
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
