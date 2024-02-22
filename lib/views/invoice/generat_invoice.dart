import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/sales/sales/sales_cubit.dart';
import 'package:kiosk/service/api/urls.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class GenerateInvoice extends StatelessWidget {
  const GenerateInvoice({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context,
          title: LocaleKeys.generateReceipt.tr(),
          showNewsAndPromo: false,
          showNotifications: true,
          showSubtitle: false,
          showBackArrow: true),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(children: [
            CustomContainer(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    BlocBuilder<SalesCubit, SalesState>(
                        builder: (context, state) {
                      if (state.salesStatus == SalesStatus.loaded) {
                        final sales = state.sales;

                        return Column(
                          children: [
                            ContainerHeader(
                                title: LocaleKeys.generateReceipt.tr(),
                                subTitle: LocaleKeys
                                    .afterEachTransactionAReceiptIsAutomaticallyGeneratedThatYouCanViewOrShareWithYourCustomersThisProvidesAConvenientAndProfessionalWayToConfirmTheDetailsOfTheTransactionAndProvideARecordOfTheSale
                                    .tr()),
                            Column(
                              children: List.generate(sales.length, (index) {
                                final data = sales[index];

                                String invoiceUrl = EndPoints.base +
                                    "invoice/${data.orderNumber}/";
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: SalesWidget(
                                    onTap: () {
                                      data.orderNumber == "Offline Sale"
                                          ? null
                                          : salesOptionsBottomSheet(context,
                                              invoiceUrl, data.orderNumber);
                                    },
                                    data: data,
                                  ),
                                );
                              }),
                            ),
                          ],
                        );
                      }
                      return const LoadingWidget(
                        isLinear: true,
                      );
                    }),
                  ],
                )),
            40.h.height
          ]),
        ),
      ),
    );
  }
}
