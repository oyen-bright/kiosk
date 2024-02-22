part of 'subscription_huawei_cubit.dart';

class SubscriptionHuaweiState extends Equatable {
  const SubscriptionHuaweiState(
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
  final List<ProductInfo> products;
  final List<InAppPurchaseData> purchases;
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

  SubscriptionHuaweiState copyWith(
      {SubscriptionType? currentSubscription,
      SubscriptionType? selectedSubscription,
      StoreStatus? status,
      AppPurchaseStatus? purchaseStatus,
      String? selectedSubscriptionId,
      String? errorMessage,
      String? currentSubscriptionId,
      List<ProductInfo>? products,
      List<InAppPurchaseData>? purchases,
      bool? hasGovernmentSubscription,
      bool? pendingPurchase}) {
    return SubscriptionHuaweiState(
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

  factory SubscriptionHuaweiState.initial() {
    return const SubscriptionHuaweiState();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currentSubscription': currentSubscription.index,
      'currentSubscriptionId': currentSubscriptionId,
      'hasGovernmentSubscription': hasGovernmentSubscription,
    };
  }

  factory SubscriptionHuaweiState.fromMap(Map<String, dynamic> map) {
    return SubscriptionHuaweiState(
      currentSubscription:
          SubscriptionType.values[map['currentSubscription'] as int],
      currentSubscriptionId: map['currentSubscriptionId'] != null
          ? map['currentSubscriptionId'] as String?
          : null,
      hasGovernmentSubscription: map['hasGovernmentSubscription'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory SubscriptionHuaweiState.fromJson(String source) =>
      SubscriptionHuaweiState.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
