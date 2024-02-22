import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/login/login.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class NewPassword extends StatefulWidget {
  final String email;
  const NewPassword({Key? key, required this.email}) : super(key: key);

  @override
  _NewPasswordState createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  bool _passwordObscureText = true;
  bool _confirmPasswordObscrueText = true;

  late final TextEditingController passwordTextController;
  late final TextEditingController confirmPasswordTextController;

  final passworedFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  final _formKeyLogin = GlobalKey<FormState>();

  @override
  void initState() {
    passwordTextController = TextEditingController();
    confirmPasswordTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    context.unFocus();
    if (_formKeyLogin.currentState!.validate()) {
      try {
        context.read<LoadingCubit>().loading();
        final response = await context.read<UserRepository>().resetPassword(
            password: confirmPasswordTextController.text.trim(),
            email: widget.email);

        await successfulDialog(context, res: response);
        context.read<LoadingCubit>().loaded();

        context.pushView(const LogIn(), clearStack: true);
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
                foregroundColor: context.theme.colorScheme.primary,
                backgroundColor: context.theme.canvasColor,
                centerTitle: false,
                elevation: 0,
              ),
              body: Form(
                key: _formKeyLogin,
                child: ListView(
                  children: [
                    ScreenHeader(
                        subTitle: LocaleKeys.pleaseEnterYourNewPassword.tr(),
                        title: LocaleKeys.resetYourPassword.tr()),
                    20.h.height,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          LocaleKeys.newPassword.tr(),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ),
                    5.h.height,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: TextFormField(
                        focusNode: passworedFocusNode,
                        textAlignVertical: TextAlignVertical.center,
                        obscureText: _passwordObscureText,
                        controller: passwordTextController,
                        onEditingComplete: () => FocusScope.of(context)
                            .requestFocus(confirmPasswordFocusNode),
                        decoration: InputDecoration(
                          helperText:
                              LocaleKeys.mustBeatLeast8Charactersuse.tr(),
                          suffixIcon: IconButton(
                            icon: Icon(
                                !_passwordObscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _passwordObscureText = !_passwordObscureText;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.required.tr();
                          } else if (value.length < 8) {
                            return LocaleKeys.passwordLessThan8Character.tr();
                          }
                          return null;
                        },
                      ),
                    ),
                    20.h.height,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(LocaleKeys.confirmPassword.tr(),
                            style: Theme.of(context).textTheme.titleSmall!),
                      ),
                    ),
                    5.h.height,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: TextFormField(
                        focusNode: confirmPasswordFocusNode,
                        textAlignVertical: TextAlignVertical.center,
                        obscureText: _confirmPasswordObscrueText,
                        onEditingComplete: () => _resetPassword(),
                        controller: confirmPasswordTextController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                                !_confirmPasswordObscrueText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _confirmPasswordObscrueText =
                                    !_confirmPasswordObscrueText;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.required.tr();
                          } else if (value.length < 8) {
                            return LocaleKeys.passwordDoesNotMatch.tr();
                          } else if (passwordTextController.text
                                  .toString()
                                  .trim() !=
                              confirmPasswordTextController.text
                                  .toString()
                                  .trim()) {
                            return LocaleKeys.passwordDoesNotMatch.tr();
                          }
                          return null;
                        },
                      ),
                    ),
                    20.h.height,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _resetPassword(),
                          child: Text(
                            LocaleKeys.resetPassword.tr(),
                            textAlign: TextAlign.center,
                          ),
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
