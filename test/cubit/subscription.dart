import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kiosk/cubits/subscription/subscription_cubit.dart';
import 'package:kiosk/models/subscription_state.dart';
import 'package:kiosk/models/user_permissions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

class MockUserRepository extends Mock implements UserRepository {}

class MockUserLoginCubit extends Mock implements UserLoginCubit {}

class MockUserCubit extends Mock implements UserCubit {}

class MockInAppPurchase extends Mock implements InAppPurchase {}

void main() {
  group('SubscriptionCubit', () {
    late SubscriptionCubit subscriptionCubit;
    late MockLocalStorage mockLocalStorage;
    late MockUserRepository mockUserRepository;
    late MockUserLoginCubit mockUserLoginCubit;
    late MockUserCubit mockUserCubit;
    late MockInAppPurchase mockInAppPurchase;

    setUp(() {
      mockLocalStorage = MockLocalStorage();
      mockUserRepository = MockUserRepository();
      mockUserLoginCubit = MockUserLoginCubit();
      mockUserCubit = MockUserCubit();
      mockInAppPurchase = MockInAppPurchase();

      subscriptionCubit = SubscriptionCubit(
        localStorage: mockLocalStorage,
        userRepository: mockUserRepository,
        userLoginCubit: mockUserLoginCubit,
        userCubit: mockUserCubit,
        inAppPurchase: mockInAppPurchase,
      );
    });

    tearDown(() {
      subscriptionCubit.close();
    });

    test('initial state is SubscriptionState.initial()', () {
      expect(subscriptionCubit.state, equals(SubscriptionState.initial()));
    });

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits correct states when subscription is upgraded',
      build: () => subscriptionCubit,
      act: (cubit) {
        final productDetails = ProductDetails(
          id: 'kiosk_plus',
          title: 'Kiosk Plus',
          description: 'Description',
          price: '9.99',
          currencyCode: 'USD',
        );
        cubit.upgradeSubscription(productDetails);
      },
      expect: () => [
        SubscriptionState.initial(status: StoreStatus.loading),
        SubscriptionState.initial(status: StoreStatus.storeLoaded),
        SubscriptionState.initial(
          status: StoreStatus.storeLoaded,
          purchaseStatus: AppPurchaseStatus.verifying,
        ),
      ],
    );
  });

  blocTest<SubscriptionCubit, SubscriptionState>(
    'emits correct states when subscription is upgraded',
    build: () => subscriptionCubit,
    act: (cubit) {
      final productDetails = ProductDetails(
        id: 'kiosk_plus',
        title: 'Kiosk Plus',
        description: 'Description',
        price: '9.99',
        currencyCode: 'USD',
      );
      cubit.upgradeSubscription(productDetails);
    },
    expect: () => [
      SubscriptionState.initial(status: StoreStatus.loading),
      SubscriptionState.initial(status: StoreStatus.storeLoaded),
      SubscriptionState.initial(
        status: StoreStatus.storeLoaded,
        purchaseStatus: AppPurchaseStatus.verifying,
      ),
    ],
  );

  blocTest<SubscriptionCubit, SubscriptionState>(
    'emits correct states when subscription is restored',
    build: () => subscriptionCubit,
    act: (cubit) {
      cubit.restoreSubscription();
    },
    expect: () => [
      SubscriptionState.initial(
        status: StoreStatus.loading,
        purchaseStatus: AppPurchaseStatus.restoring,
      ),
    ],
  );

  blocTest<SubscriptionCubit, SubscriptionState>(
    'emits correct states when purchase details are updated',
    build: () => subscriptionCubit,
    act: (cubit) {
      final purchaseDetails = PurchaseDetails(
        productID: 'kiosk_plus',
        status: PurchaseStatus.purchased,
        transactionDate: DateTime.now(),
        verificationData: PurchaseVerificationData(
          localVerificationData: 'localVerificationData',
          serverVerificationData: 'serverVerificationData',
        ),
      );
      cubit._listenToPurchaseUpdated([purchaseDetails]);
    },
    expect: () => [
      SubscriptionState.initial(
        status: StoreStatus.loading,
        purchaseStatus: AppPurchaseStatus.verifying,
      ),
      SubscriptionState.initial(
        status: StoreStatus.loading,
        purchaseStatus: AppPurchaseStatus.purchased,
        purchases: [purchaseDetails],
      ),
    ],
  );

  blocTest<SubscriptionCubit, SubscriptionState>(
    'emits correct states when subscription is canceled',
    build: () => subscriptionCubit,
    act: (cubit) {
      cubit.cancelSubscription();
    },
    expect: () => [],
  );
}
