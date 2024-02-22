import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kiosk/models/notification_bloc.dart';

class PushNotificationNot {
  PushNotificationNot({
    this.title,
    this.body,
    this.dataTitle,
    this.dataBody,
  });

  String? title;
  String? body;
  String? dataTitle;
  String? dataBody;
}

class NotificationService {
  /// Use NotificationService as ``NotificationService.instance``
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  bool _started = false;

  void start() {
    if (!_started) {
      _integrateNotification();
      _refreshToken();
      _started = true;
      _handleInitialNotification();
    }
  }

  void _integrateNotification() {
    _registerNotification();
  }

  void _registerNotification() {
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_onResume);
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onLaunch);

    _firebaseMessaging.getToken();
    _firebaseMessaging.onTokenRefresh
        .listen(_tokenRefresh, onError: _tokenRefreshFailure);
  }

  void _refreshToken() {
    _firebaseMessaging
        .getToken()
        .then((token) async {}, onError: _tokenRefreshFailure);
  }

  void _tokenRefresh(String newToken) async {}

  void _tokenRefreshFailure(error) {}

  Future<void> _handleInitialNotification() async {
    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      Map<String, dynamic> params = initialMessage.data;
      if (Platform.isIOS) {
        params = _modifyNotificationJson(params) as Map<String, dynamic>;
      }

      log("NOTIFICATION  _INITIAL_MESSAGE ", name: initialMessage.toString());

      _performActionOnNotification(params);
    }
  }

  Future<void> _onMessage(RemoteMessage message) async {
    Map<String, dynamic> params = message.data;

    if (Platform.isIOS) {
      params = _modifyNotificationJson(params) as Map<String, dynamic>;
    }
    log("NOTIFICATION  _ON_MESSAGE ", name: message.toString());

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        displayOnForeground: true,
        displayOnBackground: false,
        fullScreenIntent: true,
        autoDismissible: false,
        id: createUniqueId(),
        channelKey: 'Kiosk',
        groupKey: 'Kiosk',
        title: message.notification!.title,
        body: message.notification!.body,
        payload: Map.from(params),
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> _onLaunch(RemoteMessage message) async {
    Map<String, dynamic> params = message.data;

    if (Platform.isIOS) {
      params = _modifyNotificationJson(params) as Map<String, dynamic>;
    }
    log("NOTIFICATION  _LAUNCH ", name: message.toString());

    _performActionOnNotification(params);
  }

  Future<void> _onResume(RemoteMessage message) async {
    Map<String, dynamic> params = message.data;
    if (Platform.isIOS) {
      params = _modifyNotificationJson(params) as Map<String, dynamic>;
    }

    log("NOTIFICATION  _RESUME ", name: message.toString());

    _performActionOnNotification(params);
  }

  Map _modifyNotificationJson(Map<String, dynamic> message) {
    // message['data'] = Map.from(message ?? {});
    message['notification'] = message['aps']['alert'];
    return message;
  }

  void _performActionOnNotification(Map<String, dynamic> message) {
    log("NOTIFICATION  ACTION ", name: message.toString());

    NotificationsBloc.instance.newNotification(message);
  }
}
