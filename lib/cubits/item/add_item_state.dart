// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'add_item_cubit.dart';

class AddItemState extends Equatable {
  final File? productImage;
  final String productTitle;
  final String productSku;
  final String costPrice;
  final String price;
  final String stock;
  final String category;
  final String lowStockLimit;
  final bool outOfStockNotify;
  final bool expiryNotify;
  final String? expiryNotifyPeriod;
  final String weightUnit;
  final bool chargeByWeight;
  final String expireDate;
  final List<Variation> productVariation;
  const AddItemState(
      {this.productImage,
      this.productTitle = "",
      this.productSku = "",
      this.costPrice = "",
      this.price = "",
      this.expireDate = "",
      this.category = "",
      this.expiryNotifyPeriod,
      this.chargeByWeight = false,
      this.lowStockLimit = "",
      this.expiryNotify = false,
      this.outOfStockNotify = false,
      this.productVariation = const [],
      this.stock = "",
      this.weightUnit = ""});

  @override
  List<Object?> get props => [
        productImage,
        productTitle,
        productSku,
        costPrice,
        price,
        stock,
        expireDate,
        category,
        expiryNotifyPeriod,
        lowStockLimit,
        expiryNotify,
        outOfStockNotify,
        weightUnit,
        chargeByWeight,
        productVariation
      ];

  factory AddItemState.initial() {
    return const AddItemState();
  }

  AddItemState copyWith({
    File? productImage,
    String? productTitle,
    String? productSku,
    String? costPrice,
    String? price,
    String? stock,
    String? category,
    String? expireDate,
    String? lowStockLimit,
    String? expiryNotifyPeriod,
    bool? expiryNotify,
    bool? outOfStockNotify,
    String? weightUnit,
    bool? chargeByWeight,
    List<Variation>? productVariation,
  }) {
    return AddItemState(
      expiryNotifyPeriod: expiryNotifyPeriod ?? this.expiryNotifyPeriod,
      expiryNotify: expiryNotify ?? this.expiryNotify,
      productImage: productImage ?? this.productImage,
      productTitle: productTitle ?? this.productTitle,
      productSku: productSku ?? this.productSku,
      costPrice: costPrice ?? this.costPrice,
      expireDate: expireDate ?? this.expireDate,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      lowStockLimit: lowStockLimit ?? this.lowStockLimit,
      outOfStockNotify: outOfStockNotify ?? this.outOfStockNotify,
      weightUnit: weightUnit ?? this.weightUnit,
      chargeByWeight: chargeByWeight ?? this.chargeByWeight,
      productVariation: productVariation ?? this.productVariation,
    );
  }

  @override
  bool get stringify => true;
}
