import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;

class AnalyticsService {
  FirebaseAnalytics analytics;
  AnalyticsService({required this.analytics});

  Future<void> logNavigationEvent({required String screenName}) async {
    await analytics.setCurrentScreen(
      screenName: screenName,
    );

    await analytics.logEvent(
      name: 'screen_view',
      parameters: <String, dynamic>{
        'screen_name': screenName,
      },
    );
  }

  Future<void> logLoginEvent() async {
    await analytics.logLogin(loginMethod: "Email");
  }

  Future<void> logVirtualCardClicked() async {
    await analytics.logEvent(name: "virtual_card_clicked");
  }

  Future<void> logCartCheckout(Map<String, dynamic> params) async {
    await analytics.logEvent(
      name: 'cart_checkout',
      parameters: params,
    );
  }

  Future<void> logNewsFeedClicked(Map<String, dynamic> params) async {
    await analytics.logEvent(
      name: 'newsfeed_clicked',
      parameters: params,
    );
  }

  Future<void> logAdsClicked(Map<String, dynamic> params) async {
    await analytics.logEvent(
      name: 'ads_clicked',
      parameters: params,
    );
  }

  Future<void> logOpenCashRegister(Map<String, dynamic> params) async {
    await analytics.logEvent(
      name: 'open_register',
      parameters: params,
    );
  }

  Future<void> logOpenSalesReport() async {
    await analytics.logEvent(
      name: 'open_salesreport',
      parameters: {},
    );
  }

  Future<void> logOpenStockReport() async {
    await analytics.logEvent(
      name: 'open_stockreport',
      parameters: {},
    );
  }

  Future<void> logCheckFAQ() async {
    await analytics.logEvent(
      name: 'check_faq',
      parameters: {},
    );
  }

  Future<void> logLogOut() async {
    await analytics.logEvent(
      name: 'Log_Out',
      parameters: {},
    );
  }

  Future<void> logCheckInventory(Map<String, dynamic> params) async {
    await analytics.logEvent(
      name: 'check_inventory',
      parameters: params,
    );
  }

  Future<void> logSaleMade(Map<String, dynamic> params) async {
    await analytics.logEvent(
      name: 'sale_made',
      parameters: params,
    );
  }

  Future<void> logProductUpload(Map<String, dynamic> params) async {
    await analytics.logEvent(
      name: 'product_uploaded',
      parameters: params,
    );
  }

  Future<void> logInAppSub(Map<String, dynamic> params) async {
    await analytics.logEvent(
      name: 'inapp_sub',
      parameters: params,
    );
  }

  Future<void> logAppOpen() async {
    await analytics.logAppOpen();
  }

  Future<void> logSignUp() async {
    await analytics.logSignUp(signUpMethod: "email");
  }

  Future<void> logShare(
      String contentTyoe, String itemId, String method) async {
    await analytics.logShare(
        contentType: contentTyoe, itemId: itemId, method: method);
  }

  Future<void> logTutorialBegin() async {
    await analytics.logTutorialBegin();
  }

  Future<void> logTutorialComplete() async {
    await analytics.logTutorialComplete();
  }

  Future logAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;

    await analytics.setUserProperty(name: "app_version", value: appVersion);
  }

  Future logDeviceModel() async {
    String deviceModel = Platform.operatingSystem;

    await analytics.setUserProperty(
      name: 'device_model',
      value: deviceModel,
    );
  }
}
