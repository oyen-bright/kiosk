import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  Box<dynamic> offlineData;
  LocalStorage({required this.offlineData}) {
    // offlineData.delete(storageKeys["UserSettings"]!);
  }

  Future<void> writeData(String key, dynamic value) {
    // log(value.toString(), name: "Write: $key");
    log(key.toString(), name: "LocalStorage Write: $key");
    return offlineData.put(key, value).then((_) {});
  }

  Future<void> deleteAccount() async {
    await Future.wait([userLogout(), removeCurrentUser()]);
  }

  Future<void> userLogout() async {
    await offlineData.deleteAll([
      storageKeys["Token"],
      storageKeys["allSales"],
      storageKeys["UserProdcuts"],
      storageKeys["SalesReport"],
    ]);
  }

  Future<void> removeCurrentUser() async {
    await offlineData.deleteAll([
      storageKeys["UserDetails"],
      storageKeys["offlineCheckout"],
      storageKeys["offlineProdcuts"],
      storageKeys["UserSettings"],
      storageKeys["usersNorification"],
      storageKeys["usersNewsFeed"],
      storageKeys["subscription"],
      storageKeys["paymentMethod"],
    ]);
  }

  dynamic readData(
    String key,
  ) {
    log(key, name: "Local Storage Read: $key");
    return offlineData.get(key);
  }

  Map<String, String> storageKeys = {
    "Token": "Token",
    "UserSettings": "UserSettings",
    "UserDetails": "UserDetails",
    "allSales": "allSales",
    "UserProdcuts": "Product",
    "SalesReport": "Report",
    "TermsContions": "terms",
    "PrivacyPolicy": "privacy",
    "faqs": "faq",
    "offlineCheckout": "checkouts",
    "offlineProdcuts": "products",
    "usersNewsFeed": "notifications_news_feed",
    "usersNorification": "notifications",
    "ifFirstLunch": "firstLunch",
    "subscription": "subState",
    "paymentMethod": "paymentmethod"
  };

  //--------------TOKEN-----------------------------------

  Future<void> writeToken(dynamic data) {
    return writeData(storageKeys["Token"]!, data);
  }

  String? readToken() {
    return readData(storageKeys["Token"]!);
  }

  //--------------SUBSCRIPTION-----------------------------

  Future<void> writeSubscriptionState(dynamic data) {
    return writeData(storageKeys["subscription"]!, data);
  }

  String? readSubscriptionState() {
    return readData(storageKeys["subscription"]!);
  }

  //--------------USER-NEWS_FEED-----------------------------

  Future<void> writeUserNewsFeeds(dynamic data) {
    return writeData(storageKeys["usersNewsFeed"]!, data);
  }

  List<dynamic>? readUserNewsFeeds() {
    return readData(storageKeys["usersNewsFeed"]!);
  }

  //--------------USER-NOTIFICATION-----------------------------

  // Future<void> writeUserNotifications(dynamic data) {
  //   return writeData(storageKeys["usersNorification"]!, data);
  // }

  // List<dynamic>? readUserNotifications() {
  //   return readData(storageKeys["usersNorification"]!);
  // }

  //--------------USER-SETTINGS-----------------------------

  Future<void> writeUserSettings(dynamic data) {
    return writeData(storageKeys["UserSettings"]!, data);
  }

  String? readUserSettings() {
    return readData(storageKeys["UserSettings"]!);
  }

  //--------------PAYMENTMETHOD-----------------------------

  Future<void> writePaymentMethods(dynamic data) {
    return writeData(storageKeys["paymentMethod"]!, data);
  }

  String? readPaymentMethods() {
    return readData(storageKeys["paymentMethod"]!);
  }

  //--------------USER-DETAILS-----------------------------

  Future<void> writeUserDetails(dynamic data) {
    return writeData(storageKeys["UserDetails"]!, data);
  }

  String? readUserDetails() {
    return readData(storageKeys["UserDetails"]!);
  }

  //--------------USER-SALES-----------------------------

  Future<void> writeUserSales(dynamic data) {
    return writeData(storageKeys["allSales"]!, data);
  }

  String? readUserSales() {
    return readData(storageKeys["allSales"]!);
  }

  //--------------USER-PRODUCTS-----------------------------

  Future<void> writeUserProducts(dynamic data) {
    return writeData(storageKeys["UserProdcuts"]!, data);
  }

  String? readUserProducts() {
    return readData(storageKeys["UserProdcuts"]!);
  }

  //--------------USER-SALESREPORT-----------------------------

  Future<void> writeUserSalesReport(dynamic data) {
    return writeData(storageKeys["SalesReport"]!, data);
  }

  String? readUserSalesReport() {
    return readData(storageKeys["SalesReport"]!);
  }

  //--------------PRIVACY-----------------------------
  Future<void> writePrivacyPolicy(dynamic data) {
    return writeData(storageKeys["PrivacyPolicy"]!, data);
  }

  String? readPrivacyPolicy() {
    return readData(storageKeys["PrivacyPolicy"]!);
  }

  //--------------T&C-----------------------------
  Future<void> writeTermsCondition(dynamic data) {
    return writeData(storageKeys["TermsContions"]!, data);
  }

  String? readTermsCondition() {
    return readData(storageKeys["TermsContions"]!);
  }

  //--------------FAQ-----------------------------
  Future<void> writeFAQ(dynamic data) {
    return writeData(storageKeys["faqs"]!, data);
  }

  String? readFAQ() {
    return readData(storageKeys["faqs"]!);
  }

  //-------------FIRSTLUNCH-----------------------------
  Future<void> writeIsFirstLunch(dynamic data) {
    return writeData(storageKeys["ifFirstLunch"]!, data);
  }

  bool? readIsFirstLunch() {
    return readData(storageKeys["ifFirstLunch"]!);
  }

  //--------------Product-----------------------------
  Future<void> writeOfflineProducts(dynamic data) {
    return writeData(storageKeys["offlineProdcuts"]!, data);
  }

  List<dynamic>? readOfflineProducts() {
    return readData(storageKeys["offlineProdcuts"]!);
  }

  void clearOfflineProducts() {
    offlineData.delete(storageKeys["offlineProdcuts"]!);
  }

  //--------------CheckOut-----------------------------
  Future<void> writeOfflineCheckOut(dynamic data) {
    return writeData(storageKeys["offlineCheckout"]!, data);
  }

  List<dynamic>? readOfflineCheckOut() {
    return readData(storageKeys["offlineCheckout"]!);
  }

  void clearOfflineCheckOuts() {
    offlineData.delete(storageKeys["offlineCheckout"]!);
  }
}
