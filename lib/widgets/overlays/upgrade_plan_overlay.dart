import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/.constants.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';

class UpgradePlanOverlay extends StatelessWidget {
  const UpgradePlanOverlay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final kioskBlueTheme = context.theme.colorScheme.primary;
    return Container(
      alignment: Alignment.center,
      color: kioskBlueTheme.withOpacity(0.3),
      child: CustomContainer(
        width: double.infinity,
        padding: EdgeInsets.zero,
        boxShadow: const [],
        margin: EdgeInsets.symmetric(horizontal: 40.w),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Container(
              margin: EdgeInsets.only(top: 25.h),
              alignment: Alignment.center,
              width: double.infinity,
              child: Text(
                LocaleKeys.upgradeYourPlan.tr() + " !",
                style: context.theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10.h),
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Text(
                LocaleKeys.renewOrUpgradeYourPlan.tr(),
                textAlign: TextAlign.center,
                style: context.theme.textTheme.bodyMedium,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5.h),
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Text(
                LocaleKeys.yourCurrentPlanIsLimited.tr(),
                textAlign: TextAlign.center,
                style: context.theme.textTheme.bodyMedium!.copyWith(),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
              child: ElevatedButton(
                  onPressed: () async {
                    final offlineMode =
                        context.read<OfflineCubit>().isOffline();

                    if (offlineMode) {
                      offlineDialog(context);
                    } else {
                      showModalBottomSheet(
                          useRootNavigator: true,
                          context: context,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                          builder: (context) =>
                              const SizedBox(child: SubscriptionBottomSheet()));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: kioskYellow),
                  child: Text(LocaleKeys.uPGRADE.tr(),
                      style: const TextStyle().copyWith(color: kioskBlue))),
            )
          ],
        ),
      ),
    );
  }
}
