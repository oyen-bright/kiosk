import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/settings.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/create_account/create_business_info/register_business_infomation.dart';
import 'package:kiosk/views/email_otp/email_otp.dart';
import 'package:kiosk/views/login/login/forgot_password/forgot_password.dart';
import 'package:kiosk/views/login/login/login_select_business.dart';
import 'package:kiosk/views/login/login/login_switch_account.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';
import 'package:validators/validators.dart';

class LoginLogin extends StatefulWidget {
  const LoginLogin({Key? key}) : super(key: key);

  @override
  State<LoginLogin> createState() => _LoginLoginState();
}

class _LoginLoginState extends State<LoginLogin> {
  final _formKey = GlobalKey<FormState>();

  late final FocusNode passwordFocusNode;
  late final TextEditingController usersPasswordController;
  late final TextEditingController usersEmailController;

  @override
  void initState() {
    super.initState();

    final box = GetStorage();
    box.remove('Token');

    passwordFocusNode = FocusNode();
    usersEmailController = TextEditingController();
    usersPasswordController = TextEditingController();
    biometricLogin();
  }

  Future biometricLogin() async {
    final userSettings = context.read<UserSettingsCubit>().state;

    if (userSettings.loginWithBiometrics) {
      try {
        final authenticated = await context
            .read<UserSettingsCubit>()
            .authenticate(reason: "Login");
        if (authenticated) {
          usersPasswordController.clear();
          await _loginSubmit(context, bioLogin: true);
        }
      } catch (e) {
        context.snackBar(e.toString());
      }
    }
  }

  Future _loginSubmit(
    BuildContext context, {
    bool bioLogin = false,
  }) async {
    context.unFocus();
    if (!bioLogin ? _formKey.currentState!.validate() : true) {
      try {
        await context.read<UserLoginCubit>().userLogin(
            isBioLogin: bioLogin,
            usersEmail: usersEmailController.text,
            usersPassword: usersPasswordController.text);

        final state = context.read<UserLoginCubit>().state;

        if (state.userPermissions!.accountType == 'personal') {
          context.pushView(const SwitchAccount());
        } else if (state.merchantBusinessProfile!.isNotEmpty) {
          if (AppSettings.isHuaweiDevice) {
            context.read<SubscriptionHuaweiCubit>();
          } else {
            context.read<SubscriptionCubit>();
          }
          context.pushView(const SwitchBusiness());
        } else {
          context.pushView(
            const RegisterBusinessInformation(
              fromLogin: true,
            ),
          );
        }
        usersPasswordController.clear();
      } catch (e) {
        !bioLogin ? anErrorOccurredDialog(context, error: e.toString()) : null;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    passwordFocusNode.dispose();
    usersEmailController.dispose();
    usersPasswordController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentUser = context.read<UserLoginCubit>().currentUser;
    currentUser != null ? usersEmailController.text = currentUser.email : null;
  }

  @override
  Widget build(BuildContext context) {
    // context.setLocale(const Locale('en'));
    String currentLocale = context.locale.toString();

    Map<String, String> supportedLanguages = {
      "en": "English",
      "fr": "Français",
      "es": "Español",
      "pt": "Portuguese",
      "yo": "Yorùbá",
      "ig": "Igbo",
      "ha": "Hausa",
      "pd": "Pidgin English",
    };

    final userSettings = context.read<UserSettingsCubit>().state;

    return Scaffold(
        backgroundColor: context.theme.canvasColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: context.theme.canvasColor,
          elevation: 0,
          actions: [languagePicker(context, supportedLanguages, currentLocale)],
          centerTitle: false,
          title: const AppbarLogo(),
        ),
        body: BlocBuilder<UserLoginCubit, UsersState>(
          builder: (context, state) {
            final currentUser = context.read<UserLoginCubit>().currentUser;

            return AutofillGroup(
              child: Form(
                key: _formKey,
                child: Center(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    shrinkWrap: true,
                    children: [
                      25.h.height,
                      if (currentUser != null)
                        Column(
                          children: [
                            _WelcomeText(
                              userLogedIn: true,
                              usersFirstName: currentUser.firstName,
                            ),
                            15.h.height
                          ],
                        )
                      else
                        const _WelcomeText(),
                      Visibility(
                          visible: currentUser == null,
                          child: _InputField(
                            controller: usersEmailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LocaleKeys.required.tr();
                              } else if (!isEmail(value.trim())) {
                                return LocaleKeys.invalidEmail.tr();
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            hintText: LocaleKeys.email.tr(),
                            icon: Icons.email,
                            onEditingComplete: () {
                              FocusScope.of(context)
                                  .requestFocus(passwordFocusNode);
                            },
                          )),
                      15.h.height,
                      _InputField(
                        controller: usersPasswordController,
                        hintText: LocaleKeys.password.tr(),
                        isPasswordField: true,
                        onEditingComplete: () => _loginSubmit(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.required.tr();
                          }
                          return null;
                        },
                        keyboardType: TextInputType.visiblePassword,
                        node: passwordFocusNode,
                        icon: Icons.lock,
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        width: double.infinity,
                        child: TextButton(
                          style: const ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          onPressed: () {
                            context.pushView(const ForgotPassword());
                          },
                          child: Text(LocaleKeys.forgotPassword.tr()),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _loginSubmit(context),
                                child: Text(
                                  LocaleKeys.sIGNIN.tr().toUpperCase(),
                                ),
                              ),
                            ),
                            Visibility(
                                visible: userSettings.loginWithBiometrics,
                                child: IconButton(
                                    onPressed: () async {
                                      await biometricLogin();
                                    },
                                    icon: const Icon(Icons.fingerprint))),
                          ],
                        ),
                      ),
                      Builder(builder: (_) {
                        if (currentUser != null) {
                          return _NewToKiosk(
                            usersEmailController: usersEmailController,
                            userLogedIn: true,
                            usersFirstName: currentUser.firstName.toString(),
                          );
                        }
                        return const _NewToKiosk(
                          userLogedIn: false,
                        );
                      })
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}

class _NewToKiosk extends StatelessWidget {
  final TextEditingController? usersEmailController;
  final bool userLogedIn;
  final String? usersFirstName;
  const _NewToKiosk({
    this.usersEmailController,
    required this.userLogedIn,
    this.usersFirstName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (userLogedIn) {
          usersEmailController!.clear();
          context.read<UserSettingsCubit>().reset();
          await context.read<UserLoginCubit>().removeCurrentUser();
        } else {
          context.pushView(const EmailOtp(), replaceView: true);
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: context.theme.textTheme.bodyMedium!.copyWith(),
            children: <TextSpan>[
              TextSpan(
                text: userLogedIn
                    ? LocaleKeys.not.tr() + " " + usersFirstName! + '?'
                    : LocaleKeys.newToKiosk.tr() + " ",
                style: context.theme.textTheme.bodyMedium!.copyWith(
                    color: Colors.grey, fontWeight: FontWeight.normal),
              ),
              TextSpan(
                  text: userLogedIn
                      ? ' ' + LocaleKeys.unlockDevice.tr()
                      : ' ' + LocaleKeys.signUp.tr(),
                  style: context.theme.textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  final bool userLogedIn;
  final String usersFirstName;
  const _WelcomeText(
      {Key? key, this.usersFirstName = "", this.userLogedIn = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: userLogedIn
                  ? LocaleKeys.welcomeBack.tr() + ", "
                  : LocaleKeys.welcomeTo.tr() + ", ",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: Colors.grey, fontWeight: FontWeight.normal),
            ),
            TextSpan(
                text: userLogedIn ? usersFirstName : "Kiosk",
                style: context.theme.textTheme.headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;
  final Function()? onEditingComplete;

  final bool isPasswordField;

  final IconData icon;
  final TextInputType? keyboardType;
  final FocusNode? node;

  const _InputField({
    Key? key,
    this.isPasswordField = false,
    required this.controller,
    this.onEditingComplete,
    this.validator,
    this.keyboardType,
    required this.hintText,
    required this.icon,
    this.node,
  }) : super(key: key);

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool obscureText = false;

  @override
  void initState() {
    super.initState();
    if (widget.isPasswordField) {
      obscureText = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        focusNode: widget.node,
        autofillHints: [
          widget.isPasswordField ? AutofillHints.password : AutofillHints.email
        ],
        obscureText: obscureText,
        onEditingComplete: widget.onEditingComplete,
        validator: widget.validator,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
            suffixIcon: widget.isPasswordField
                ? Builder(builder: (context) {
                    return IconButton(
                      icon: Icon(
                          !obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    );
                  })
                : null,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            prefixIcon: Icon(
              widget.icon,
            ),
            hintText: widget.hintText),
      ),
    );
  }
}
