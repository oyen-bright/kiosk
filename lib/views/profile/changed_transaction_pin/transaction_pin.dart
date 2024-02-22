import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/profile/changed_transaction_pin/transaction_pin_new.dart';
import 'package:kiosk/views/profile/reset_transactional_pin/reset_transactional_pin.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class ChangeTransactionPIN extends StatefulWidget {
  const ChangeTransactionPIN({
    Key? key,
  }) : super(key: key);

  @override
  _ChangeTransactionPINState createState() => _ChangeTransactionPINState();
}

class _ChangeTransactionPINState extends State<ChangeTransactionPIN> {
  StreamController<ErrorAnimationType>? errorController;
  String _inputText = "";

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    context.read<LoadingCubit>().loaded();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  void onResetTransactionPin() async {
    final userEmail = context.read<UserCubit>().state.currentUser!.email;
    try {
      context.read<LoadingCubit>().loading(message: "Sending OTP");
      await context.read<UserRepository>().sendOTP(email: userEmail);
      context.read<LoadingCubit>().loaded();
      context.pushView(const ResetTranscationPin(), replaceView: true);
    } catch (e) {
      context.read<LoadingCubit>().loaded();
      anErrorOccurredDialog(context, error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingCubit, LoadingState>(
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Stack(children: [
            Scaffold(
              appBar: customAppBar(
                context,
                title: LocaleKeys.changeTransactionPin.tr(),
                showBackArrow: true,
                showNewsAndPromo: false,
                showNotifications: false,
                subTitle: LocaleKeys.profile.tr(),
              ),
              body: ListView(
                children: [
                  CustomContainer(
                    alignment: Alignment.center,
                    margin:
                        EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      children: [
                        ContainerHeader(
                            subTitle: LocaleKeys
                                .inputYourOldTransactionPinToChangeYourTransactionPin
                                .tr(),
                            title: LocaleKeys.changeTransactionPin.tr()),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 0.w),
                            child: BoxTextField(
                              shape: PinCodeFieldShape.box,
                              onChanged: (value) {
                                _inputText = value;
                              },
                              errorAnimationController: errorController,
                              length: 6,
                              beforeTextPaste: (text) {
                                if (int.tryParse(text.toString()) != null) {
                                  _inputText = text ?? _inputText;
                                }
                                return true;
                              },
                            ))
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin:
                        EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_inputText.length != 6) {
                          errorController!.add(ErrorAnimationType
                              .shake); // Triggering error shake animation
                        } else {
                          context.pushView(ChangeTransactionPin(
                            oldPin: _inputText,
                          ));
                        }
                      },
                      child: Text(
                        LocaleKeys.continuE.tr().toUpperCase(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                        onPressed: onResetTransactionPin,
                        child: Text(LocaleKeys.resetTransactionalPin.tr())),
                  ),
                  10.h.height
                ],
              ),
            ),
            Visibility(
                visible: isLoading,
                child: LoadingWidget(
                  title: state.msg,
                ))
          ]),
        );
      },
    );
  }
}
