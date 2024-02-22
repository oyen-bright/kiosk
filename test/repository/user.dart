import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/service/user_repository.dart';
import 'package:kiosk/service/user_services.dart';
import 'package:mockito/mockito.dart';

class MockUserServices extends Mock implements UserServices {}

void main() {
  group('UserRepository', () {
    late UserRepository userRepository;
    late MockUserServices mockUserServices;

    setUp(() {
      mockUserServices = MockUserServices();
      userRepository = UserRepository(userServices: mockUserServices);
    });

    test('checkVersion returns version', () async {
      // Arrange
      const String expectedVersion = '1.0.0';
      when(mockUserServices.getKioskVersion())
          .thenAnswer((_) async => expectedVersion);

      // Act
      final result = await userRepository.checkVersion();

      // Assert
      expect(result, equals(expectedVersion));
      verify(mockUserServices.getKioskVersion());
    });

    test('createAccount returns message', () async {
      // Arrange
      const String expectedMessage = 'Account created successfully';
      when(mockUserServices.createUserAccount(payload: anyNamed('payload')))
          .thenAnswer((_) async => expectedMessage);

      // Act
      final result = await userRepository.createAccount(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        gender: 'Male',
        dob: '1990-01-01',
        stateProvince: 1,
        phoneNumber: '1234567890',
        governmentOrganizationName: 'Government Org',
        countryISO2: 'US',
        password: 'password',
      );

      // Assert
      expect(result, equals(expectedMessage));
      verify(mockUserServices.createUserAccount(payload: anyNamed('payload')));
    });

    test('userLogout calls logOutUser', () async {
      // Arrange
      when(mockUserServices.logOUtUser()).thenAnswer((_) async {});

      // Act
      await userRepository.userLogout();

      // Assert
      verify(mockUserServices.logOUtUser());
    });

    test('userLogin returns UsersState', () async {
      // Arrange
      final Map<String, dynamic> mockData = {
        'merchant_business_profle': [],
        'promo_code': true,
        'business_currency': 'USD',
        'merchant_wallet_id': 'wallet_id',
        'merchant_subscription': 'basic',
        'merchant_accept_kroon': false,
        'merchant_role': 'merchant',
      };
      when(mockUserServices.userLogin(
        usersEmail: anyNamed('usersEmail'),
        usersPassword: anyNamed('usersPassword'),
      )).thenAnswer((_) async => mockData);

      // Act
      final result = await userRepository.userLogin(
        usersEmail: 'john@example.com',
        usersPassword: 'password',
      );

      // Assert
      expect(result.status, equals(UserLoginStateStatus.loaded));
      verify(mockUserServices.userLogin(
        usersEmail: 'john@example.com',
        usersPassword: 'password',
      ));
    });

    test('createTransactionPin returns result', () async {
      // Arrange
      const String expectedResponse = 'Transaction PIN created successfully';
      when(mockUserServices.createUsersTransactionPin(any))
          .thenAnswer((_) async => expectedResponse);

      // Act
      final result =
          await userRepository.createTransactionPin(transactionPIn: '1234');

      // Assert
      expect(result, equals(expectedResponse));
      verify(mockUserServices.createUsersTransactionPin('1234'));
    });

    test('changeTransactionPin returns result', () async {
      // Arrange
      const String expectedResponse = 'Transaction PIN changed successfully';
      when(mockUserServices.changeUsersTransactionPin(any, any))
          .thenAnswer((_) async => expectedResponse);

      // Act
      final result = await userRepository.changeTransactionPin(
        oldTransactionPIn: '1234',
        newTransactionPin: '5678',
      );

      // Assert
      expect(result, equals(expectedResponse));
      verify(mockUserServices.changeUsersTransactionPin('1234', '5678'));
    });

    test('getBusinessInformation returns business info', () async {
      // Arrange
      final Map<String, dynamic> expectedResponse = {
        'name': 'Example Business'
      };
      when(mockUserServices.usersBusinessInformation())
          .thenAnswer((_) async => expectedResponse);

      // Act
      final result = await userRepository.getBusinessInformation();

      // Assert
      expect(result, equals(expectedResponse));
      verify(mockUserServices.usersBusinessInformation());
    });

    test('createUserAddress returns result', () async {
      // Arrange
      const String expectedResponse = 'Address created successfully';
      when(mockUserServices.editUserAddress(any, any, any, any, any, any, any,
              id: anyNamed('id')))
          .thenAnswer((_) async => expectedResponse);

      // Act
      final result = await userRepository.createUserAddress(
        type: 'Current Address',
        flatNumber: '123',
        streetName: 'Main St',
        buildingName: 'Example Building',
        state: 'California',
        city: 'Los Angeles',
        zipPostCode: '12345',
      );

      // Assert
      expect(result, equals(expectedResponse));
      verify(mockUserServices.editUserAddress(
        'current',
        '123',
        'Main St',
        'Example Building',
        'California',
        'Los Angeles',
        '12345',
        id: null,
      ));
    });

    test('deleteUserAddress returns result', () async {
      // Arrange
      const String expectedResponse = 'Address deleted successfully';
      when(mockUserServices.deleteUserAddress(id: anyNamed('id')))
          .thenAnswer((_) async => expectedResponse);

      // Act
      final result = await userRepository.deleteUserAddress(id: 'address_id');

      // Assert
      expect(result, equals(expectedResponse));
      verify(mockUserServices.deleteUserAddress(id: 'address_id'));
    });

    test('getAds returns list of ads', () async {
      // Arrange
      final List<Ads> expectedResponse = [
        Ads(title: 'Ad 1'),
        Ads(title: 'Ad 2')
      ];
      when(mockUserServices.ads()).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await userRepository.getAds();

      // Assert
      expect(result, equals(expectedResponse));
      verify(mockUserServices.ads());
    });

    test('dumpOfflineData synchronizes offline data', () async {
      // Arrange
      when(mockUserServices.syncOfflineProducts()).thenAnswer((_) async {});
      when(mockUserServices.syncOfflineCheckOuts()).thenAnswer((_) async {});

      // Act
      await userRepository.dumpOfflineData();

      // Assert
      verify(mockUserServices.syncOfflineProducts());
      verify(mockUserServices.syncOfflineCheckOuts());
    });

    test('deviceId updates device ID', () async {
      // Arrange
      const String deviceId = 'device_id';

      // Act
      await userRepository.deviceId(deviceId: deviceId);

      // Assert
      verify(mockUserServices.refreshDeviceId(deviceId));
    });

    test('deleteAccount deletes user account', () async {
      // Act
      await userRepository.deleteAccount();

      // Assert
      verify(mockUserServices.deleteUsersAccount());
    });

    test('getCountries returns list of countries', () async {
      // Arrange
      final List<Countries> expectedResponse = [
        Countries(name: 'Country 1'),
        Countries(name: 'Country 2')
      ];
      when(mockUserServices.countriesList())
          .thenAnswer((_) async => expectedResponse);

      // Act
      final result = await userRepository.getCountries();

      // Assert
      expect(result, equals(expectedResponse));
      verify(mockUserServices.countriesList());
    });

    test('getCountryStates returns list of states', () async {
      // Arrange
      final List<Map> expectedResponse = [
        {'name': 'State 1'},
        {'name': 'State 2'}
      ];
      when(mockUserServices.getCountryState(any))
          .thenAnswer((_) async => expectedResponse);

      // Act
      final result = await userRepository.getCountryStates('country_id');

      // Assert
      expect(result, equals(expectedResponse));
      verify(mockUserServices.getCountryState('country_id'));
    });

    test('getGovernmentList returns list of government organizations',
        () async {
      // Arrange
      final List<String> expectedResponse = ['Org 1', 'Org 2'];
      when(mockUserServices.getGovernmentOrganizationList()).thenAnswer(
          (_) async => expectedResponse
              .map((e) => {'government_organization': e})
              .toList());

      // Act
      final result = await userRepository.getGovernmentList();

      // Assert
      expect(result, equals(expectedResponse));
      verify(mockUserServices.getGovernmentOrganizationList());
    });

    test('getCountriesAsMap returns map of countries', () async {
      // Arrange
      final Map<String, dynamic> expectedResponse = {
        'country1': 'Country 1',
        'country2': 'Country 2'
      };
      when(mockUserServices.countriesListMap())
          .thenAnswer((_) async => expectedResponse);

      // Act
      final result = await userRepository.getCountriesAsMap();

      // Assert
      expect(result, equals(expectedResponse));
      verify(mockUserServices.countriesListMap());
    });

    test('getNotification returns a list of NewsFeed', () async {
      final newsFeedList = await userRepository.getNotification();
      expect(newsFeedList, isA<List<NewsFeed>>());
    });

    test('updateBusinessLogo returns a string result', () async {
      final result = await userRepository.updateBusinessLogo(
        File('test_image.jpg'),
        businessInformation: {'id': 'test_business_id'},
      );
      expect(result, isA<String>());
    });

    test('createBusinessProfile returns a string result', () async {
      final result = await userRepository.createBusinessProfile(
        {
          'business_name': 'Test Business',
          'business_logo': File('logo.jpg'),
        },
        'test_username',
        'test_password',
      );
      expect(result, isA<String>());
    });

    test('createTransactionPin returns a string result', () async {
      final result = await userRepository.createTransactionPin(
        transactionPIn: '1234',
      );
      expect(result, isA<String>());
    });

    test('changeTransactionPin returns a string result', () async {
      final result = await userRepository.changeTransactionPin(
        oldTransactionPIn: '1234',
        newTransactionPin: '5678',
      );
      expect(result, isA<String>());
    });

    test('getBusinessInformation returns a map', () async {
      final businessInfo = await userRepository.getBusinessInformation();
      expect(businessInfo, isA<Map<String, dynamic>>());
    });

    test('createUserAddress returns a string result', () async {
      final result = await userRepository.createUserAddress(
        type: 'Current Address',
        flatNumber: '123',
        streetName: 'Test Street',
        buildingName: 'Test Building',
        state: 'Test State',
        city: 'Test City',
        zipPostCode: '123456',
      );
      expect(result, isA<String>());
    });

    test('deleteUserAddress returns a string result', () async {
      final result = await userRepository.deleteUserAddress(
        id: 'test_address_id',
      );
      expect(result, isA<String>());
    });

    test('getAds returns a list of Ads', () async {
      final adsList = await userRepository.getAds();
      expect(adsList, isA<List<Ads>>());
    });

    test('dumpOfflineData completes without error', () async {
      await expectLater(userRepository.dumpOfflineData(), completes);
    });

    test('deviceId completes without error', () async {
      await expectLater(
        userRepository.deviceId(deviceId: 'test_device_id'),
        completes,
      );
    });

    test('deleteAccount completes without error', () async {
      await expectLater(userRepository.deleteAccount(), completes);
    });

    test('getCountries returns a list of Countries', () async {
      final countriesList = await userRepository.getCountries();
      expect(countriesList, isA<List<Countries>>());
    });

    test('getCountryStates returns a list of Maps', () async {
      final countryStatesList =
          await userRepository.getCountryStates('test_country_id');
      expect(countryStatesList, isA<List<Map>>());
    });

    test('getGovernmentList returns a list of strings', () async {
      final governmentList = await userRepository.getGovernmentList();
      expect(governmentList, isA<List<String>>());
    });

    test('getCountriesAsMap returns a map', () async {
      final countriesMap = await userRepository.getCountriesAsMap();
      expect(countriesMap, isA<Map<String, dynamic>>());
    });
  });
}
