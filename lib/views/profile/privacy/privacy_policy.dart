import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context,
          title: LocaleKeys.privacyPolicy.tr(),
          showBackArrow: true,
          subTitle: LocaleKeys.profile.tr(),
          showNewsAndPromo: false,
          showNotifications: false),
      body: Scrollbar(
        child: ListView(
          children: [
            FutureBuilder<String>(
                future: context.read<UserRepository>().getPrivacyPolicy(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Error(info: snapshot.error.toString());
                    }
                    if (snapshot.hasData) {
                      return PrivacyPolicyContent(
                          privacyPolicy: snapshot.data!.toString());
                    }
                  }
                  return const LoadingState();
                }),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyContent extends StatelessWidget {
  final String privacyPolicy;

  const PrivacyPolicyContent({Key? key, required this.privacyPolicy})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                privacyPolicy.replaceAll('“', ''),
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ));
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
        padding: EdgeInsets.all(16.r),
        child: Column(children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                    child: SizedBox(
                  width: double.infinity,
                  child: AutoSizeText(LocaleKeys.privacyPolicy.tr(),
                      style: Theme.of(context).textTheme.titleMedium),
                )),
              ],
            ),
          ),
          const LoadingWidget(
            isLinear: true,
          )
        ]));
  }
}
