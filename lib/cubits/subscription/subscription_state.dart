// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'subscription_cubit.dart';

enum SubscriptionType {
  free,
  kioskPlus,
  kioskPro,
}

enum StoreStatus {
  storeUnavailable,
  storeLoaded,
  error,
  loading,
}

enum AppPurchaseStatus {
  pending,
  error,
  purchased,
  invalid,
  verifying,
  cancelled
}

class SubscriptionState extends Equatable {
  const SubscriptionState(
      {this.currentSubscription = SubscriptionType.free,
      this.selectedSubscription = SubscriptionType.free,
      this.status = StoreStatus.loading,
      this.purchaseStatus,
      this.selectedSubscriptionId,
      this.errorMessage,
      this.currentSubscriptionId = "",
      this.products = const [],
      this.purchases = const [],
      this.hasGovernmentSubscription = false,
      this.pendingPurchase = false});
  final SubscriptionType currentSubscription;
  final SubscriptionType selectedSubscription;
  final StoreStatus status;
  final AppPurchaseStatus? purchaseStatus;
  final String? selectedSubscriptionId;
  final String? errorMessage;
  final String? currentSubscriptionId;
  final List<ProductDetails> products;
  final List<PurchaseDetails> purchases;
  final bool hasGovernmentSubscription;
  final bool pendingPurchase;

  @override
  List<Object?> get props => [
        currentSubscription,
        selectedSubscription,
        status,
        purchaseStatus,
        selectedSubscriptionId,
        errorMessage,
        currentSubscriptionId,
        products,
        purchases,
        hasGovernmentSubscription,
        pendingPurchase
      ];

  SubscriptionState copyWith(
      {SubscriptionType? currentSubscription,
      SubscriptionType? selectedSubscription,
      StoreStatus? status,
      AppPurchaseStatus? purchaseStatus,
      String? selectedSubscriptionId,
      String? errorMessage,
      String? currentSubscriptionId,
      List<ProductDetails>? products,
      List<PurchaseDetails>? purchases,
      bool? hasGovernmentSubscription,
      bool? pendingPurchase}) {
    return SubscriptionState(
        currentSubscription: currentSubscription ?? this.currentSubscription,
        selectedSubscription: selectedSubscription ?? this.selectedSubscription,
        status: status ?? this.status,
        purchaseStatus: purchaseStatus ?? this.purchaseStatus,
        selectedSubscriptionId:
            selectedSubscriptionId ?? this.selectedSubscriptionId,
        errorMessage: errorMessage ?? this.errorMessage,
        currentSubscriptionId:
            currentSubscriptionId ?? this.currentSubscriptionId,
        products: products ?? this.products,
        purchases: purchases ?? this.purchases,
        hasGovernmentSubscription:
            hasGovernmentSubscription ?? this.hasGovernmentSubscription,
        pendingPurchase: pendingPurchase ?? this.pendingPurchase);
  }

  factory SubscriptionState.initial() {
    return const SubscriptionState();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currentSubscription': currentSubscription.index,
      'currentSubscriptionId': currentSubscriptionId,
      'hasGovernmentSubscription': hasGovernmentSubscription,
    };
  }

  factory SubscriptionState.fromMap(Map<String, dynamic> map) {
    return SubscriptionState(
      currentSubscription:
          SubscriptionType.values[map['currentSubscription'] as int],
      currentSubscriptionId: map['currentSubscriptionId'] != null
          ? map['currentSubscriptionId'] as String?
          : null,
      hasGovernmentSubscription: map['hasGovernmentSubscription'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory SubscriptionState.fromJson(String source) =>
      SubscriptionState.fromMap(json.decode(source) as Map<String, dynamic>);
}
