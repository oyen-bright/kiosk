import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/profile/reset_transactional_pin/reset_transaction_pin.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ResetTranscationPin extends StatefulWidget {
  const ResetTranscationPin({
    Key? key,
  }) : super(key: key);

  @override
  State<ResetTranscationPin> createState() => _ResetTranscationPinState();
}

class _ResetTranscationPinState extends State<ResetTranscationPin> {
  late final TextEditingController textEditingController;

  String _inputText = "";
  bool _showButton = false;
  bool _resendOTP = false;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void verifyOTp() async {
    final userEmail = context.read<UserCubit>().state.currentUser!.email;
    try {
      context.read<LoadingCubit>().loading(message: "Verifying OTP");
      await context
          .read<UserRepository>()
          .verifyOtp(email: userEmail, pin: _inputText);

      context.read<LoadingCubit>().loaded();
      await context.pushView(const ResetTransactionPin());
      context.popView();
    } catch (e) {
      context.read<LoadingCubit>().loaded();
      setState(() {
        _resendOTP = true;
      });
      anErrorOccurredDialog(context, error: e.toString());
    }
  }

  void reSendOTP() async {
    final userEmail = context.read<UserCubit>().state.currentUser!.email;

    try {
      context.read<LoadingCubit>().loading(message: "Sending OTP");
      await context.read<UserRepository>().sendOTP(email: userEmail);
      textEditingController.clear();
      context.snackBar(LocaleKeys.oTPSent.tr());
      context.read<LoadingCubit>().loaded();
    } catch (e) {
      context.read<LoadingCubit>().loaded();
      anErrorOccurredDialog(context, error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = context.read<UserCubit>().state.currentUser!.email;

    return BlocBuilder<LoadingCubit, LoadingState>(
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Stack(
            children: [
              Scaffold(
                appBar: customAppBar(context,
                    title: LocaleKeys.transactionalPinDisabled.tr(),
                    showBackArrow: true,
                    showNewsAndPromo: false,
                    showNotifications: false,
                    showSubtitle: false),
                body: StatefulBuilder(builder: (context, setState) {
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      CustomContainer(
                        margin: EdgeInsets.symmetric(
                            horizontal: 22.w, vertical: 10.h),
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ContainerHeader(
                                title: LocaleKeys.transactionalPinDisabled.tr(),
                                subTitle:
                                    '${LocaleKeys.yourTransactionalPinHaveBeenDisabledAn.tr()}"*****${userEmail.substring(3)}" ${LocaleKeys.toResetYourPin.tr()}'),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 0.w),
                                child: BoxTextField(
                                    shape: PinCodeFieldShape.box,
                                    controller: textEditingController,
                                    onCompleted: (v) {
                                      setState(() {
                                        _showButton = true;
                                      });
                                    },
                                    onChanged: (value) {
                                      if (value.length < 6) {
                                        setState(() {
                                          _showButton = false;
                                          _resendOTP = false;
                                        });
                                      }
                                      _inputText = value;
                                    },
                                    length: 6,
                                    beforeTextPaste: (text) {
                                      if (int.tryParse(text.toString()) !=
                                          null) {
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
                      Builder(builder: (context) {
                        if (_resendOTP) {
                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 22.w, vertical: 15.h),
                            width: double.infinity,
                            child: TextButton(
                                onPressed: () => reSendOTP(),
                                child: Text(LocaleKeys.resendOTP.tr())),
                          );
                        } else if (_showButton) {
                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 22.w, vertical: 15.h),
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => verifyOTp(),
                              child: Text(
                                LocaleKeys.continuE.tr(),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                    ],
                  );
                }),
              ),
              Visibility(
                child: LoadingWidget(title: state.msg),
                visible: isLoading,
              )
            ],
          ),
        );
      },
    );
  }
}
