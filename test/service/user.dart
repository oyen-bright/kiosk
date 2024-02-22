import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kiosk/services/user_services.dart';
import 'package:mockito/mockito.dart';

// Mocking http.Client
class MockHttpClient extends Mock implements http.Client {}

// Mocking LocalStorage
class MockLocalStorage extends Mock implements LocalStorage {}

// Mocking InternetCubit
class MockInternetCubit extends Mock implements InternetCubit {}

void main() {
  late UserServices userServices;
  late MockHttpClient mockHttpClient;
  late MockLocalStorage mockLocalStorage;
  late MockInternetCubit mockInternetCubit;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockLocalStorage = MockLocalStorage();
    mockInternetCubit = MockInternetCubit();

    userServices = UserServices(
      internetCubit: mockInternetCubit,
      localStorage: mockLocalStorage,
      httpClient: mockHttpClient,
    );
  });

  test('UserServices instance initialization', () {
    expect(userServices.httpClient, mockHttpClient);
    expect(userServices.localStorage, mockLocalStorage);
    expect(userServices.internetCubit, mockInternetCubit);
  });

  test('resetUsersPassword - success', () async {
    when(mockHttpClient.post(any, body: anyNamed('body'))).thenAnswer(
        (_) async =>
            http.Response('{"message": "Password reset successful"}', 200));

    const email = 'test@example.com';
    const newPassword = 'newPassword123';
    final response = await userServices.resetUsersPassword(
      email: email,
      password: newPassword,
    );

    expect(response, 'Password reset successful');
  });

  test('resetUsersPassword - failure', () async {
    when(mockHttpClient.post(any, body: anyNamed('body')))
        .thenThrow(Exception('Failed to reset password'));

    const email = 'test@example.com';
    const newPassword = 'newPassword123';

    expect(
      () async => await userServices.resetUsersPassword(
          email: email, password: newPassword),
      throwsA(isInstanceOf<Exception>()),
    );
  });

  test('sendUsersFeedback - success', () async {
    when(mockHttpClient.post(any, body: anyNamed('body'))).thenAnswer(
        (_) async =>
            http.Response('{"message": "Feedback sent successfully"}', 200));

    const email = 'test@example.com';
    const subject = 'Test Subject';
    const message = 'Test Message';
    final response = await userServices.sendUsersFeedback(
      email: email,
      subject: subject,
      message: message,
    );

    expect(response, 'Feedback sent successfully');
  });

  test('sendUsersFeedback - failure', () async {
    when(mockHttpClient.post(any, body: anyNamed('body')))
        .thenThrow(Exception('Failed to send feedback'));

    const email = 'test@example.com';
    const subject = 'Test Subject';
    const message = 'Test Message';

    expect(
      () async => await userServices.sendUsersFeedback(
        email: email,
        subject: subject,
        message: message,
      ),
      throwsA(isInstanceOf<Exception>()),
    );
  });

  test('logOUtUser - success', () async {
    when(mockHttpClient.post(any, body: anyNamed('body'))).thenAnswer(
        (_) async =>
            http.Response('{"message": "Logged out successfully"}', 200));

    await userServices.logOUtUser();
  });

  test('logOUtUser - failure', () async {
    when(mockHttpClient.post(any, body: anyNamed('body')))
        .thenThrow(Exception('Failed to log out'));

    expect(
      () async => await userServices.logOUtUser(),
      throwsA(isInstanceOf<Exception>()),
    );
  });

  test('userLogin returns token on successful login', () async {
    when(mockHttpClient.post(any, body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"token": "abc123"}', 200));

    final token = await userServices.userLogin(
      usersEmail: 'test@example.com',
      usersPassword: 'password',
    );

    expect(token, isA<String>());
    expect(token, equals('abc123'));
  });

  test('userLogin stores token in local storage', () async {
    when(mockHttpClient.post(any, body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"token": "abc123"}', 200));

    await userServices.userLogin(
      usersEmail: 'test@example.com',
      usersPassword: 'password',
    );

    verify(mockLocalStorage.writeToken(any)).called(1);
  });

  test('getUserInformation returns user information', () async {
    when(mockHttpClient.get(any)).thenAnswer((_) async =>
        http.Response('{"name": "John", "email": "john@example.com"}', 200));

    final user = await userServices.getUserInformation();

    expect(user.name, equals('John'));
    expect(user.email, equals('john@example.com'));
  });
  test('selectBusinessProfile returns true on successful selection', () async {
    // Mocking the response of getRequest method for selecting business profile
    when(mockHttpClient.getRequest(any))
        .thenAnswer((_) async => http.Response('', 200));

    final result = await userServices.selectBusinessProfile(id: '123');

    expect(result, isTrue);
  });

  test('resetUsersPassword returns message on successful password reset',
      () async {
    // Mocking the response of postRequest method for password reset
    when(mockHttpClient.post(any, body: anyNamed('body'))).thenAnswer(
        (_) async =>
            http.Response('{"message": "Password reset successful"}', 200));

    final message = await userServices.resetUsersPassword(
        email: 'test@example.com', password: 'newpassword');

    expect(message, equals('Password reset successful'));
  });

  test('sendUsersFeedback returns message on successful feedback submission',
      () async {
    // Mocking the response of postRequest method for feedback submission
    when(mockHttpClient.post(any, body: anyNamed('body'))).thenAnswer(
        (_) async => http.Response(
            '{"message": "Feedback submitted successfully"}', 200));

    final message = await userServices.sendUsersFeedback(
      email: 'test@example.com',
      subject: 'Test Subject',
      message: 'Test Message',
    );

    expect(message, equals('Feedback submitted successfully'));
  });
}
