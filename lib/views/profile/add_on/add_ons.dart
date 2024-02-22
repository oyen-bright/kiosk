import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';

class AddOns extends StatelessWidget {
  const AddOns({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context,
          title: LocaleKeys.integrations.tr(),
          showNewsAndPromo: false,
          subTitle: LocaleKeys.profile.tr(),
          showNotifications: false,
          showBackArrow: true),
      body: ListView(
        children: [
          CustomContainer(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
              padding: EdgeInsets.all(16.r),
              child: Column(children: [
                ContainerHeader(
                    title: LocaleKeys.integrations.tr(),
                    subTitle: LocaleKeys
                        .ourPlatformIsDesignedToIntegrateSeamlesslyWithAVarietyOfThirdPartyToolsAndServices
                        .tr())
              ])),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              LocaleKeys.thereAreNoIntegrationsCurrentlyAvailableForYourAccount
                  .tr(),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
