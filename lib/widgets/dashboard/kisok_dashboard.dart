import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/settings/user_settings_cubit.dart';
import 'package:kiosk/extensions/theme_extention.dart';
import 'package:kiosk/models/sales_report.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class KisokDashBoard extends StatelessWidget {
  final SalesReport salesReport;
  final List<GlobalKey> showCasekeys;
  final String currency;
  final String red;
  final String yellow;
  final String orange;

  const KisokDashBoard({
    Key? key,
    required this.showCasekeys,
    required this.salesReport,
    required this.red,
    required this.yellow,
    required this.orange,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final kioskBlue = context.theme.colorScheme.primary;
    final performance =
        '${salesReport.dailyReportData["sale_percentage"]["percentage"]}%';

    final totalSales =
        salesReport.dailyReportData["inventory"]["all_orders_count"].toString();

    final performanceColor = salesReport.dailyReportData["sale_percentage"]
                    ["percentage"]
                .toString()
                .substring(0, 1) ==
            "-"
        ? Colors.red
        : salesReport.dailyReportData["sale_percentage"]["percentage"]
                    .toString()
                    .substring(0, 1) ==
                "0"
            ? Colors.green
            : Colors.green;

    final salesTotal = amountFormatter(
      salesReport.dailyReportData["total_sales"]["total_sales"],
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 15.h),
      child: Showcase(
        key: showCasekeys[0],
        title: LocaleKeys.dashboard.tr(),
        targetBorderRadius: BorderRadius.circular(16.r),
        description: LocaleKeys
            .viewYourTotalSalesForTheDayYourCurrentPerformanceForTodaySSalesComparedToYesterdaysSalesYourInventoryStatusAndTheNumberOfSalesMadeDuringTheDay
            .tr(),
        child: CustomContainer(
          padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 11.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDailyTrade(
                  kioskBlue, context, performance, performanceColor),
              _buildSalesTotal(context, salesTotal, kioskBlue),
              _buildInventoryHealth(context, totalSales, kioskBlue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryHealth(
      BuildContext context, String totalSales, Color kioskBlue) {
    return GestureDetector(
      onTap: (() => showinformationDialog(context,
          title: LocaleKeys.inventoryHealth.tr(),
          information: LocaleKeys.thisIsYourInventoryHealthTrackerInfo.tr())),
      child: Row(
        children: [
          Flexible(
              child: Showcase(
            key: showCasekeys[3],
            title: LocaleKeys.inventoryHealth.tr(),
            targetBorderRadius: BorderRadius.circular(5.r),
            targetPadding: EdgeInsets.all(10.r),
            description: LocaleKeys.thisIsYourInventoryHealthTrackerInfo.tr(),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: AutoSizeText(
                    LocaleKeys.inventoryHealth.tr(),
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Text(
                        orange,
                        style: const TextStyle(color: Colors.green),
                      ),
                      25.w.width,
                      Text(
                        yellow,
                        style: const TextStyle(
                            color: Color.fromRGBO(247, 181, 0, 1)),
                      ),
                      25.w.width,
                      Text(
                        red,
                        style: const TextStyle(color: Colors.red),
                      ),
                      10.w.width,
                    ],
                  ),
                ),
              ],
            ),
          )),
          Flexible(
            child: GestureDetector(
              onTap: (() => showinformationDialog(context,
                  title: LocaleKeys.salesCount.tr(),
                  information: "Shows the number of sales made for the day.")),
              child: Showcase(
                key: showCasekeys[2],
                title: LocaleKeys.saleCount.tr(),
                targetBorderRadius: BorderRadius.circular(5.r),
                targetPadding: EdgeInsets.all(10.r),
                description:
                    LocaleKeys.indicateTheNumberOfSalesCarriedOutForTheDay.tr(),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: AutoSizeText(
                        LocaleKeys.salesCount.tr(),
                        maxLines: 1,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: AutoSizeText(totalSales,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          style: TextStyle(
                            color: kioskBlue,
                          )),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSalesTotal(
      BuildContext context, String salesTotal, Color kioskBlue) {
    return Showcase(
      key: showCasekeys[1],
      title: LocaleKeys.trackYourSales.tr(),
      targetBorderRadius: BorderRadius.circular(5.r),
      targetPadding: EdgeInsets.all(10.r),
      description: LocaleKeys.displaysTheFullAmountOfSalesMadeForTheDay.tr(),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 5.h),
            width: double.infinity,
            child: AutoSizeText(LocaleKeys.salesTotal.tr()),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                currency,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.theme.colorScheme.primary,
                ),
              ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.only(left: 5.w),
                child: Row(
                  children: [
                    BlocBuilder<UserSettingsCubit, UserSettingsState>(
                      builder: (context, state) {
                        final showKioskBalance = state.showKioskBalance;

                        return AutoSizeText(
                          hideAccBalance(context, salesTotal,
                              hideBalance: !showKioskBalance),
                          style: context.theme.textTheme.titleLarge!.copyWith(
                            color: kioskBlue,
                          ),
                        );
                      },
                    ),
                    3.w.width,
                    const ShowHideBalance(),
                  ],
                ),
              ))
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTrade(Color kioskBlue, BuildContext context,
      String performance, MaterialColor performanceColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            child: SizedBox(
          child: AutoSizeText(
            LocaleKeys.dailyTrade.tr(),
            maxLines: 1,
            style: TextStyle(color: kioskBlue, fontWeight: FontWeight.bold),
          ),
        )),
        Flexible(
          child: GestureDetector(
            onTap: (() => showinformationDialog(context,
                title: LocaleKeys.performance.tr() + " !",
                information: LocaleKeys.trackYourSalesPerformanceInfo.tr())),
            child: Showcase(
              key: showCasekeys[4],
              title: LocaleKeys.performance.tr(),
              targetBorderRadius: BorderRadius.circular(5.r),
              targetPadding: EdgeInsets.all(10.r),
              description: LocaleKeys.trackYourSalesPerformanceInfo.tr(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AutoSizeText(
                    LocaleKeys.performance.tr(),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: AutoSizeText(performance,
                        maxLines: 1, style: TextStyle(color: performanceColor)),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class ShowHideBalance extends StatelessWidget {
  const ShowHideBalance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final kioskBlue = context.theme.colorScheme.primary;

    return GestureDetector(
      onTap: () async {
        context.read<UserSettingsCubit>().toggleShowKioskBalance();
      },
      child: Builder(builder: (context) {
        if (context.watch<UserSettingsCubit>().state.showKioskBalance) {
          return Icon(
            Icons.visibility_off,
            color: kioskBlue,
          );
        }
        return Icon(
          Icons.visibility,
          color: kioskBlue,
        );
      }),
    );
  }
}
