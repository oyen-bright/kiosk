import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/settings.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:kiosk/widgets/subscription/subscription_bottom_sheet_products.dart';

class SubscriptionBottomSheet extends StatefulWidget {
  const SubscriptionBottomSheet({Key? key}) : super(key: key);

  @override
  State<SubscriptionBottomSheet> createState() =>
      _SubscriptionBottomSheetState();
}

class _SubscriptionBottomSheetState extends State<SubscriptionBottomSheet> {
  SubscriptionType? _selectedSubscription;

  final data = [
    {
      'title': "Basic",
      "Subtitle": LocaleKeys.free.tr(),
      'value': SubscriptionType.free,
    },
    {
      'title': "KroonKiosk+",
      "Subtitle": LocaleKeys.paid.tr(),
      'value': SubscriptionType.kioskPlus,
    },
    {
      'title': "KroonKiosk Pro",
      "Subtitle": LocaleKeys.paid.tr(),
      'value': SubscriptionType.kioskPro,
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (AppSettings.isHuaweiDevice) {
      return BlocBuilder<SubscriptionHuaweiCubit, SubscriptionHuaweiState>(
          builder: (context, state) {
        switch (state.status) {
          case StoreStatus.storeUnavailable:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(LocaleKeys.storeIsCurentlyNotAvailable.tr()),
                  TextButton(
                      onPressed: () {
                        context.read<SubscriptionCubit>().reloadStore();
                      },
                      child: Text(LocaleKeys.retry.tr()))
                ],
              ),
            );
          case StoreStatus.storeLoaded:
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      LocaleKeys.chooseYourSubscriptionPlan.tr(),
                      style: context.theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    for (Map i in data)
                      Stack(
                        children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: ListTile(
                                leading: Radio<SubscriptionType>(
                                  value: i['value'],
                                  groupValue: _selectedSubscription,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSubscription = value;
                                    });
                                  },
                                ),
                                trailing: Text(
                                  i['Subtitle'] + "   ",
                                  style: context.theme.textTheme.bodySmall,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5.h, horizontal: 5.w),
                                title: Text(
                                  i['title'],
                                  style: context.theme.textTheme.titleSmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                tileColor: context.theme.canvasColor.darken(5),
                              )),
                          if (i['value'] == SubscriptionType.kioskPro)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    decoration: const BoxDecoration(
                                        color: Colors.purple,
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(5),
                                            bottomRight: Radius.circular(5))),
                                    child: Text(
                                      LocaleKeys.RECOMMENDED.tr(),
                                      style: context.theme.textTheme.bodySmall!
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            )
                        ],
                      ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text(LocaleKeys.continuE.tr()),
                        onPressed: () {
                          if (_selectedSubscription != null) {
                            context.pushView(SubscriptionBottomsheetPlanDisplay(
                              subscriptionType: _selectedSubscription!,
                            ));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );

          case StoreStatus.error:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(LocaleKeys.storeIsCurentlyNotAvailable.tr()),
                  Text(state.errorMessage ?? ""),
                  TextButton(
                      onPressed: () {
                        context.read<SubscriptionCubit>().reloadStore();
                      },
                      child: Text(LocaleKeys.retry.tr()))
                ],
              ),
            );

          case StoreStatus.loading:
            return const Center(
              child: LoadingWidget(),
            );
        }
      });
    }

    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        switch (state.status) {
          case StoreStatus.storeUnavailable:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(LocaleKeys.storeIsCurentlyNotAvailable.tr()),
                  TextButton(
                      onPressed: () {
                        context.read<SubscriptionCubit>().reloadStore();
                      },
                      child: Text(LocaleKeys.retry.tr()))
                ],
              ),
            );
          case StoreStatus.storeLoaded:
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      LocaleKeys.chooseYourSubscriptionPlan.tr(),
                      style: context.theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    for (Map i in data)
                      Stack(
                        children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    _selectedSubscription = i['value'];
                                  });
                                },
                                leading: Radio<SubscriptionType>(
                                  value: i['value'],
                                  groupValue: _selectedSubscription,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSubscription = value;
                                    });
                                  },
                                ),
                                trailing: Text(
                                  i['Subtitle'] + "   ",
                                  style: context.theme.textTheme.bodySmall,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5.h, horizontal: 5.w),
                                title: Text(
                                  i['title'],
                                  style: context.theme.textTheme.titleSmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                tileColor: context.theme.canvasColor.darken(5),
                              )),
                          if (i['value'] == SubscriptionType.kioskPro)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    decoration: const BoxDecoration(
                                        color: Colors.purple,
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(5),
                                            bottomRight: Radius.circular(5))),
                                    child: Text(
                                      LocaleKeys.RECOMMENDED.tr(),
                                      style: context.theme.textTheme.bodySmall!
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            )
                        ],
                      ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text(LocaleKeys.continuE.tr()),
                        onPressed: () {
                          if (_selectedSubscription != null) {
                            context.pushView(SubscriptionBottomsheetPlanDisplay(
                              subscriptionType: _selectedSubscription!,
                            ));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );

          case StoreStatus.error:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(LocaleKeys.storeIsCurentlyNotAvailable.tr()),
                  Text(state.errorMessage ?? ""),
                  TextButton(
                      onPressed: () {
                        context.read<SubscriptionCubit>().reloadStore();
                      },
                      child: Text(LocaleKeys.retry.tr()))
                ],
              ),
            );

          case StoreStatus.loading:
            return const Center(
              child: LoadingWidget(),
            );
        }
      },
    );
  }
}
