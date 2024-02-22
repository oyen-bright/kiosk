import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/workers/workers_create_worker.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class WorkersOTPVerification extends StatefulWidget {
  const WorkersOTPVerification({Key? key, required this.email})
      : super(key: key);
  final String email;

  @override
  State<WorkersOTPVerification> createState() => _WorkersOTPVerificationState();
}

class _WorkersOTPVerificationState extends State<WorkersOTPVerification> {
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 5);
  int counter = 15;

  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    startTimer();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    countdownTimer!.cancel();
    textEditingController.dispose();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => myDuration = const Duration(minutes: 5));
    startTimer();
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  Future<void> resendOTP() async {
    try {
      context.read<LoadingCubit>().loading(message: "Sending OTP");
      final response = await context
          .read<UserRepository>()
          .sendOTP(email: widget.email.toLowerCase());
      context.read<LoadingCubit>().loaded();
      resetTimer();
      textEditingController.clear();
      successfulDialog(context, res: response.titleCase);
    } catch (e) {
      context.read<LoadingCubit>().loaded();

      anErrorOccurredDialog(context, error: e.toString().titleCase);
    }
  }

  Future<void> verifyOTP() async {
    try {
      context.read<LoadingCubit>().loading(message: "Verifying OTP");
      await context.read<UserRepository>().verifyOtp(
          email: widget.email.toLowerCase(), pin: textEditingController.text);
      context.read<LoadingCubit>().loaded();
      await context.pushView(
          WorkersCreateAccount(
            email: widget.email,
          ),
          replaceView: true);
    } catch (e) {
      context.read<LoadingCubit>().loaded();

      anErrorOccurredDialog(context, error: e.toString().titleCase);
    }
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    return BlocBuilder<LoadingCubit, LoadingState>(
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Stack(alignment: Alignment.topCenter, children: [
            Scaffold(
                appBar: customAppBar(context,
                    title: LocaleKeys.myWorkers.tr(),
                    showBackArrow: true,
                    showNewsAndPromo: false,
                    showNotifications: false,
                    showSubtitle: false),
                body: BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                    return ListView(children: [
                      CustomContainer(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(
                              horizontal: 22.w, vertical: 10.h),
                          padding: EdgeInsets.all(16.r),
                          child: Column(children: [
                            ContainerHeader(
                                title: LocaleKeys.oTPVerification.tr(),
                                subTitle: LocaleKeys
                                    .ourOtpVerificationProcessInvolvesSendingA6DigitCodeToTheEmailOrPhoneNumberProvidedWhichMustThenBeEnteredIntoOurSystemToCompleteTheVerificationProcess
                                    .tr()),
                            10.h.height,
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0.w),
                              child: BoxTextField(
                                shape: PinCodeFieldShape.box,
                                length: 6,
                                controller: textEditingController,
                                beforeTextPaste: (input) {
                                  if (input != null) {
                                    if (int.tryParse(input) != null) {
                                      textEditingController.text = input;
                                    }
                                  }
                                  return true;
                                },
                                onCompleted: (v) => verifyOTP(),
                                onChanged: (_) {},
                              ),
                            ),
                            5.h.height,
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(LocaleKeys.didnTReceiveAnyCode.tr(),
                                      style:
                                          context.theme.textTheme.titleSmall),
                                  TextButton(
                                      onPressed: () {
                                        if (minutes == "00") {
                                          resendOTP();
                                        }
                                      },
                                      child: Text(
                                        minutes == "00"
                                            ? LocaleKeys.rESENDCODE.tr()
                                            : "$minutes:$seconds",
                                      ))
                                ],
                              ),
                            ),
                          ])),
                    ]);
                  },
                )),
            Visibility(
              child: const LoadingWidget(),
              visible: isLoading,
            )
          ]),
        );
      },
    );
  }
}
