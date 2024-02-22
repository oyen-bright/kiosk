import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formkey = GlobalKey<FormState>();
  late final TextEditingController oldPassword;
  late final TextEditingController password;
  late final TextEditingController confirmPassword;

  final passwordFocusNode = FocusNode();
  final confrimPasswordFocusNode = FocusNode();

  bool _isObscure = true;
  bool _newisObscure = true;
  bool _isObscureConfirm = true;

  @override
  void initState() {
    super.initState();
    oldPassword = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
  }

  @override
  void dispose() {
    oldPassword.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  void onPressed() async {
    context.unFocus();
    if (_formkey.currentState!.validate()) {
      try {
        context.read<LoadingCubit>().loading();

        final response = await context.read<UserRepository>().changePassword(
            newPassword: password.text, oldPassword: oldPassword.text);
        context.read<LoadingCubit>().loaded();
        await successfulDialog(context, res: response.toString());
        context.popView();
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
                appBar: customAppBar(
                  context,
                  title: LocaleKeys.password.tr(),
                  showBackArrow: true,
                  showNewsAndPromo: false,
                  showNotifications: false,
                  subTitle: LocaleKeys.profile.tr(),
                ),
                body: ListView(
                  shrinkWrap: true,
                  children: [
                    CustomContainer(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(
                          horizontal: 22.w, vertical: 10.h),
                      padding: EdgeInsets.all(16.r),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ContainerHeader(
                              title: LocaleKeys.changePassword.tr(),
                              subTitle: LocaleKeys
                                  .ifYouNeedToChangeYourPasswordYouCanDoSoByClickingOnTheChangePasswordButtonSimplyEnterYourCurrentPasswordFollowedByYourNewPasswordTwiceToConfirmTheChange
                                  .tr(),
                            ),
                            CustomTextFormField(
                              labelText: LocaleKeys.oldPassword.tr(),
                              obscureText: _isObscure,
                              onEditingComplete: () {
                                FocusScope.of(context)
                                    .requestFocus(passwordFocusNode);
                              },
                              controller: oldPassword,
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return LocaleKeys.enterYourPassword.tr();
                                } else if (value.length < 8) {
                                  return LocaleKeys.passwordLessThan8Character
                                      .tr();
                                }
                                return null;
                              },
                            ),
                            20.h.height,
                            CustomTextFormField(
                              onEditingComplete: () {
                                FocusScope.of(context)
                                    .requestFocus(confrimPasswordFocusNode);
                              },
                              focusNode: passwordFocusNode,
                              labelText: LocaleKeys.newPassword.tr(),
                              obscureText: _newisObscure,
                              controller: password,
                              onPressed: () {
                                setState(() {
                                  _newisObscure = !_newisObscure;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return LocaleKeys.enterYourNewPassword.tr();
                                } else if (value.length < 8) {
                                  return LocaleKeys.passwordLessThan8Character
                                      .tr();
                                }
                                return null;
                              },
                              helperText:
                                  LocaleKeys.mustBeatLeast8Charactersuse.tr(),
                            ),
                            20.h.height,
                            CustomTextFormField(
                              focusNode: confrimPasswordFocusNode,
                              labelText: LocaleKeys.confirmPassword.tr(),
                              obscureText: _isObscureConfirm,
                              controller: confirmPassword,
                              onPressed: () {
                                setState(() {
                                  _isObscureConfirm = !_isObscureConfirm;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return LocaleKeys.enterYourNewPassword.tr();
                                } else if (value.length < 8) {
                                  return LocaleKeys.passwordLessThan8Character
                                      .tr();
                                } else if (password.text.toString().trim() !=
                                    confirmPassword.text.toString().trim()) {
                                  return LocaleKeys.passwordDoesNotMatch.tr();
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    10.h.height,
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () => onPressed(),
                          child: Center(
                            child: Text(
                              LocaleKeys.changePassword.tr(),
                            ),
                          )),
                    )
                  ],
                )),
            Visibility(visible: isLoading, child: const LoadingWidget())
          ]),
        );
      },
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final bool obscureText;
  final TextEditingController? controller;
  final String labelText;
  final String? Function(String?)? validator;
  final void Function()? onPressed;
  final String? helperText;
  final FocusNode? focusNode;
  final void Function()? onEditingComplete;
  const CustomTextFormField(
      {Key? key,
      this.validator,
      required this.labelText,
      this.focusNode,
      this.onEditingComplete,
      this.obscureText = false,
      this.controller,
      this.helperText,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      obscureText: obscureText,
      controller: controller,
      decoration: InputDecoration(
        helperText: helperText,
        suffixIcon: IconButton(
          icon: Icon(!obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey),
          onPressed: onPressed,
        ),
        labelText: labelText,
      ),
      validator: validator,
    );
  }
}
