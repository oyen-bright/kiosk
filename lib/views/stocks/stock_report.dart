import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/constant_color.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/settings.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/amount_formatter.dart';
import 'package:kiosk/utils/get_currency.dart';
import 'package:kiosk/views/stocks/stock_report_all_product.dart';
import 'package:kiosk/views/stocks/stock_report_filter_product.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

import '../business/business_report_intro.dart';

class StockReport extends StatelessWidget {
  const StockReport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // context.read<AnalyticsService>().logOpenStockReport();

    return Scaffold(
        appBar: customAppBar(context,
            title: LocaleKeys.inventoryReport.tr(),
            showNewsAndPromo: false,
            showSubtitle: false,
            showNotifications: true,
            showBackArrow: true),
        body: Stack(
          children: [
            BlocBuilder<StockReportCubit, StockReportState>(
              builder: (context, state) {
                return ListView(
                  children: [
                    _buildStockReportDetails(context, state),
                    _buildMostSoldItems(state),
                    _buildStockValue(state),
                    10.h.height,
                    _buildCreateBusinessProfile(),
                    50.h.height,
                  ],
                );
              },
            ),
            _buildUpgradePlayOverlay(context)
          ],
        ));
  }
}

Builder _buildUpgradePlayOverlay(BuildContext context) {
  return Builder(builder: (_) {
    final canAcess = AppSettings.isHuaweiDevice
        ? context.watch<SubscriptionHuaweiCubit>().checkAccess()
        : context.watch<SubscriptionCubit>().checkAccess();

    if (!canAcess) {
      return const UpgradePlanOverlay();
    }
    return Container();
  });
}

Builder _buildCreateBusinessProfile() {
  return Builder(builder: (context) {
    final isAWorker = context.read<UserCubit>().state.permissions!.isAWorker;

    if (!isAWorker) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
        child: ElevatedButton(
            onPressed: () {
              context.pushView(
                const BuisnessPlan(),
              );
            },
            child: Text(LocaleKeys.generateBusinessReport.tr().toUpperCase())),
      );
    }
    return Container();
  });
}

Padding _buildStockValue(StockReportState state) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 0.h),
    child: BalanceDisplay(
      obsucre: false,
      title: LocaleKeys.stockValue.tr(),
      value: amountFormatter(state.stockValue),
    ),
  );
}

Builder _buildMostSoldItems(StockReportState state) {
  return Builder(builder: (context) {
    if (state.mostSoldItems.isEmpty) {
      return Container();
    }
    return CustomContainer(
        height: 205.h,
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                      child: SizedBox(
                    child: AutoSizeText(
                      LocaleKeys.mostSoldItems.tr(),
                      maxLines: 1,
                    ),
                  )),
                ],
              ),
            ),
            20.h.height,
            Expanded(
              child: SizedBox(
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  for (var item in state.mostSoldItems)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: SizedBox(
                        width: 0.7.sw,
                        child: ItemSale3(
                          imageUrl: (item["product__image"]?.isEmpty) ?? false
                              ? null
                              : "https://nyc3.digitaloceanspaces.com/test-server-space/kroon-kiosk-test-static/" +
                                  (item["product__image"] ?? ""),
                          count: item["total"].toString(),
                          name: item["product__product_name"],
                          price: amountFormatter(item["total_revenue"] ?? 0),
                          variation:
                              item["variation__variations_category"] == null
                                  ? ""
                                  : item["variation__variations_category"]
                                          .toString()
                                          .toUpperCase() +
                                      " : " +
                                      item["variation__variation_value"],
                          currency: getCurrency(context),
                        ),
                      ),
                    )
                ]),
              ),
            ),
          ],
        ));
  });
}

SizedBox _buildStockReportDetails(BuildContext cx, StockReportState state) {
  return SizedBox(
    width: double.infinity,
    child: GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      primary: false,
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      crossAxisCount: 2,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          child: StockReportInfoCard(
              callback: () {
                cx.pushView(const AllProduct());
              },
              title: LocaleKeys.uploadedItems.tr(),
              value: state.uploadedItemsCount.toString(),
              backgroundColor: uploadedItemBG),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: StockReportInfoCard(
              callback: () {},
              title: LocaleKeys.soldItems.tr(),
              value: state.soldItemsCount.toString(),
              backgroundColor: soldItemBG),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: StockReportInfoCard(
              value: state.lowOnStockCount.toString(),
              title: LocaleKeys.lowStockItems.tr(),
              callback: () {
                cx.pushView(const FilterProduct(
                  isOutOfStock: false,
                ));
              },
              backgroundColor: lowStockItemBG),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: StockReportInfoCard(
              value: state.outOfStockCount.toString(),
              title: LocaleKeys.outOfStockItems.tr(),
              callback: () {
                cx.pushView(const FilterProduct());
              },
              backgroundColor: outOfStockItemBG),
        ),
      ],
    ),
  );
}
