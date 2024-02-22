import 'package:flutter/material.dart';
import 'package:kiosk/constants/.constants.dart';

class VirtualCard {
  final String? cardId;
  final String? accountId;
  final String? amount;
  final String? currency;
  final String? cardHash;
  final String? cardPan;
  final String? maskedPan;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? cvv;
  final String? expiration;
  final String? sendTo;
  final String? binCheckName;
  final String? cardType;
  final String? nameOnCard;
  bool? block;
  bool? isActive;
  final String? cardDesign;
  final Color cardColor;

  VirtualCard(
      {required this.accountId,
      required this.address,
      required this.amount,
      required this.binCheckName,
      required this.cardHash,
      required this.cardId,
      required this.cardPan,
      required this.block,
      required this.cardDesign,
      required this.cardType,
      required this.city,
      required this.currency,
      required this.cvv,
      required this.expiration,
      required this.isActive,
      required this.maskedPan,
      required this.nameOnCard,
      required this.postalCode,
      required this.sendTo,
      required this.state,
      required this.cardColor});
  factory VirtualCard.fromJson(Map<String, dynamic> json) {
    Color generateBacgroundColor() {
      if (json["card_design"] == "Design_1") {
        return const Color.fromRGBO(248, 193, 32, 1);
      } else if (json["card_design"] == "Design_2") {
        return kioskBlue;
      } else if (json["card_design"] == "Design_3") {
        return const Color.fromRGBO(205, 147, 194, 1);
      } else {
        return const Color.fromRGBO(222, 78, 110, 1);
      }
    }

    return VirtualCard(
        block: json["block"],
        accountId: json["account_id"],
        address: json["address"],
        amount: json["amount"],
        cardDesign: json["card_design"],
        binCheckName: json["bin_check_name"],
        cardHash: json["card_hash"],
        cardId: json["card_id"],
        cardPan: json["card_pan"],
        cardType: json["card_type"],
        city: json["city"],
        currency: json["currency"],
        cvv: json["cvv"],
        expiration: json["expiration"],
        isActive: json["is_active"],
        maskedPan: json["masked_pan"],
        nameOnCard: json["name_on_card"],
        postalCode: json["postal_code"],
        sendTo: json["send_to"],
        cardColor: generateBacgroundColor(),
        state: json["state"]);
  }
}
