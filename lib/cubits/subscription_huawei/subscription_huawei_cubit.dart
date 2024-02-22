import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:huawei_iap/huawei_iap.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';
import 'package:kiosk/settings.dart';
import 'package:kiosk/translations/locale_keys.g.dart';

part 'subscription_huawei_state.dart';

class SubscriptionHuaweiCubit extends Cubit<SubscriptionHuaweiState> {
  final LocalStorage localStorage;
  final UserRepository userRepository;
  final UserLoginCubit userLoginCubit;

  /// Constructs a SubscriptionHuaweiCubit.
  ///
  /// [localStorage] is used to read and store subscription state locally.
  ///
  /// [userRepository] provides access to user-related data and actions.
  ///
  /// [userLoginCubit] manages the user's login state and permissions.
  SubscriptionHuaweiCubit({
    required this.localStorage,
    required this.userRepository,
    required this.userLoginCubit,
  }) : super(SubscriptionHuaweiState.initial()) {
    // Load saved subscription state from local storage if available
    final data = localStorage.readSubscriptionState();
    if (data != null) {
      emit(SubscriptionHuaweiState.fromJson(data));
    }

    // Get the current user's subscription ID from UserLoginCubit
    final currentSubscriptionId =
        userLoginCubit.state.userPermissions!.merchantSubscription;

    // Emit the initial state with subscription information
    emit(state.copyWith(
      hasGovernmentSubscription:
          userLoginCubit.state.userPermissions!.hasPromoCode,
      currentSubscription: mapId(currentSubscriptionId),
      currentSubscriptionId: currentSubscriptionId,
    ));

    // Check the environment and load available products
    checkEnvironment().then((value) {
      loadProducts();
    });
  }

  // List of product IDs available for purchase
  final List<String> _kProductIds = <String>[
    "kiosk_plus",
    "kiosk_plus_yearly",
    "kiosk_plus_yearly_gov",
    "kiosk_pro",
    "kiosk_pro_yearly",
  ];

  /// Determine the category of a product based on its ID.
  ///
  /// [productId] is the ID of the product to categorize.
  ///
  /// Returns a string representing the category of the product.
  String getProductIDCategory(String productId) {
    if (_kProductIds.contains(productId)) {
      if (productId == "kiosk_plus" ||
          productId == "kiosk_plus_yearly" ||
          productId == "kiosk_plus_yearly_gov") {
        return "kiosk_plus";
      } else if (productId == "kiosk_pro" || productId == "kiosk_pro_yearly") {
        return "kiosk_pro";
      }
    }
    return "unknown";
  }

  /// Map a subscription type to the corresponding product IDs.
  ///
  /// [type] is the subscription type to map.
  ///
  /// Returns a list of product IDs associated with the subscription type.
  List<String> mapSubscriptionType(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.kioskPlus:
        return state.hasGovernmentSubscription
            ? ["kiosk_plus_yearly_gov"]
            : [
                "kiosk_plus",
                "kiosk_plus_yearly",
              ];
      case SubscriptionType.kioskPro:
        return ["kiosk_pro", "kiosk_pro_yearly"];

      default:
        return [];
    }
  }

  /// Update the promo code status.
  ///
  /// [val] is a boolean indicating whether the promo code is active.
  void updatePromoCode(bool val) {
    emit(state.copyWith(hasGovernmentSubscription: val));
  }

  /// Update the subscription status based on user permissions.
  ///
  /// [userPermissions] is the user's permissions object.
  void updateSubscriptionStatus(Permissions? userPermissions) {
    final currentSubscriptionId = userPermissions!.merchantSubscription;

    emit(state.copyWith(
        currentSubscription: mapId(currentSubscriptionId),
        currentSubscriptionId: currentSubscriptionId));
  }

  /// Map a subscription type to the corresponding ProductInfo objects.
  ///
  /// [type] is the subscription type to map.
  ///
  /// Returns a list of ProductInfo objects associated with the subscription type.
  List<ProductInfo> mapSelectedSubscription(SubscriptionType type) {
    final ids = mapSubscriptionType(type);

    return state.products.where((e) {
      return ids.contains(e.productId);
    }).toList();
  }

  SubscriptionType mapId(String id) {
    switch (id) {
      case "kiosk_plus":
        return SubscriptionType.kioskPlus;
      case "kiosk_plus_yearly":
        return SubscriptionType.kioskPlus;

      case "kiosk_plus_yearly_gov":
        return SubscriptionType.kioskPlus;
      case "kiosk_pro":
        return SubscriptionType.kioskPro;
      case "kiosk_pro_yearly":
        return SubscriptionType.kioskPro;
      default:
        return SubscriptionType.free;
    }
  }

  /// Check if the current user has access to any subscription.
  ///
  /// Returns `true` if the user has a subscription, `false` otherwise.
  bool checkAccess() {
    if (state.currentSubscription == SubscriptionType.free) {
      return false;
    }
    return true;
  }

  /// Check if the current user is a pro user.
  ///
  /// Returns `true` if the user has a Kiosk Pro subscription, `false` otherwise.
  bool isProUser() {
    return state.currentSubscription == SubscriptionType.kioskPro;
  }

  /// Check the environment readiness for in-app purchases.
  ///
  /// This method is called to ensure the environment is ready for
  /// making in-app purchases using the Huawei IAP SDK.
  Future<void> checkEnvironment() async {
    await IapClient.isEnvReady();
  }

  /// Load product information for available subscriptions.
  ///
  /// This method fetches product information for the available
  /// in-app subscriptions from the Huawei IAP SDK and updates the state.
  Future<void> loadProducts() async {
    try {
      emit(state.copyWith(status: StoreStatus.loading));

      // Define a request to fetch product information
      ProductInfoReq request = ProductInfoReq(
          priceType: IapClient.IN_APP_SUBSCRIPTION, skuIds: [..._kProductIds]);

      // Obtain product information using Huawei IAP SDK
      ProductInfoResult result = await IapClient.obtainProductInfo(request);

      if (result.returnCode == "0") {
        emit(state.copyWith(
            status: StoreStatus.storeLoaded, products: result.productInfoList));
        return;
      }

      emit(state.copyWith(
          status: StoreStatus.error, errorMessage: result.errMsg));

      return;
    } on PlatformException catch (e) {
      emit(state.copyWith(
          status: StoreStatus.error, errorMessage: e.toString()));

      return;
    }
  }

  /// Reload the store to fetch the latest product information.
  ///
  /// This method calls [loadProducts] to refresh the store with
  /// the latest product information.
  Future<void> reloadStore() async {
    loadProducts();
  }

  /// Purchase a subscription product using the Huawei IAP SDK.
  ///
  /// This method initiates the purchase of a subscription product and
  /// handles the purchase process including verification and migration.
  /// It updates the state with the purchase status and subscription details.
  ///
  /// Returns a [PurchaseResultInfo] object if the purchase is successful, or `null` otherwise.
  Future<PurchaseResultInfo?> purchaseSubscription(ProductInfo product) async {
    try {
      // Create a purchase intent request
      PurchaseIntentReq req = PurchaseIntentReq(
          priceType: IapClient.IN_APP_SUBSCRIPTION,
          productId: product.productId!,
          developerPayload:
              AppSettings.huaweiInAppSubscriptionTest ? "Test" : null);

      // Create a purchase intent using Huawei IAP SDK
      PurchaseResultInfo res = await IapClient.createPurchaseIntent(req);

      if (res.returnCode == "0") {
        emit(state.copyWith(purchaseStatus: AppPurchaseStatus.verifying));

        // Verify the purchase and obtain subscription token validation response
        final subscriptionTokenValidationResponse = await userRepository
            .verifyPurchase(res.inAppPurchaseData!.purchaseToken!,
                tokenId: res.inAppPurchaseData!.subscriptionId!,
                platform: "huawei");

        if (subscriptionTokenValidationResponse.item1) {
          // Migrate the subscription plan
          final subscriptionPlanMigrationResponse = await userRepository
              .migrateSubscriptionPlan(res.inAppPurchaseData!.purchaseToken!,
                  expDate: subscriptionTokenValidationResponse.item2!,
                  subscriptionId: res.inAppPurchaseData!.subscriptionId,
                  productId:
                      getProductIDCategory(res.inAppPurchaseData!.productId!),
                  yearlyProductID: res.inAppPurchaseData!.productId!,
                  platform: "huawei");

          if (subscriptionPlanMigrationResponse) {
            emit(state.copyWith(
              currentSubscriptionId: res.inAppPurchaseData!.productId,
              currentSubscription: mapId(res.inAppPurchaseData!.productId!),
              purchases: [...state.purchases, res.inAppPurchaseData!],
              purchaseStatus: AppPurchaseStatus.purchased,
            ));

            localStorage.writeSubscriptionState(state.toJson());
            return res;
          } else {
            emit(state.copyWith(
                purchaseStatus: AppPurchaseStatus.invalid,
                errorMessage: LocaleKeys.planMigrationError.tr()));
          }
        } else {
          emit(state.copyWith(
              purchaseStatus: AppPurchaseStatus.invalid,
              errorMessage:
                  subscriptionTokenValidationResponse.item2 ?? res.errMsg));
          return res;
        }
      }

      return null;
    } on PlatformException catch (e) {
      emit(state.copyWith(
          purchaseStatus: AppPurchaseStatus.invalid,
          errorMessage: e.toString()));

      return null;
    }
  }

  /// Restore previously purchased subscriptions for the current user.
  ///
  /// This method retrieves the list of owned subscriptions using the Huawei IAP SDK
  /// and verifies and migrates each valid subscription. It updates the state with
  /// the restored subscription details.
  Future<void> restoreSubscription() async {
    // Obtain the list of owned purchases, specifically in-app subscriptions
    final res = await IapClient.obtainOwnedPurchases(
        OwnedPurchasesReq(priceType: IapClient.IN_APP_SUBSCRIPTION));

    // Check if the operation was successful
    if (res.returnCode != "0") {
      return;
    }

    // Iterate through the list of owned subscriptions
    for (InAppPurchaseData purchase in res.inAppPurchaseDataList!) {
      // Check if the purchase state is 0 (purchased) and if the subscription is valid
      if (purchase.purchaseState == 0 && purchase.subIsvalid!) {
        // Verify the purchase and obtain subscription token validation response
        final subTokenVerificationResponse =
            await userRepository.verifyPurchase(purchase.purchaseToken!,
                tokenId: purchase.subscriptionId!, platform: "huawei");

        // Check if the subscription token is valid
        if (subTokenVerificationResponse.item1) {
          // Migrate the subscription plan
          final subscriptionPlanMigrationResponse = await userRepository
              .migrateSubscriptionPlan(purchase.purchaseToken!,
                  expDate: subTokenVerificationResponse.item2!,
                  productId: getProductIDCategory(purchase.productId!),
                  yearlyProductID: purchase.productId!,
                  platform: "huawei");

          // Check if the subscription plan migration was successful
          if (subscriptionPlanMigrationResponse) {
            // Update the state with the restored subscription details
            emit(state.copyWith(
              currentSubscriptionId: purchase.productId!,
              currentSubscription: mapId(purchase.productId!),
              purchases: [...state.purchases, purchase],
              purchaseStatus: AppPurchaseStatus.purchased,
            ));

            // Save the updated state to local storage
            localStorage.writeSubscriptionState(state.toJson());
          } else {
            emit(state.copyWith(
                purchaseStatus: AppPurchaseStatus.invalid,
                errorMessage: LocaleKeys.planMigrationError.tr()));
          }
        }
      }
    }
  }

  /// Launch the subscription management activity.
  ///
  /// This method is used to start the Huawei IAP subscription management activity.
  /// If [id] is provided, it opens the subscription edit activity for the specified subscription.
  /// If [id] is null, it opens the subscription manager activity.
  ///
  /// This method constructs the necessary request and calls the `startIapActivity` API
  /// to launch the subscription management activity.
  ///
  /// Parameters:
  /// - [id]: The product ID of the subscription to manage (null to open subscription manager).
  Future<void> manageSubscription({String? id}) async {
    // Constructing the request for starting the IAP activity.
    final request = StartIapActivityReq(
      productId: id,
      type: id != null
          ? StartIapActivityReq.TYPE_SUBSCRIBE_EDIT_ACTIVITY
          : StartIapActivityReq.TYPE_SUBSCRIBE_MANAGER_ACTIVITY,
    );

    // Call the startIapActivity API to launch the subscription management activity.
    await IapClient.startIapActivity(request);
  }
}
