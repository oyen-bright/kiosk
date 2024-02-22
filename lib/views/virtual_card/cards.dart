import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_card/awesome_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';

class Cards extends StatelessWidget {
  const Cards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        showSubtitle: false,
        title: LocaleKeys.cards.tr(),
        showBackArrow: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),
            _buildCreditCard(context),
            SizedBox(height: 15.h),
            CustomContainer(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 25.w, right: 26.w, top: 20.h),
              padding: EdgeInsets.all(16.r),
              child: AutoSizeText(
                LocaleKeys.comingSoon.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: context.theme.colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCard(BuildContext context) {
    bool showBack = false;

    return StatefulBuilder(
      builder: (context, setCardSet) {
        return GestureDetector(
          onTap: () {
            // context.read<AnalyticsService>().logVirtualCardClicked();
            setCardSet(() {
              showBack = !showBack;
            });
          },
          child: CreditCard(
            cardNumber: "***************",
            cardExpiry: "*********",
            cardHolderName: context.read<UserCubit>().state.currentUser!.name,
            cvv: "***",
            bankName: "",
            cardType: CardType.masterCard,
            showBackSide: showBack,
            frontBackground: _buildFrontBackground(context),
            backBackground: _buildBackBackground(),
            showShadow: false,
            textExpDate: 'Exp. Date',
            textName: 'Name',
            textExpiry: 'MM/YY',
          ),
        );
      },
    );
  }

  Widget _buildFrontBackground(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage("assets/images/Design_2.png"),
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
                    left: 15.w,
                    top: 15.h,
                  ),
                  alignment: Alignment.centerLeft,
                  height: 30.h,
                  width: double.infinity,
                  child: Image.asset("assets/images/Group 6.png"),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(right: 48.w, top: 7.h),
                  child: Text(
                    LocaleKeys.tapToSeeDetails.tr(),
                    style: context.theme.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.5)),
                  ))
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage("assets/images/Design_2.png"),
          fit: BoxFit.cover,
        ),
      ),
      width: double.infinity,
    );
  }
}
