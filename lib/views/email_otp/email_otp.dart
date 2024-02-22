import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/email_validation.dart';
import 'package:kiosk/views/login/login.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

import 'email_otp_verification.dart';

class EmailOtp extends StatefulWidget {
  const EmailOtp({Key? key}) : super(key: key);

  @override
  State<EmailOtp> createState() => _EmailOtpState();
}

class _EmailOtpState extends State<EmailOtp> {
  late final TextEditingController _textEditingController;
  late final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  _onContinue() async {
    context.read<UserLoginCubit>().removeCurrentUser();
    context.unFocus();

    if (_formkey.currentState!.validate()) {
      try {
        final email = _textEditingController.text.toLowerCase();
        context.read<LoadingCubit>().loading();
        await context.read<UserRepository>().sendOTP(email: email);
        context.read<LoadingCubit>().loaded();
        context.pushView(EmailOtpVerification(
          userData: {"Email": email},
        ));
      } catch (e) {
        context.read<LoadingCubit>().loaded();
        anErrorOccurredDialog(context, error: e.toString());
      }
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
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: context.theme.canvasColor,
                  elevation: 0,
                  centerTitle: false,
                  title: const AppbarLogo()),
              backgroundColor: context.theme.canvasColor,
              body: Form(
                key: _formkey,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(children: [
                      _Input(_textEditingController, _onContinue),
                      15.h.height,
                      _ContinueButton(_onContinue),
                      10.h.height,
                      const _AlreadyHavaAnAccount(),
                    ]),
                  ),
                ),
              ),
            ),
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

class _AlreadyHavaAnAccount extends StatelessWidget {
  const _AlreadyHavaAnAccount({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushView(const LogIn(), replaceView: true);
      },
      child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocaleKeys.alreadyHaveAnAccount.tr(),
                  style: context.theme.textTheme.bodyMedium!),
              Text(" " + LocaleKeys.login.tr(),
                  style: context.theme.textTheme.bodyMedium!.copyWith(
                      color: context.theme.colorScheme.primary,
                      fontWeight: FontWeight.bold)),
            ],
          )),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input(this._textEditingController, this.onEditingComplete);

  final TextEditingController _textEditingController;
  final Function()? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: AutoSizeText(LocaleKeys.emailAddress.tr(),
                style: context.theme.textTheme.titleSmall!),
          ),
          5.h.height,
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              onEditingComplete: onEditingComplete,
              decoration: InputDecoration(
                  hintText: LocaleKeys.pleaseEnterYourEmailAddress.tr()),
              controller: _textEditingController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocaleKeys.required.tr();
                }
                if (!isValidEmail(value.trim())) {
                  return LocaleKeys.invalidEmail.tr();
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton(this.onPressed);
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          LocaleKeys.continuE.tr().toUpperCase(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
