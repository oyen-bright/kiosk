import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/business_report.dart';
import 'package:kiosk/settings.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/amount_formatter.dart';
import 'package:kiosk/utils/get_currency.dart';
import 'package:kiosk/views/business/charts.dart';
import 'package:kiosk/views/generate_business_report/view_reports.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class BusinessReportView extends StatelessWidget {
  const BusinessReportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RefreshController _refreshController = RefreshController();
    final ScrollController _scrollController = ScrollController();

    return BlocConsumer<BusinessReportCubit, BusinessReportState>(
      listener: (context, state) async {
        if (state.status == ReportStatus.error) {
          context.snackBar(state.response.toString());
        }
      },
      builder: (context, state) {
        final isLoading = state.status == ReportStatus.initial;
        final businessReport = state.businessReport;

        if (isLoading) {
          return WillPopScope(
            onWillPop: () async => !isLoading,
            child: Scaffold(
                appBar: customAppBar(
                  context,
                  title: LocaleKeys.businessReport.tr(),
                  showBackArrow: true,
                  showNewsAndPromo: false,
                  showNotifications: false,
                  showSubtitle: false,
                ),
                body: Stack(
                  children: [
                    SmartRefresher(
                        controller: _refreshController,
                        onRefresh: () => onRefresh(context, _refreshController),
                        child:
                            ListView(controller: _scrollController, children: [
                          _HeaderInfo(
                              isLoading: isLoading,
                              businessReport: businessReport),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 10.h),
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.pushView(const ViewBusinessReports());
                              },
                              child: Text(
                                LocaleKeys.generateBusinessReport
                                    .tr()
                                    .toUpperCase(),
                              ),
                            ),
                          )
                        ])),
                    _buildUpgradePlayOverlay(context)
                  ],
                )),
          );
        }

        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Scaffold(
              appBar: customAppBar(
                context,
                title: LocaleKeys.businessReport.tr(),
                showBackArrow: true,
                showNewsAndPromo: false,
                showNotifications: false,
                showSubtitle: false,
              ),
              body: Stack(
                children: [
                  SmartRefresher(
                      controller: _refreshController,
                      onRefresh: () => onRefresh(context, _refreshController),
                      child: ListView(controller: _scrollController, children: [
                        _HeaderInfo(
                            isLoading: isLoading,
                            businessReport: businessReport),
                        Builder(builder: (_) {
                          if (isLoading || businessReport == null) {
                            return Container();
                          }
                          return Column(
                            children: [
                              _DailySaleBarChart(
                                  businessReport: businessReport),
                              20.h.height,
                              Chart(
                                businessReport: businessReport,
                              ),
                              20.h.height,
                              PieChat(
                                businessReport: businessReport,
                              ),
                              20.h.height,
                              MostSoldItem(
                                businessReport: businessReport,
                              )
                            ],
                          );
                        }),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 10.h),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.pushView(const ViewBusinessReports());
                            },
                            child: Text(
                              LocaleKeys.generateBusinessReport
                                  .tr()
                                  .toUpperCase(),
                            ),
                          ),
                        ),
                        40.h.height,
                      ])),
                  _buildUpgradePlayOverlay(context)
                ],
              )),
        );
      },
    );
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

  onRefresh(BuildContext context, RefreshController _refreshController) async {
    try {
      _refreshController.isRefresh;
      await context.read<BusinessReportCubit>().getFinancialReport();
      _refreshController.refreshCompleted();
    } catch (e) {
      context.snackBar(e.toString());
      _refreshController.refreshFailed();
    }
  }
}

class _HeaderInfo extends StatelessWidget {
  const _HeaderInfo({
    Key? key,
    required this.isLoading,
    required this.businessReport,
  }) : super(key: key);

  final bool isLoading;
  final BusinessReport? businessReport;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        padding: EdgeInsets.all(16.r),
        child: Column(children: [
          ContainerHeader(
              title: LocaleKeys.businessReport.tr(),
              subTitle: LocaleKeys
                      .ourBusinessReportProvidesAComprehensiveOverviewOfYourBusinessOperationsIncludingDailySalesFiguresTheMostSoldItemsAndFinancialReportsThisAllowsYouToMonitorYourBusinessPerformanceIdentifyAreasForImprovementAndMakeInformedDecisionsAboutYourOperations
                      .tr() +
                  "\n\n" +
                  LocaleKeys.bussnessRecomendation.tr()),
          Builder(builder: (_) {
            if (isLoading || businessReport == null) {
              return const LoadingWidget(
                isLinear: true,
              );
            }
            return Container();
          })
        ]));
  }
}

class _DailySaleBarChart extends StatelessWidget {
  const _DailySaleBarChart({
    Key? key,
    required this.businessReport,
  }) : super(key: key);

  final BusinessReport businessReport;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 400,
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: CustomContainer(
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 20.w, right: 20.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            height: 400,
            child: DailySalesBarChart(
              title: LocaleKeys.dailySales.tr(),
              subtitle: LocaleKeys
                  .dailySalesDataProvidesARealTimeSnapshotOfYourBusinessPerformanceAllowingYouToTrackYourRevenueIdentifyTrendsAndAdjustYourOperationsAccordinglyByMonitoringYourDailySalesFigures
                  .tr(),
              barBackgroundColor: context.theme.primaryColorLight,
              barColor: context.theme.colorScheme.primary.lighten(10),
              data: businessReport.dailySales,
              days: businessReport.days,
              touchedBarColor: context.theme.colorScheme.primary,
            ),
          )),
    );
  }
}

class Chart extends StatelessWidget {
  const Chart({
    Key? key,
    required this.businessReport,
  }) : super(key: key);
  final BusinessReport businessReport;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 400,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: CustomContainer(
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 20.w, right: 20.w),
            padding: EdgeInsets.all(16.r),
            height: 400,
            child: PaymentLineChart(
              months: businessReport.days,
              sales: [
                businessReport.cardDailyPaymentSale,
                businessReport.cashDailyPaymentSale,
                businessReport.kroonDailyPaymentSale,
                businessReport.mobileMoneyDailyPaymentSale,
              ],
            )),
      ),
    );
  }
}

class PieChat extends StatelessWidget {
  const PieChat({
    Key? key,
    required this.businessReport,
  }) : super(key: key);
  final BusinessReport businessReport;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 400,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: CustomContainer(
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 20.w, right: 20.w),
            padding: EdgeInsets.all(16.r),
            height: 400,
            child: MerchantRevenuePieChart(
              merchantRevenue: businessReport.merchantRevenue,
            )),
      ),
    );
  }
}

class MostSoldItem extends StatelessWidget {
  const MostSoldItem({
    Key? key,
    required this.businessReport,
  }) : super(key: key);
  final BusinessReport businessReport;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomContainer(
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 20.w, right: 20.w),
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              ContainerHeader(
                  title: LocaleKeys.bestSellingProducts.tr(),
                  subTitle: LocaleKeys
                      .knowingYourBestSellingProductsIsKeyToMaximizingYourRevenuePotentialByAnalyzingYourSalesDataYouCanIdentifyTheProductsThatAreMostPopularAmongYourCustomersAndAdjustYourInventoryAndMarketingStrategiesToCapitalizeOnTheseTrends
                      .tr()),
              for (var i in businessReport.bestSale)
                ListTile(
                  isThreeLine: false,
                  title: Text(
                    i.productProductName,
                    style: context.theme.textTheme.bodyMedium,
                  ),
                  subtitle: RichText(
                    text: TextSpan(
                      text: LocaleKeys.count.tr() + ' :',
                      style: context.theme.textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: i.total.toString(),
                          style: context.theme.textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: RichText(
                    text: TextSpan(
                      text: LocaleKeys.totalAmount.tr() + ' :',
                      style: context.theme.textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: amountFormatter(
                              i.totalAmount.toString(), getCurrency(context)),
                          style: context.theme.textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          )),
    );
  }
}
