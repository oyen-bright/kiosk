import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/sales/sales/sales_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/sales.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/sales/sales_details.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

//TODO: implementation of the scrollbar

class SalesList extends StatelessWidget {
  final String? paymentMethod;
  final String? title;
  final bool isToday;
  const SalesList(
      {Key? key,
      this.isToday = false,
      this.paymentMethod,
      this.title = "Sales"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RefreshController _refreshController = RefreshController();

    if (context
            .read<SalesCubit>()
            .getSaleByPaymentMethod(paymentMethod ?? 'all_sales') ==
        null) {
      context.read<SalesCubit>().loadSales(paymentMethod: paymentMethod);
    }

    return Scaffold(
      appBar: customAppBar(context,
          title: title!, showNewsAndPromo: false, showSubtitle: false),
      body: SmartRefresher(
          controller: _refreshController,
          onRefresh: () => _onRefresh(_refreshController, context),
          child: BlocConsumer<SalesCubit, SalesState>(
            listener: (context, state) {
              if (state.salesStatus == SalesStatus.error) {
                context.snackBar(state.msg);
              }
            },
            builder: (context, state) {
              List<Sales>? sales;

              if (paymentMethod != null) {
                sales = context
                    .read<SalesCubit>()
                    .getSaleByPaymentMethod(paymentMethod!);
              } else {
                sales = state.sales;
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    CustomContainer(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(
                            horizontal: 22.w, vertical: 10.h),
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          children: [
                            ContainerHeader(
                              title: LocaleKeys.allSales.tr(),
                              subTitle: LocaleKeys
                                  .allSalesListProvidesAComprehensiveRecordOfEveryTransactionMadeByYourBusinessThisAllowsYouToReviewYourSalesHistoryTrackYourRevenueOverTimeAndIdentifyAnyTrendsOrPatternsInYourSalesData
                                  .tr(),
                            ),
                            if (state.salesStatus == SalesStatus.initial ||
                                sales == null)
                              const LoadingWidget(
                                isLinear: true,
                              ),
                            if (sales != null && sales.isNotEmpty)
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: sales.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (_, index) {
                                    final sale = sales![index];

                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 10.h),
                                      child: SalesWidget(
                                          data: sale,
                                          onTap: () => context.pushView(
                                              TransactionScreen(data: sale))),
                                    );
                                  }),
                          ],
                        )),
                    if (sales != null && sales.isNotEmpty)
                      if (state.totalCount[paymentMethod ?? 'all_sales']! >
                          sales.length) ...[
                        Center(
                          child: Builder(builder: (context) {
                            bool isLoading = false;
                            return StatefulBuilder(
                                builder: (context, setState) {
                              if (isLoading) {
                                return const CircularProgressIndicator();
                              }
                              return TextButton(
                                  onPressed: () async {
                                    setState(
                                      () => isLoading = true,
                                    );
                                    await context
                                        .read<SalesCubit>()
                                        .nextPage(paymentMethod: paymentMethod);
                                    setState(
                                      () => isLoading = false,
                                    );
                                  },
                                  child: const Text("Load More"));
                            });
                          }),
                        ),
                        50.height,
                      ]
                  ],
                ),
              );
            },
          )),
    );
  }

  Future _onRefresh(
      RefreshController _refreshController, BuildContext context) async {
    try {
      _refreshController.isRefresh;
      await context.read<SalesCubit>().loadSales(paymentMethod: paymentMethod);
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
      context.snackBar(e.toString());
    }
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
                  child: AutoSizeText("Sales",
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
