import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/profile/reset_transactional_pin/reset_transaction_pin_confirm.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ResetTransactionPin extends StatefulWidget {
  const ResetTransactionPin({
    Key? key,
  }) : super(key: key);

  @override
  _ResetTransactionPinState createState() => _ResetTransactionPinState();
}

class _ResetTransactionPinState extends State<ResetTransactionPin> {
  late StreamController<ErrorAnimationType>? _errorController;

  String _inputText = "";

  @override
  void initState() {
    _errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    _errorController!.close();
    super.dispose();
  }

  void verifyInput() {
    if (_inputText.length != 6) {
      _errorController!
          .add(ErrorAnimationType.shake); // Triggering error shake animation
    } else {
      context.pushView(ResetTransactionPinConfirm(
        currentPin: _inputText,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context,
          title: LocaleKeys.transactionalPinDisabled.tr(),
          showBackArrow: true,
          showNewsAndPromo: false,
          showNotifications: false,
          showSubtitle: false),
      body: ListView(
        shrinkWrap: true,
        children: [
          CustomContainer(
            margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                ContainerHeader(
                    title: LocaleKeys.createYourNewTransactionPin.tr(),
                    subTitle: LocaleKeys
                        .createANewTransactionPinThisPinWillBeRequiredAnytimeYouWantToMake
                        .tr()),
                Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.w),
                    child: BoxTextField(
                        shape: PinCodeFieldShape.box,
                        errorAnimationController: _errorController,
                        onChanged: (value) {
                          _inputText = value;
                        },
                        length: 6,
                        beforeTextPaste: (text) {
                          if (int.tryParse(text.toString()) != null) {
                            _inputText = text!;
                            if (_inputText.length == 6) {
                              _inputText = text;
                            }
                          }

                          return true;
                        })),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 15.h),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: verifyInput,
              child: Text(
                LocaleKeys.continuE.tr(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
