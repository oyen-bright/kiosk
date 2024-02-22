import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/email_otp/email_otp_verification.dart';
import 'package:kiosk/views/login/login/forgot_password/forgot_password_new.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';
import 'package:validators/validators.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late final TextEditingController textContoller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    textContoller = TextEditingController();
  }

  @override
  void dispose() {
    textContoller.dispose();
    super.dispose();
  }

  Future onClick() async {
    context.unFocus();
    final email = textContoller.text.trim().toLowerCase();
    if (_formKey.currentState!.validate()) {
      try {
        context.read<LoadingCubit>().loading();
        final response =
            await context.read<UserRepository>().forgetPassword(email: email);
        context.read<LoadingCubit>().loaded();
        await successfulDialog(context, res: response);
        context.pushView(EmailOtpVerification(
          callBack: NewPassword(
            email: email,
          ),
          userData: {
            "Email": textContoller.text.trim().toLowerCase(),
          },
        ));
      } catch (e) {
        context.read<LoadingCubit>().loaded();
        anErrorOccurredDialog(context, error: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingCubit, LoadingState>(builder: (context, state) {
      final isLoading = state.status == Status.loading;

      return WillPopScope(
        onWillPop: () async => !isLoading,
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: context.theme.canvasColor,
              appBar: AppBar(
                backgroundColor: context.theme.canvasColor,
                foregroundColor: context.theme.colorScheme.primary,
                centerTitle: false,
                elevation: 0,
              ),
              body: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ScreenHeader(
                        subTitle: LocaleKeys.pleaseEnterYourEmailThat.tr(),
                        title: LocaleKeys.resetYourPassword.tr()),
                    20.h.height,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: TextFormField(
                        onEditingComplete: onClick,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: isLoading,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return LocaleKeys.required.tr();
                          } else if (!isEmail(value)) {
                            return LocaleKeys.invalidEmail.tr();
                          }
                          return null;
                        },
                        textAlignVertical: TextAlignVertical.center,
                        controller: textContoller,
                        decoration:
                            InputDecoration(hintText: LocaleKeys.email.tr()),
                      ),
                    ),
                    20.h.height,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => onClick(),
                        child: Text(
                          LocaleKeys.send.tr(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              child: const LoadingWidget(),
              visible: isLoading,
            ),
          ],
        ),
      );
    });
  }
}
