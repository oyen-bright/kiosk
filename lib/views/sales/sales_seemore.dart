import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/sales/sales/sales_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/sales/sales_details.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

//TODO: implementation of the scrollbar
//Todo: snackbar on smart refresh fails

class SeeMoreSales extends StatelessWidget {
  const SeeMoreSales({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RefreshController _refreshController = RefreshController();

    return Scaffold(
      appBar: customAppBar(context,
          title: LocaleKeys.allSales.tr(),
          showNewsAndPromo: false,
          showSubtitle: false,
          showNotifications: false,
          actions: [],
          showBackArrow: true),
      body: SmartRefresher(
        onRefresh: () => _onRefresh(_refreshController, context),
        controller: _refreshController,
        child: BlocBuilder<SalesCubit, SalesState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(children: [
                CustomContainer(
                    alignment: Alignment.center,
                    margin:
                        EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      children: [
                        ContainerHeader(
                          title: LocaleKeys.allSales.tr(),
                          subTitle: LocaleKeys
                              .allSalesListProvidesAComprehensiveRecordOfEveryTransactionMadeByYourBusinessThisAllowsYouToReviewYourSalesHistoryTrackYourRevenueOverTimeAndIdentifyAnyTrendsOrPatternsInYourSalesData
                              .tr(),
                        ),
                        if (state.sales.isNotEmpty) ...[
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.sales.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (_, index) {
                                final sale = state.sales[index];

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: SalesWidget(
                                      data: sale,
                                      onTap: () => context.pushView(
                                          TransactionScreen(data: sale))),
                                );
                              }),
                        ] else
                          const LoadingWidget(
                            isLinear: true,
                          )
                      ],
                    )),
                if (state.totalCount['all_sales']! > state.sales.length) ...[
                  Center(
                    child: Builder(builder: (context) {
                      bool isLoading = false;
                      return StatefulBuilder(builder: (context, setState) {
                        if (isLoading) {
                          return const CircularProgressIndicator();
                        }
                        return TextButton(
                            onPressed: () async {
                              setState(
                                () => isLoading = true,
                              );
                              await context.read<SalesCubit>().nextPage();
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
              ]),
            );
          },
        ),
      ),
    );
  }

  void _onRefresh(
      RefreshController _refreshController, BuildContext context) async {
    try {
      _refreshController.isRefresh;
      await context.read<SalesCubit>().loadSales();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
      context.snackBar(e.toString());
    }
  }
}
