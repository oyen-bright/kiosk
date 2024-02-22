import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/notification_service.dart'; // Import the file containing NotificationService
import 'package:mockito/mockito.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  group('NotificationService Tests', () {
    late NotificationService notificationService;
    late MockFirebaseMessaging mockFirebaseMessaging;

    setUp(() {
      mockFirebaseMessaging = MockFirebaseMessaging();
      notificationService = NotificationService();
      notificationService._firebaseMessaging = mockFirebaseMessaging;
    });

    test('start - Firebase messaging integration', () {
      notificationService.start();

      // Verify that requestPermission is called with the correct parameters
      verify(mockFirebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      )).called(1);

      // Verify that Firebase messaging listeners are set up correctly
      verify(mockFirebaseMessaging.getToken()).called(1);
      verify(mockFirebaseMessaging.onTokenRefresh.listen(any)).called(1);
      verify(mockFirebaseMessaging.onMessage.listen(any)).called(1);
      verify(mockFirebaseMessaging.onMessageOpenedApp.listen(any)).called(1);
      verify(FirebaseMessaging.onBackgroundMessage(any)).called(1);
    });
  });
}
