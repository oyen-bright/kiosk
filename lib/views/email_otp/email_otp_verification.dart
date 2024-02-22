import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/create_account/create_account.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class EmailOtpVerification extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Widget? callBack;

  const EmailOtpVerification({Key? key, required this.userData, this.callBack})
      : super(key: key);

  @override
  State<EmailOtpVerification> createState() => _EmailOtpVerificationState();
}

class _EmailOtpVerificationState extends State<EmailOtpVerification> {
  late final TextEditingController _textEditingController;

  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 5);

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    countdownTimer!.cancel();
    _textEditingController.dispose();
    super.dispose();
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

  void resendOTP() async {
    try {
      context.read<LoadingCubit>().loading(message: "Sending OTP");
      final response = await context
          .read<UserRepository>()
          .sendOTP(email: widget.userData["Email"].toLowerCase());
      context.read<LoadingCubit>().loaded();
      resetTimer();
      _textEditingController.clear();
      successfulDialog(context, res: response);
    } catch (e) {
      context.read<LoadingCubit>().loaded();
      anErrorOccurredDialog(context, error: e.toString());
    }
  }

  void verifyOTP(String pin) async {
    try {
      context.read<LoadingCubit>().loading(message: "");
      await context
          .read<UserRepository>()
          .verifyOtp(email: widget.userData["Email"].toLowerCase(), pin: pin);
      context.read<LoadingCubit>().loaded();
      stopTimer();
      if (widget.callBack != null) {
        await context.pushView(widget.callBack!, replaceView: true);
      } else {
        await context.pushView(
            CreateAccount(
              userData: widget.userData,
            ),
            replaceView: true);
      }

      _textEditingController.clear();
    } catch (e) {
      context.read<LoadingCubit>().loaded();
      anErrorOccurredDialog(context, error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    return BlocBuilder<LoadingCubit, LoadingState>(builder: (context, state) {
      final isLoading = state.status == Status.loading;

      return WillPopScope(
        onWillPop: () async => !isLoading,
        child: Stack(children: [
          Scaffold(
            appBar: AppBar(
              elevation: 0,
              foregroundColor: context.theme.colorScheme.primary,
              backgroundColor: context.theme.canvasColor,
            ),
            backgroundColor: context.theme.canvasColor,
            body: ListView(children: [
              const _Header(),
              10.h.height,
              _InputOTP(
                email: widget.userData["Email"],
                onCompleted: verifyOTP,
                textEditingController: _textEditingController,
              ),
              10.h.height,
              _DidntReceiveOTP(
                minutes: minutes,
                seconds: seconds,
                onPressed: resendOTP,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  LocaleKeys.oTPTakingAWhileToArrive.tr() + " 😉.",
                  style: context.theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              )
            ]),
          ),
          Visibility(
            child: const LoadingWidget(),
            visible: isLoading,
          )
        ]),
      );
    });
  }
}

class _DidntReceiveOTP extends StatelessWidget {
  const _DidntReceiveOTP({
    Key? key,
    required this.minutes,
    required this.seconds,
    required this.onPressed,
  }) : super(key: key);

  final String minutes;
  final String seconds;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(LocaleKeys.didnTReceiveAnyCode.tr(),
              style: context.theme.textTheme.bodyMedium),
          TextButton(
              onPressed: () {
                if (minutes == "00") {
                  onPressed();
                }
              },
              child: Text(
                  minutes == "00"
                      ? LocaleKeys.rESENDCODE.tr()
                      : "$minutes:$seconds",
                  style: TextStyle(
                      color: const Color(0xFF0000BC),
                      fontWeight: FontWeight.bold,
                      fontSize: context.theme.textTheme.bodyMedium!.fontSize))),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Icon(
            Icons.message,
            size: 100.w,
          ),
        ),
        10.h.height,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          width: double.infinity,
          child: Text(
            LocaleKeys.verificationCode.tr(),
            textAlign: TextAlign.center,
            style: context.theme.textTheme.titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _InputOTP extends StatelessWidget {
  const _InputOTP(
      {required this.onCompleted,
      required this.textEditingController,
      required this.email});

  final void Function(String)? onCompleted;
  final TextEditingController textEditingController;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          width: double.infinity,
          child: Text(
            LocaleKeys.pleaseEnterTheOTP.tr() + " $email",
            textAlign: TextAlign.center,
            style: context.theme.textTheme.titleSmall,
          ),
        ),
        5.h.height,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: BoxTextField(
            length: 6,
            controller: textEditingController,
            validator: (v) {
              if (v!.length < 6) {
                return;
              } else {
                return null;
              }
            },
            onChanged: (value) {},
            onCompleted: onCompleted,
            beforeTextPaste: (text) {
              if (text != null) {
                if (int.tryParse(text) != null) {
                  textEditingController.text = text;
                }
              }
              return true;
            },
          ),
        ),
      ],
    );
  }
}
