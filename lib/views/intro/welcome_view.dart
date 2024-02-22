import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/email_otp/email_otp.dart';
import 'package:kiosk/views/login/login.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: context.theme.canvasColor,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: context.theme.canvasColor,
            elevation: 0,
            centerTitle: false,
            title: const AppbarLogo()),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Image(),
            const _Text(),
            35.h.height,
            const _Buttons(),
            10.h.height
          ],
        ),
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          width: double.infinity,
          child: Image.asset("assets/images/Illustration.png")),
    );
  }
}

class _Text extends StatelessWidget {
  const _Text();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(LocaleKeys.welcomeToKiosk.tr(),
              textAlign: TextAlign.center,
              style: context.theme.textTheme.headlineMedium!
                  .copyWith(fontWeight: FontWeight.bold)),
        ),
        10.h.height,
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(LocaleKeys.joinAwesomeMerchantsAll.tr(),
              textAlign: TextAlign.justify,
              style: context.theme.textTheme.titleMedium!),
        ),
      ],
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _CustomButton(
              text: LocaleKeys.signInAsWorker.tr(),
              onPressed: () {
                context.pushView(const LogIn());
              },
            ),
            5.h.height,
            _CustomButton(
              text: LocaleKeys.signInAsMerchant.tr(),
              color: Colors.black,
              onPressed: () {
                context.pushView(const LogIn());
              },
            ),
            5.h.height,
            _CustomButton(
              text: LocaleKeys.signUp.tr(),
              color: Colors.black,
              onPressed: () async {
                context.pushView(const EmailOtp());
              },
            ),
            20.h.height
          ],
        ),
      ),
    );
  }
}

class _CustomButton extends StatelessWidget {
  final void Function()? onPressed;
  final Color? color;
  final String text;
  const _CustomButton({
    this.color,
    required this.text,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(),
        onPressed: onPressed,
        child: Text(
          text.toUpperCase(),
        ),
      ),
    );
  }
}
