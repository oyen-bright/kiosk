// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:easy_localization/easy_localization.dart';
import 'package:kiosk/utils/utils.dart';

class Products {
  String id;
  String productSku;
  String productName;
  String costPrice;
  String price;
  String image;
  String stock;
  String weightUnit;
  String lowStockLimit;
  String weightQuantity;
  String? expireDate;
  int? notificationPeriod;
  List productsVariation;
  final String category;
  bool chargeByWeight;
  bool expireNotify;
  bool outOfStockNotify;

// addin cart alread

  Products({
    required this.id,
    required this.lowStockLimit,
    required this.chargeByWeight,
    required this.productsVariation,
    required this.category,
    required this.image,
    required this.notificationPeriod,
    required this.price,
    required this.expireDate,
    required this.expireNotify,
    required this.outOfStockNotify,
    required this.weightUnit,
    required this.productName,
    required this.productSku,
    required this.weightQuantity,
    required this.costPrice,
    required this.stock,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json["id"],
      notificationPeriod: json['expiry_days_notify'] != null
          ? json['expiry_days_notify'] == 0
              ? null
              : json['expiry_days_notify']
          : json['expiry_days_notify'],
      expireDate: json['expiring_date'] ?? "",
      expireNotify: json['expire_notify'] ?? false,
      lowStockLimit: json["low_stock_limit"] ?? "5",
      outOfStockNotify: json['out_of_stock_notify'] ?? false,
      weightUnit: json["weight_unit"] ?? "",
      chargeByWeight: json["charge_by_weight"] ?? false,
      productsVariation: json["products_variation"] ?? [],
      category: json["category"].toString(),
      image: json['image'] ?? "",
      costPrice: json["cost_price"] ?? "",
      stock: json['stock'].toString(),
      productName:
          toBeginningOfSentenceCase(Util.decodeString(json['product_name'])) ??
              Util.decodeString(json['product_name']),
      productSku: json['product_sku'],
      price: json['price'],
      weightQuantity: json['weight_quantity'] ?? null.toString(),
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "products_variation": productsVariation,
        "product_sku": productSku,
        "charge_by_weight": chargeByWeight,
        "weight_quantity": weightQuantity,
        "weight_unit": weightUnit,
        "out_of_stock_notify": outOfStockNotify,
        "low_stock_limit": lowStockLimit,
        "product_name": productName,
        "expire_notify": expireNotify,
        "expiring_date": expireDate,
        "expiry_days_notify": notificationPeriod,
        "category": category,
        "price": price,
        "cost_price": costPrice,
        "image": image,
        "stock": stock,
      };

  @override
  String toString() {
    return 'Products(id: $id, productSku: $productSku, expireDate: $expireDate, productName: $productName, costPrice: $costPrice, price: $price, image: $image, stock: $stock, weightUnit: $weightUnit, lowStockLimit: $lowStockLimit, weightQuantity: $weightQuantity, productsVariation: $productsVariation, category: $category, chargeByWeight: $chargeByWeight, outOfStockNotify: $outOfStockNotify)';
  }
}
