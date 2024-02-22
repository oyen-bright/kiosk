import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

import 'create_transaction_pin_confirm.dart';

class CreateTransactionPin extends StatelessWidget {
  final String firstName;
  final String email;
  final String password;
  final Map<String, dynamic> sesionToken;
  const CreateTransactionPin(
      {Key? key,
      required this.password,
      required this.firstName,
      required this.sesionToken,
      required this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    void procede(String pin) {
      context.pushView(TransactionPinConfirm(
          firstName: firstName,
          email: email,
          password: password,
          currentPin: pin,
          sessionToken: const {}));
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: context.theme.canvasColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: context.theme.canvasColor,
          elevation: 0,
          title: const AppbarLogo(),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            20.h.height,
            ScreenHeader(
                title:
                    "${LocaleKeys.hello.tr()} $firstName, \n${LocaleKeys.createYourTransactionPin.tr()}",
                subTitle: LocaleKeys
                    .createATransactionPinThisPinWillBeRequiredAnytimeYouWantAnytimeYouWantToViewYourVirtualCardDetails
                    .tr()),
            20.h.height,
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: BoxTextField(
                  shape: PinCodeFieldShape.box,
                  onCompleted: procede,
                  onChanged: (v) {},
                  length: 6,
                  beforeTextPaste: (text) {
                    if (int.tryParse(text.toString()) != null) {
                      if (text!.length == 6) {
                        procede(text);
                      }
                    }
                    return true;
                  },
                ))
          ],
        ),
      ),
    );
  }
}
