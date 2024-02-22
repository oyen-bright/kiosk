// ignore_for_file: unused_local_variable

import 'package:awesome_card/awesome_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/virtual_card.dart';
import 'package:kiosk/translations/locale_keys.g.dart';

class KioskCard extends StatelessWidget {
  final Color backgroundColor;
  final VirtualCard card;

  const KioskCard({
    Key? key,
    this.backgroundColor = const Color.fromRGBO(248, 193, 32, 1),
    required this.card,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final kioskBlue = context.theme.colorScheme.primary;
    final cardDesign = card.cardDesign;

    Color? cardBgColor;
    String? cardImage;

    switch (cardDesign) {
      case "Design_1":
        cardBgColor = const Color.fromRGBO(248, 193, 32, 1);
        break;
      case "Design_2":
        cardBgColor = kioskBlue;
        break;
      default:
        cardImage = "assets/images/$cardDesign.png";
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: CreditCard(
        horizontalMargin: 0,
        cardNumber: card.maskedPan,
        cardExpiry: card.expiration,
        cardHolderName: card.nameOnCard,
        cvv: card.cvv,
        bankName: "",
        cardType: card.cardType == "mastercard" || card.cardType!.isEmpty
            ? CardType.masterCard
            : CardType.visa,
        showBackSide: false,
        frontBackground: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: cardBgColor ?? card.cardColor,
            image: cardImage == null
                ? null
                : DecorationImage(
                    image: AssetImage(cardImage),
                    fit: BoxFit.cover,
                  ),
          ),
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: 10.h,
                          left: 15.w,
                          top: 15.h,
                        ),
                        alignment: Alignment.centerLeft,
                        height: 30.h,
                        width: double.infinity,
                        child: Image.asset(
                          "assets/images/Group 6.png",
                          color: cardBgColor == kioskBlue ? Colors.white : null,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 48.w, top: 7.h),
                      child: Text(
                        LocaleKeys.tapToSeeDetails.tr(),
                        style: context.theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backBackground: CardBackgrounds.white,
        showShadow: false,
        textExpDate: 'Exp. Date',
        textName: 'Name',
        textExpiry: 'MM/YY',
      ),
    );
  }
}
