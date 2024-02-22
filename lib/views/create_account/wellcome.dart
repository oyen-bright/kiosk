import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/login/login.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class Wellcome extends StatefulWidget {
  const Wellcome({Key? key}) : super(key: key);

  @override
  State<Wellcome> createState() => _WellcomeState();
}

class _WellcomeState extends State<Wellcome> {
  @override
  void initState() {
    Timer(const Duration(seconds: 2), () {
      context.pushView(const LogIn(), clearStack: true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topCenter, children: [
      Image.asset(
        "assets/images/background.png",
        width: double.infinity,
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
      ),
      Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Expanded(
                    child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 40.w),
                              child:
                                  Image.asset("assets/images/Illustration.png"))
                        ]),
                  ),
                )),
                5.h.height,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w),
                  child: Column(children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        LocaleKeys.welcomeToKiosk.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                                color: context.theme.colorScheme.primary,
                                fontWeight: FontWeight.bold),
                      ),
                    ),
                    15.h.height,
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        LocaleKeys.voila.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    80.h.height
                  ]),
                ),
              ])))
    ]);
  }
}
