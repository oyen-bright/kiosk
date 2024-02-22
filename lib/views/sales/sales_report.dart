import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/.constants.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/sales_report.dart' as model_rales_report;
import 'package:kiosk/settings.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/amount_formatter.dart';
import 'package:kiosk/utils/get_currency.dart';
import 'package:kiosk/views/business/business_report.dart';
import 'package:kiosk/views/sales/sales.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

//Todo check for kroon sales on endpoint

class SalesReport extends StatelessWidget {
  const SalesReport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // context.read<AnalyticsService>().logOpenSalesReport();
    final RefreshController _refreshController = RefreshController();

    return Scaffold(
        appBar: customAppBar(context,
            title: LocaleKeys.salesReport.tr(),
            showNewsAndPromo: false,
            showSubtitle: false,
            showNotifications: true,
            showBackArrow: true),
        body: Stack(children: [
          BlocConsumer<SalesReportCubit, SalesReportState>(
            listener: (context, state) {
              if (state.salesReportStatus == SalesReportStatus.error) {
                context.snackBar(state.msg);
              }
            },
            builder: (context, state) {
              if (state.salesReport != null) {
                final salesReport = state.salesReport!;
                return SmartRefresher(
                  controller: _refreshController,
                  onRefresh: () async {
                    _refreshController.isRefresh;
                    await context.read<SalesReportCubit>().getSaleReport();
                    _refreshController.refreshCompleted();
                  },
                  child: ListView(
                    children: [
                      _buildSalesDetails(context, salesReport),
                      _buildMostSoldItem(salesReport),
                      _buildStockValue(salesReport),
                      10.h.height,
                      _buildCreateBusinessProfile(),
                      50.h.height
                    ],
                  ),
                );
              }
              return Container(
                  color: context.theme.scaffoldBackgroundColor,
                  child: const LoadingWidget(title: ""));
            },
          ),
          _buildUpgradePlayOverlay(context)
        ]));
  }

  Builder _buildUpgradePlayOverlay(BuildContext context) {
    return Builder(builder: (_) {
      final canAccess = AppSettings.isHuaweiDevice
          ? context.watch<SubscriptionHuaweiCubit>().checkAccess()
          : context.watch<SubscriptionCubit>().checkAccess();

      if (!canAccess) {
        return const UpgradePlanOverlay();
      }
      return Container();
    });
  }
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
                  const BusinessReportView(),
                );
              },
              child:
                  Text(LocaleKeys.generateBusinessReport.tr().toUpperCase())));
    }
    return Container();
  });
}

Padding _buildStockValue(model_rales_report.SalesReport salesReport) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 0.h),
    child: BalanceDisplay(
      obsucre: false,
      title: LocaleKeys.stockValue.tr(),
      value: amountFormatter(salesReport.stockReport!["cost_sales_total"]),
    ),
  );
}

SizedBox _buildSalesDetails(
    BuildContext context, model_rales_report.SalesReport salesReport) {
  return SizedBox(
    width: double.infinity,
    child: Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          child: SalesReportInfoCard(
              currency: getCurrency(context) + " ",
              callback: () {
                context.pushView(SalesList(
                  title: LocaleKeys.totalSales.tr(),
                ));
              },
              title: LocaleKeys.totalSales.tr(),
              value: amountFormatter(
                  salesReport.allReportData["total_sales"]["total_sales"]),
              backgroundColor: totalSalesBG),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: SalesReportInfoCard(
              currency: getCurrency(context) + " ",
              callback: () {
                context.pushView(SalesList(
                  paymentMethod: "card_payment",
                  title: LocaleKeys.cardSales.tr(),
                ));
              },
              title: LocaleKeys.cardSales.tr(),
              value: amountFormatter(
                  salesReport.allReportData["total_sales"]["card_sales"]),
              backgroundColor: cardSalesBG),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: SalesReportInfoCard(
              currency: getCurrency(context) + " ",
              value: amountFormatter(
                  salesReport.allReportData["total_sales"]["cash_sale"]),
              title: LocaleKeys.cashSales.tr(),
              callback: () {
                context.pushView(SalesList(
                  paymentMethod: "cash_payment",
                  title: LocaleKeys.cashSales.tr(),
                ));
              },
              backgroundColor: cashSalesBG),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: SalesReportInfoCard(
              currency: getCurrency(context) + " ",
              value: amountFormatter(salesReport.allReportData["total_sales"]
                  ["mobile_money_sales"]),
              title: "Mobile Money ${LocaleKeys.sales.tr()}",
              callback: () {
                context.pushView(SalesList(
                  title: "Mobile Money ${LocaleKeys.sales.tr()}",
                  paymentMethod: "mobile_money_payment",
                ));
              },
              backgroundColor: mobileMoneySalesBG),
        ),
      ],
    ),
  );
}

Builder _buildMostSoldItem(model_rales_report.SalesReport salesReport) {
  return Builder(builder: (context) {
    final mostSoldItems =
        salesReport.stockReport!["most_sold_products"] as List<dynamic>;

    if (mostSoldItems.isEmpty) {
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
                      child: AutoSizeText(
                    LocaleKeys.mostSoldItems.tr(),
                    maxLines: 1,
                  )),
                ],
              ),
            ),
            20.h.height,
            Expanded(
              child: SizedBox(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var i
                        in salesReport.stockReport!["most_sold_products"])
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: SizedBox(
                          width: 0.7.sw,
                          child: ItemSale3(
                            imageUrl: (i["product__image"]?.isEmpty) ?? false
                                ? null
                                : "https://nyc3.digitaloceanspaces.com/test-server-space/kroon-kiosk-test-static/" +
                                    (i["product__image"] ?? ""),
                            count: i["total"].toString(),
                            name: i["product__product_name"],
                            price: amountFormatter(i["total_revenue"] ?? 0),
                            variation:
                                i["variation__variations_category"] == null
                                    ? ""
                                    : i["variation__variations_category"]
                                            .toString()
                                            .toUpperCase() +
                                        " : " +
                                        i["variation__variation_value"],
                            currency: getCurrency(context),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ],
        ));
  });
}
