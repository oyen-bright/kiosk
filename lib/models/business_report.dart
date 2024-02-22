import 'package:flutter/material.dart';

import '../utils/.utils.dart';

class BusinessReport {
  List<int> dailySales;
  List<int> kroonDailyPaymentSale;
  List<int> cashDailyPaymentSale;
  List<int> cardDailyPaymentSale;
  List<int> mobileMoneyDailyPaymentSale;
  List<BestSale> bestSale;
  List<String> days;
  List<MerchantRevenue> merchantRevenue;

  BusinessReport({
    required this.dailySales,
    required this.kroonDailyPaymentSale,
    required this.cashDailyPaymentSale,
    required this.cardDailyPaymentSale,
    required this.mobileMoneyDailyPaymentSale,
    required this.bestSale,
    required this.days,
    required this.merchantRevenue,
  });

  factory BusinessReport.fromJson(Map<String, dynamic> json) {
    return BusinessReport(
      dailySales: List<int>.from(json["daily_sales"].map((x) => x)),
      kroonDailyPaymentSale:
          List<int>.from(json["kroon_daily_payment_sale"].map((x) => x)),
      cashDailyPaymentSale:
          List<int>.from(json["cash_daily_payment_sale"].map((x) => x)),
      cardDailyPaymentSale:
          List<int>.from(json["card_daily_payment_sale"].map((x) => x)),
      mobileMoneyDailyPaymentSale:
          List<int>.from(json["mobile_money_daily_payment_sale"].map((x) => x)),
      bestSale: List<BestSale>.from(
          json["best_sale"].map((x) => BestSale.fromJson(x))),
      days: List<String>.from(json["days"].map((x) => x)),
      merchantRevenue: List<MerchantRevenue>.from(
          json["merchant_revenue"].map((x) => MerchantRevenue.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "daily_sales": List<dynamic>.from(dailySales.map((x) => x)),
        "kroon_daily_payment_sale":
            List<dynamic>.from(kroonDailyPaymentSale.map((x) => x)),
        "cash_daily_payment_sale":
            List<dynamic>.from(cashDailyPaymentSale.map((x) => x)),
        "card_daily_payment_sale":
            List<dynamic>.from(cardDailyPaymentSale.map((x) => x)),
        "mobile_money_daily_payment_sale":
            List<dynamic>.from(mobileMoneyDailyPaymentSale.map((x) => x)),
        "best_sale": List<dynamic>.from(bestSale.map((x) => x.toJson())),
        "days": List<dynamic>.from(days.map((x) => x)),
        "merchant_revenue":
            List<dynamic>.from(merchantRevenue.map((x) => x.toJson())),
      };
}

class BestSale {
  String productProductName;
  int total;
  double totalAmount;
  Color color;

  BestSale(
      {required this.productProductName,
      required this.total,
      required this.totalAmount,
      required this.color});

  factory BestSale.fromJson(Map<String, dynamic> json) => BestSale(
        productProductName: json["product__product_name"],
        total: json["total"],
        totalAmount: json["total_amount"].toDouble(),
        color: generateRandomColor(),
      );

  Map<String, dynamic> toJson() => {
        "product__product_name": productProductName,
        "total": total,
        "total_amount": totalAmount
      };
}

class MerchantRevenue {
  String paymentMethod;
  double totalRevenue;
  Color color;

  MerchantRevenue(
      {required this.paymentMethod,
      required this.totalRevenue,
      required this.color});

  factory MerchantRevenue.fromJson(Map<String, dynamic> json) {
    return MerchantRevenue(
        paymentMethod: json['payment_method'],
        totalRevenue: json['total_revenue'],
        color: generateRandomColor());
  }

  Map<String, dynamic> toJson() => {
        'payment_method': paymentMethod,
        'total_revenue': totalRevenue,
      };
}

class FinancialReport {
  List<double> recentSale;
  List<String> days;

  FinancialReport({required this.recentSale, required this.days});

  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    return FinancialReport(
        recentSale:
            List<double>.from(json["recent_sale"].map((x) => x.toDouble())),
        days: List<String>.from(json["days"].map((x) => x)));
  }

  Map<String, dynamic> toJson() => {
        "recent_sale": List<dynamic>.from(recentSale.map((x) => x)),
        "days": List<dynamic>.from(days.map((x) => x)),
      };
}
