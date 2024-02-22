import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';

class Payment extends StatelessWidget {
  const Payment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context,
          title: LocaleKeys.payment.tr(),
          showNewsAndPromo: false,
          subTitle: LocaleKeys.profile.tr(),
          showNotifications: false,
          showBackArrow: true),
      body: ListView(
        children: [
          CustomContainer(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
              padding: EdgeInsets.all(16.r),
              child: Column(children: [
                ContainerHeader(
                    title: LocaleKeys.paymentMethod.tr(),
                    subTitle: LocaleKeys
                        .toAddAPaymentMethodClickTheAddPaymentMethodButtonFromThereYouCanSelectYourPreferredPaymentProcessorYouCanUseTheToggleToEnableOrDisableThePaymentMethodAsNeeded
                        .tr()),
              ])),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              LocaleKeys.paymentIntegrationNote.tr(),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
