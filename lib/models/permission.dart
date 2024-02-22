class Permissions {
  final bool acceptKroon;
  final bool isAWorker;
  final bool hasPromoCode;
  final String businessCurrency;
  final String merchantWalletId;
  final String merchantSubscription;
  final String accountType;

  const Permissions(
      {required this.acceptKroon,
      required this.hasPromoCode,
      required this.isAWorker,
      required this.accountType,
      required this.businessCurrency,
      required this.merchantWalletId,
      required this.merchantSubscription});
}
