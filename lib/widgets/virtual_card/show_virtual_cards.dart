import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/virtual_card.dart';
import 'package:kiosk/translations/locale_keys.g.dart';

import 'kiosk_virtual_card.dart';

class ShowVirtualCards extends StatelessWidget {
  final int index;
  final List<dynamic> virtualCards;
  const ShowVirtualCards(
      {Key? key, required this.index, required this.virtualCards})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (virtualCards.isEmpty) {
      return GestureDetector(
        onTap: () {},
        child: _gotoCardTab(context),
      );
    } else {
      return GestureDetector(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 3.w),
          child: KioskCard(
            card: VirtualCard.fromJson(Map.from(virtualCards[index - 1])),
          ),
        ),
      );
    }
  }

  Widget _gotoCardTab(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              image: const DecorationImage(
                image: AssetImage("assets/images/Design_1.png"),
                fit: BoxFit.cover,
              ),
            ),
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: 10.h,
                          left: 10.w,
                          top: 15.h,
                        ),
                        alignment: Alignment.centerLeft,
                        height: 30.h,
                        width: double.infinity,
                        child: Image.asset("assets/images/Group 6.png"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 20.h),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            LocaleKeys.toCreateAVirtualCardGoToTheCardsTab.tr().toUpperCase(),
            textAlign: TextAlign.center,
            style: context.theme.textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
