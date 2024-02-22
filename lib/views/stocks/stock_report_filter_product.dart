import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/offline/offline_cubit.dart';
import 'package:kiosk/cubits/stock/stock_report_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/inventory/inventory_edit_item.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class FilterProduct extends StatelessWidget {
  final bool isOutOfStock;
  const FilterProduct({Key? key, this.isOutOfStock = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final offlineMode = context.watch<OfflineCubit>().isOffline();

    return Scaffold(
        appBar: customAppBar(context,
            title: isOutOfStock
                ? LocaleKeys.outOfStock.tr()
                : LocaleKeys.lowOnStock.tr().titleCase,
            showSubtitle: false,
            showNewsAndPromo: false,
            showNotifications: false,
            actions: [],
            showBackArrow: true),
        body: Scrollbar(
          child: ListView(
            children: [
              CustomContainer(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    BlocBuilder<StockReportCubit, StockReportState>(
                      builder: (context, state) {
                        if (state.allProduct != null) {
                          List<Products> filteredProduct = [];
                          if (isOutOfStock) {
                            filteredProduct = state.outOfStock;
                          } else {
                            filteredProduct = state.lowOnStock;
                          }

                          return Column(children: [
                            ContainerHeader(
                                title: LocaleKeys.allProduct.tr() +
                                    " " +
                                    (isOutOfStock
                                        ? LocaleKeys.outOfStock.tr().titleCase
                                        : LocaleKeys.lowOnStock.tr().titleCase),
                                subTitle: LocaleKeys
                                    .aCompleteListOfEveryItemYouHaveAvailableForSaleInYourInventoryTapToEditProductAndManageInventoryLevelsToEnsureThatYouAlwaysHaveTheProductsYourCustomersWant
                                    .tr()),
                            for (var item in filteredProduct)
                              StockReportProduct(
                                isLowOnStock: !isOutOfStock,
                                data: item,
                                ontTap: () async {
                                  offlineMode
                                      ? offlineDialog(context)
                                      : await context.pushView(
                                          EditItemInInventory(
                                            product: item,
                                          ),
                                          animate: true);
                                },
                              )
                          ]);
                        }
                        return Column(children: [
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: AutoSizeText(isOutOfStock
                                        ? LocaleKeys.outOfStock.tr()
                                        : LocaleKeys.lowOnStock.tr().titleCase),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const LoadingWidget(
                            isLinear: true,
                          )
                        ]);
                      },
                    )
                  ],
                ),
              ),
              40.h.height
            ],
          ),
        ));
  }
}
