import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/service/.services.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:url_launcher/url_launcher.dart';

part 'subscription_state.dart';

/// Manages the subscription state and purchases for the application.
///
/// This [Cubit] is responsible for managing the subscription state, including
/// handling in-app purchases, restoring subscriptions, and updating the state
/// based on user permissions.
class SubscriptionCubit extends Cubit<SubscriptionState> {
  final LocalStorage localStorage;
  final UserRepository userRepository;
  final UserLoginCubit userLoginCubit;
  final UserCubit userCubit;
  final InAppPurchase inAppPurchase;

  late final StreamSubscription<List<PurchaseDetails>> _subscription;
  late final Stream<List<PurchaseDetails>> purchaseUpdated;

  /// Initialize the [SubscriptionCubit] with required dependencies.
  ///
  /// This constructor sets up the [SubscriptionCubit] with the necessary dependencies,
  /// initializes the subscription state from local storage if available, and sets up
  /// listeners for in-app purchase updates.
  ///
  /// Parameters:
  /// - [localStorage]: Local storage for storing subscription state.
  /// - [inAppPurchase]: Plugin for handling in-app purchases.
  /// - [userCubit]: The [UserCubit] for managing user-related states.
  /// - [userLoginCubit]: The [UserLoginCubit] for managing user login states.
  /// - [userRepository]: The repository for user-related data.
  SubscriptionCubit({
    required this.localStorage,
    required this.inAppPurchase,
    required this.userCubit,
    required this.userLoginCubit,
    required this.userRepository,
  }) : super(SubscriptionState.initial()) {
    // 1. Load Subscription State from Local Storage
    final data = localStorage.readSubscriptionState();
    if (data != null) {
      emit(SubscriptionState.fromJson(data));
    }

    // 2. Set Up Purchase Updates Stream
    purchaseUpdated = inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      emit(state.copyWith(
          purchaseStatus: AppPurchaseStatus.error,
          errorMessage: error.toString()));
    });

    // 3. Initialize Current Subscription Information
    final currentSubscriptionId =
        userLoginCubit.state.userPermissions!.merchantSubscription;

    emit(state.copyWith(
        hasGovernmentSubscription:
            userLoginCubit.state.userPermissions!.hasPromoCode,
        currentSubscription: mapId(currentSubscriptionId),
        currentSubscriptionId: currentSubscriptionId));

    // 4. Initialize Store Information (Products)
    initStoreInfo(_kProductIds);

    // 5. Restore Subscriptions on Android
    if (Platform.isAndroid) {
      restoreSubscription();
    }
  }

  /// List of product IDs for available subscriptions.
  final List<String> _kProductIds = <String>[
    "kiosk_plus",
    "kiosk_plus_yearly",
    "kiosk_plus_yearly_gov",
    "kiosk_pro",
    "kiosk_pro_yearly",
  ];

  /// Determine the category of a subscription product based on its ID.
  ///
  /// Returns the category of the product, such as "kiosk_plus" or "kiosk_pro",
  /// or "unknown" if the product ID is not found in the list.
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

  /// Map a subscription ID to a [SubscriptionType] enum.
  ///
  /// Returns a [SubscriptionType] enum based on the provided subscription ID.
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
      case "basic":
        return SubscriptionType.free;
      default:
        return SubscriptionType.free;
    }
  }

  /// Check if the current subscription allows access.
  ///
  /// Returns `true` if access is allowed, `false` otherwise.
  bool checkAccess() {
    if (state.currentSubscription == SubscriptionType.free) {
      return false;
    }
    return true;
  }

  /// Check if the user has a Kiosk Pro subscription.
  ///
  /// Returns `true` if the user has a Kiosk Pro subscription, `false` otherwise.
  bool isProUser() {
    return state.currentSubscription == SubscriptionType.kioskPro;
  }

  /// Check if the user is an Apple test account.
  ///
  /// Returns `true` if the user's email matches the Apple test account email,
  /// `false` otherwise.
  bool isAppleTestAccount() {
    return userCubit.state.currentUser?.email == "applekiosk@kroonapp.com";
  }

  /// Map a [SubscriptionType] to a list of product IDs.
  ///
  /// Returns a list of product IDs corresponding to the provided [SubscriptionType].
  List<String> mapSubscriptionType(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.kioskPlus:
        if (isAppleTestAccount()) {
          return ["kiosk_plus", "kiosk_plus_yearly", "kiosk_plus_yearly_gov"];
        }
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

  /// Map a [SubscriptionType] to a list of product details.
  ///
  /// Returns a list of [ProductDetails] corresponding to the provided [SubscriptionType].
  List<ProductDetails> mapSelectedSubscription(SubscriptionType type) {
    final ids = mapSubscriptionType(type);

    return state.products.where((e) {
      return ids.contains(e.id);
    }).toList();
  }

  /// Update the promo code status in the state.
  ///
  /// [val]: The new promo code status value.
  void updatePromoCode(bool val) {
    emit(state.copyWith(hasGovernmentSubscription: val));
  }

  /// Update the current subscription status in the state.
  ///
  /// [userPermissions]: The user's permissions object.
  void updateSubscriptionStatus(Permissions? userPermissions) {
    final currentSubscriptionId = userPermissions!.merchantSubscription;

    emit(state.copyWith(
        currentSubscription: mapId(currentSubscriptionId),
        currentSubscriptionId: currentSubscriptionId));
  }

  /// Initialize store information and product details.
  ///
  /// [productIds]: List of product IDs to query.
  Future<void> initStoreInfo(List<String> productIds) async {
    // Set the state to loading while initializing the store.
    emit(state.copyWith(status: StoreStatus.loading));

    // Check if in-app purchases are available on the device.
    final bool isAvailable = await inAppPurchase.isAvailable();

    if (!isAvailable) {
      // If in-app purchases are not available, update the state accordingly.
      emit(state.copyWith(status: StoreStatus.storeUnavailable));
      return;
    }

    // Query product details for the specified product IDs.
    final ProductDetailsResponse productDetailResponse =
        await inAppPurchase.queryProductDetails(productIds.toSet());

    if (productDetailResponse.error != null) {
      // Handle any errors that occur during product detail retrieval.
      emit(state.copyWith(
          status: StoreStatus.error,
          errorMessage: productDetailResponse.error!.message));
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      // If no product details are retrieved, update the state to indicate
      // that the store is unavailable.
      emit(state.copyWith(status: StoreStatus.storeUnavailable));
      return;
    }

    // Update the state with the loaded product details.
    emit(state.copyWith(
        status: StoreStatus.storeLoaded,
        products: productDetailResponse.productDetails));
  }

  /// Reload store information using predefined product IDs.
  void reloadStore() {
    initStoreInfo(_kProductIds);
  }

  /// Complete a purchase by providing purchase details.
  ///
  /// [purchase]: The purchase details to complete.
  void completePurchase(PurchaseDetails purchase) {
    inAppPurchase.completePurchase(purchase);
  }

  /// Listen to updates in purchase details and handle accordingly.
  ///
  /// [purchaseDetailsList]: List of updated purchase details.
  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      try {
        // Check if the purchase is pending (awaiting confirmation).
        if (purchaseDetails.status == PurchaseStatus.pending) {
          emit(state.copyWith(purchaseStatus: AppPurchaseStatus.pending));
        }
        // Check if the purchase was canceled.
        else if (purchaseDetails.status == PurchaseStatus.canceled) {
          emit(state.copyWith(purchaseStatus: AppPurchaseStatus.cancelled));

          // If the purchase requires pending completion, do so.
          if (purchaseDetails.pendingCompletePurchase) {
            await inAppPurchase.completePurchase(purchaseDetails);
            return;
          }
        }
        // Handle successful purchases or restores.
        else {
          // Handle purchases that resulted in an error.
          if (purchaseDetails.status == PurchaseStatus.error) {
            _handleError(purchaseDetails);
          }
          // Process successful purchases and restores.
          else if (purchaseDetails.status == PurchaseStatus.purchased ||
              purchaseDetails.status == PurchaseStatus.restored) {
            emit(state.copyWith(purchaseStatus: AppPurchaseStatus.verifying));

            // If the purchase matches the current subscription, update state.
            if (state.currentSubscriptionId == purchaseDetails.productID) {
              emit(state.copyWith(
                  purchaseStatus: AppPurchaseStatus.purchased,
                  purchases: [...state.purchases, purchaseDetails]));
              return;
            }

            // Verify the purchase token with the backend.
            final subTokenVerificationResponse =
                await userRepository.verifyPurchase(
                    purchaseDetails.verificationData.serverVerificationData,
                    tokenId: purchaseDetails.productID,
                    platform: getSubscriptionPlatform());

            if (subTokenVerificationResponse.item1) {
              // Migrate the subscription plan based on the purchase.
              final subscriptionPlanMigrationResponse =
                  await userRepository.migrateSubscriptionPlan(
                      purchaseDetails.verificationData.serverVerificationData,
                      productId:
                          getProductIDCategory(purchaseDetails.productID),
                      expDate: subTokenVerificationResponse.item2!,
                      yearlyProductID: purchaseDetails.productID,
                      platform: getSubscriptionPlatform());

              if (subscriptionPlanMigrationResponse) {
                emit(state.copyWith(
                  currentSubscriptionId: purchaseDetails.productID,
                  currentSubscription: mapId(purchaseDetails.productID),
                  purchases: [...state.purchases, purchaseDetails],
                  purchaseStatus: AppPurchaseStatus.purchased,
                ));
                localStorage.writeSubscriptionState(state.toJson());
              } else {
                // Handle errors during subscription plan migration.
                emit(state.copyWith(
                    purchaseStatus: AppPurchaseStatus.invalid,
                    errorMessage: LocaleKeys.planMigrationError.tr()));
                return;
              }
            } else {
              // Handle errors in verifying the purchase token.
              emit(state.copyWith(
                  purchaseStatus: AppPurchaseStatus.invalid,
                  errorMessage: subTokenVerificationResponse.item2 ??
                      purchaseDetails.error?.message));
            }
          }

          // If the purchase requires pending completion, do so.
          if (purchaseDetails.pendingCompletePurchase) {
            await inAppPurchase.completePurchase(purchaseDetails);
            return;
          }
        }
      } catch (e) {
        // Handle any unexpected errors during the purchase process.
        emit(state.copyWith(
            purchaseStatus: AppPurchaseStatus.error,
            errorMessage: e.toString()));
        return;
      }
    }
  }

  /// Handle errors that occur during the purchase process.
  ///
  /// [purchaseDetails]: The purchase details containing error information.
  void _handleError(PurchaseDetails purchaseDetails) {
    emit(state.copyWith(
        purchaseStatus: AppPurchaseStatus.error,
        errorMessage:
            purchaseDetails.error?.message ?? LocaleKeys.anErrorOccured.tr()));
  }

  /// Upgrade the subscription to the selected package.
  ///
  /// [productDetails]: The product details of the selected subscription package.
  void upgradeSubscription(ProductDetails productDetails) {
    try {
      // Define a purchase parameter based on the platform.
      late PurchaseParam purchaseParam;

      if (Platform.isAndroid) {
        final Map<String, PurchaseDetails> purchases =
            Map<String, PurchaseDetails>.fromEntries(
                state.purchases.map((PurchaseDetails purchase) {
          if (purchase.pendingCompletePurchase) {
            inAppPurchase.completePurchase(purchase);
          }
          return MapEntry<String, PurchaseDetails>(
              purchase.productID, purchase);
        }));

        purchaseParam = GooglePlayPurchaseParam(
            productDetails: productDetails,
            changeSubscriptionParam: (state.currentSubscriptionId != null &&
                    state.purchases.isNotEmpty)
                ? ChangeSubscriptionParam(
                    oldPurchaseDetails: purchases[state.currentSubscriptionId]
                        as GooglePlayPurchaseDetails,
                  )
                : null);
      } else {
        purchaseParam = PurchaseParam(
          productDetails: productDetails,
        );
      }

      // Initiate the purchase process for the selected subscription package.
      inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      // Handle any exceptions that occur during the purchase.
      emit(state.copyWith(
          purchaseStatus: AppPurchaseStatus.error, errorMessage: e.toString()));
    }
  }

  /// Restore previously purchased subscriptions.
  void restoreSubscription() {
    // Use inAppPurchase to restore purchases.
    inAppPurchase.restorePurchases();
  }

  /// Cancel the current subscription.
  ///
  /// Depending on the platform (iOS or Android), this method opens the subscription management page
  /// in the respective app store for the user to cancel their subscription.
  void cancelSubscription() {
    if (Platform.isIOS) {
      // If the platform is iOS, open the Apple App Store's subscription management page.
      launchUrl(Uri.parse("https://apps.apple.com/account/subscriptions"));
    } else {
      // If the platform is not iOS (typically Android), open the Google Play Store's subscription management page.
      launchUrl(
          Uri.parse('http://play.google.com/store/account/subscriptions'));
    }
  }

  /// Get the current subscription platform.
  ///
  /// This method returns the platform as a string, which can be 'apple' for iOS or 'google' for Android.
  String getSubscriptionPlatform() {
    if (Platform.isIOS) {
      return "apple";
    }
    return 'google';
  }

  /// Close the subscription cubit and cancel any active stream subscriptions.
  ///
  /// This method cancels the stream subscription for listening to purchase updates and then
  /// calls the superclass's close method to close the cubit.
  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
