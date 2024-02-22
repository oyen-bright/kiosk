import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        title: LocaleKeys.termsAndConditions.tr(),
        showBackArrow: true,
        subTitle: LocaleKeys.profile.tr(),
        showNewsAndPromo: false,
        showNotifications: false,
      ),
      body: Scrollbar(
        child: ListView(
          children: [
            FutureBuilder<String>(
              future: context.read<UserRepository>().getTermsAndConditions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Error(info: snapshot.error.toString());
                  }
                  if (snapshot.hasData) {
                    return TermsAndConditionsContent(
                        termsAndConditions: snapshot.data!);
                  }
                }
                return const LoadingState();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TermsAndConditionsContent extends StatelessWidget {
  final String termsAndConditions;

  const TermsAndConditionsContent({Key? key, required this.termsAndConditions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
      padding: EdgeInsets.all(16.r),
      child: SizedBox(
        width: double.infinity,
        child: AutoSizeText(
          termsAndConditions.replaceAll('“', ''),
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
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
                  child: AutoSizeText(LocaleKeys.termsAndConditions.tr(),
                      style: Theme.of(context).textTheme.titleMedium),
                )),
              ],
            ),
          ),
          LoadingWidget(
              isLinear: true, backgroundColor: context.theme.primaryColorLight)
        ]));
  }
}
