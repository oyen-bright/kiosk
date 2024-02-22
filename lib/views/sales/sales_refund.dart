import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/sales/sales/sales_cubit.dart';
import 'package:kiosk/extensions/navigation_extention.dart';
import 'package:kiosk/extensions/snackbar_extention.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/sales/sales_details.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

//TODO: implementation of the scrollbar

class SalesRefund extends StatelessWidget {
  final String? paymentMethod;
  final String? title;
  final bool isToday;
  const SalesRefund(
      {Key? key,
      this.isToday = false,
      this.paymentMethod,
      this.title = "Refund Sales"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RefreshController _refreshController = RefreshController();
    // final ScrollController _scrollController = ScrollController();

    return Scaffold(
      appBar: customAppBar(context,
          title: title!, showNewsAndPromo: false, showSubtitle: false),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: () => _onRefresh(_refreshController, context),
        child: ListView(
          children: [
            BlocConsumer<SalesCubit, SalesState>(
              listener: (context, state) {
                if (state.salesStatus == SalesStatus.error) {
                  context.snackBar(state.msg);
                }
              },
              builder: (context, state) {
                final sales = state.sales;
                if (sales.isNotEmpty) {
                  return CustomContainer(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(
                          horizontal: 22.w, vertical: 10.h),
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        children: [
                          ContainerHeader(
                              title: LocaleKeys.refundSale.tr(),
                              subTitle: LocaleKeys.refundSaleSubtitle.tr()),
                          SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  for (var sale in sales)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10.h),
                                      child: SalesWidget(
                                          data: sale,
                                          onTap: () async {
                                            if (!sale.isRefunded) {
                                              final res =
                                                  await refundsalesOptionsButtomSheet(
                                                      context,
                                                      sale.orderNumber);
                                              if (res != null) {
                                                context.pushView(
                                                    TransactionScreen(
                                                        data: sale));
                                              }
                                            }
                                          }),
                                    )
                                ],
                              )),
                        ],
                      ));
                }
                if (sales.isEmpty) {
                  return Container();
                }
                return const LoadingState();
              },
            )
          ],
        ),
      ),
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
                  child: AutoSizeText(LocaleKeys.sales.tr(),
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
