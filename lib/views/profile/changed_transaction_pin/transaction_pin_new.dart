import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/profile/changed_transaction_pin/transaction_pin_confirm.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ChangeTransactionPin extends StatelessWidget {
  final String oldPin;

  const ChangeTransactionPin({Key? key, required this.oldPin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _inputText = "";

    return Scaffold(
      appBar: customAppBar(context,
          title: LocaleKeys.changeTransactionPin.tr(),
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
                    subTitle: LocaleKeys.createYourNewTransactionPin.tr(),
                    title: LocaleKeys.changeTransactionPin.tr()),
                Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.w),
                    child: BoxTextField(
                        shape: PinCodeFieldShape.box,
                        onCompleted: (v) {
                          procede(context, _inputText);
                          _inputText = "";
                        },
                        onChanged: (value) {
                          _inputText = value;
                        },
                        length: 6,
                        beforeTextPaste: (text) {
                          if (int.tryParse(text.toString()) != null) {
                            _inputText = text!;
                            if (_inputText.length == 6) {
                              procede(context, _inputText);
                              _inputText = "";
                            }
                          }

                          return true;
                        }))
              ],
            ),
          ),
        ],
      ),
    );
  }

  void procede(BuildContext context, String pin) {
    context.pushView(ChangeTransactionPinConfirm(
      currentPin: pin,
      oldPin: oldPin,
    ));
  }
}
