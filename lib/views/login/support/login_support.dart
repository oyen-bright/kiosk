import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/.constants.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/theme/app_theme.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class LoginSupport extends StatefulWidget {
  const LoginSupport({Key? key}) : super(key: key);

  @override
  State<LoginSupport> createState() => _LoginSupportState();
}

class _LoginSupportState extends State<LoginSupport> {
  String packageName = "";
  String appVersion = "";
  String appBuildNumber = "";

  void getAppInfo() async {
    PackageInfo packageInfor = await PackageInfo.fromPlatform();
    setState(() {
      packageName = packageInfor.packageName;
      appVersion = packageInfor.version;
      appBuildNumber = packageInfor.buildNumber;
    });
  }

  PreferredSizeWidget _appVersion(BuildContext context, String appVersion) {
    return PreferredSize(
      preferredSize: Size.fromHeight(10.0.h), // here the desired height
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        margin: EdgeInsets.only(bottom: 4.h),
        width: double.infinity,
        child: Text("App Version: " + appVersion,
            textAlign: TextAlign.right,
            style: context.theme.textTheme.bodyMedium!
                .copyWith(color: context.theme.colorScheme.primary)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getAppInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: kioskGrayBGColor(context),
          appBar: AppBar(
              bottom: _appVersion(context, appVersion),
              backgroundColor: context.theme.canvasColor,
              elevation: 0,
              centerTitle: true,
              title: Text(
                LocaleKeys.support.tr(),
                style: const TextStyle()
                    .copyWith(color: context.theme.colorScheme.primary),
              )),
          body: ListView(children: [
            Column(
              children: [
                4.h.height,
                _Supports(dataSupport: dataSupport),
                10.h.height,
                _Socials(dataSocials: dataSocials),
                10.h.height,
                const _Email(),
              ],
            ),
          ]),
        ),
      ],
    );
  }
}

class _Email extends StatelessWidget {
  const _Email({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: context.theme.canvasColor,
        child: Column(
          children: [
            10.h.height,
            Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: SizedBox(
                width: double.infinity,
                child: Text(LocaleKeys.emailUs.tr(),
                    style: context.theme.textTheme.titleSmall!),
              ),
            ),
            4.h.height,
            SocialTile(
              emailUsData["title"],
              icon: emailUsData["icon"],
              onTap: emailUsData["funtion"] as VoidCallback,
            )
          ],
        ));
  }
}

class _Socials extends StatelessWidget {
  const _Socials({
    Key? key,
    required this.dataSocials,
  }) : super(key: key);

  final List<Map> dataSocials;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: context.theme.canvasColor,
        width: double.infinity,
        child: Column(
          children: [
            10.h.height,
            Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: SizedBox(
                width: double.infinity,
                child: Text(LocaleKeys.socialMedia.tr(),
                    style: context.theme.textTheme.titleSmall!),
              ),
            ),
            4.h.height,
            for (var i in dataSocials)
              SocialTile(
                i["title"],
                onTap: i["funtion"] as VoidCallback,
                icon: i["icon"],
                iconBgColor:
                    context.theme.colorScheme.primary.withOpacity(0.04),
              ),
          ],
        ));
  }
}

class _Supports extends StatelessWidget {
  const _Supports({
    Key? key,
    required this.dataSupport,
  }) : super(key: key);

  final List<Map> dataSupport;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        color: context.theme.canvasColor,
        child: Column(
          children: [
            10.h.height,
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: SizedBox(
                width: double.infinity,
                child: Text(LocaleKeys.support.tr(),
                    style: context.theme.textTheme.titleSmall!),
              ),
            ),
            4.h.height,
            for (var i in dataSupport)
              SupportTile(
                i["title"],
                onTap: () => context.pushView(i["funtion"] as Widget),
                icon: i["icon"],
              ),
          ],
        ));
  }
}
