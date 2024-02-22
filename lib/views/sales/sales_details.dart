import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/sales.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/service/api/urls.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/amount_formatter.dart';
import 'package:kiosk/utils/get_currency.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class TransactionScreen extends StatefulWidget {
  final Sales data;
  const TransactionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  Widget build(BuildContext context) {
    final orderNumber = widget.data.orderNumber;
    String? customersChange;
    String? cashReceived;
    String invoiceUrl = EndPoints.base + "invoice/${widget.data.orderNumber}/";

    return Scaffold(
        appBar: customAppBar(context,
            showSubtitle: false,
            title: LocaleKeys.sale.tr(),
            actions: [
              orderNumber == "Offline Sale"
                  ? Container()
                  : IconButton(
                      onPressed: () => salesOptionsBottomSheet(
                          context, invoiceUrl, orderNumber),
                      icon: Icon(
                        Icons.more_vert,
                        color: context.theme.colorScheme.primary,
                      )),
            ]),
        body: FutureBuilder<List<dynamic>>(
            future: context
                .read<UserRepository>()
                .getSaleDetails(saleId: widget.data.orderNumber),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Error(
                    info: snapshot.error.toString(),
                  );
                }

                if (snapshot.hasData) {
                  final saleDetail = snapshot.data!;

                  int itemCount = 0;
                  String worker = "";

                  for (var i in saleDetail) {
                    itemCount +=
                        (i["quantity"] == 0 ? 1 : i["quantity"]) as int;
                    customersChange =
                        i["payment"]["customers_change"].toString();
                    cashReceived = i["payment"]["cash_collected"].toString();
                    worker = i["worker"];
                  }

                  return _buildItems(orderNumber, saleDetail, itemCount, worker,
                      cashReceived, customersChange);
                }
              }

              return _buildInitialItems(
                  orderNumber, cashReceived, customersChange);
            }));
  }

  Column _buildInitialItems(
      String orderNumber, String? cashReceived, String? customersChange) {
    return Column(
      children: [
        Expanded(
            child: ListView(
          children: [
            CustomContainer(
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
                            child: AutoSizeText(" $orderNumber "),
                          )),
                        ],
                      ),
                    ),
                    const LoadingWidget(
                      isLinear: true,
                    )
                  ],
                )),
          ],
        )),
        LoadingBottomInfo(
            data: widget.data,
            cashReceived: cashReceived,
            customersChange: customersChange),
        35.h.height
      ],
    );
  }

  Column _buildItems(
      String orderNumber,
      List<dynamic> saleDetail,
      int itemCount,
      String worker,
      String? cashReceived,
      String? customersChange) {
    return Column(
      children: [
        Expanded(
            child: ListView(
          children: [
            KioskSlidable(
              onPressed: (context) async {
                final res = await refundSaleBottomSheet(context, orderNumber);
                if (res != null) {
                  setState(() {});
                }
              },
              child: Builder(builder: (context) {
                return GestureDetector(
                  onTap: () => Slidable.of(context)!.openEndActionPane(),
                  child: CustomContainer(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(
                          horizontal: 22.w, vertical: 10.h),
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                    child: SizedBox(
                                  child: AutoSizeText("$orderNumber "),
                                )),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Column(children: [
                            for (var i in saleDetail)
                              ItemSale2(
                                slidablePressed: (context) async {
                                  final res =
                                      await refundProductSaleBottomSheet(
                                          context, Map.from(i), orderNumber);

                                  if (res != null) {
                                    setState(() {});
                                  }
                                },
                                refundCount: i["refund_quantity"],
                                isRefunded: i["refund"] ?? false,
                                currency: '',
                                refundPrice:
                                    i["refund_product_price"] ?? "0.00",
                                count: i["quantity"] == 0
                                    ? "1"
                                    : i["quantity"].toString(),
                                imageUrl: i["product"]['product_sku'] == "MS"
                                    ? "MS"
                                    : i["product"]['image'] ?? "",
                                name: i["product"]["product_name"],
                                variation: i["variation"].isEmpty
                                    ? i["product"]["product_sku"]
                                    : i["variation"][0]["variation_value"],
                                price: i["product"]['product_sku'] == "MS"
                                    ? amountFormatter(
                                        double.parse(i["product_total_price"]))
                                    : amountFormatter(
                                        double.parse(i["product"]["price"])),
                              )
                          ]),
                        ],
                      )),
                );
              }),
            ),
          ],
        )),
        LoadedButtomInfo(
            data: widget.data,
            itemCount: itemCount,
            worker: worker,
            cashReceived: cashReceived,
            customersChange: customersChange),
        35.h.height
      ],
    );
  }
}

class LoadingBottomInfo extends StatelessWidget {
  const LoadingBottomInfo({
    Key? key,
    required this.data,
    required this.cashReceived,
    required this.customersChange,
  }) : super(key: key);

  final Sales data;
  final String? cashReceived;
  final String? customersChange;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 0.h),
        padding: EdgeInsets.all(16.r),
        color: context.theme.primaryColorLight,
        child: Column(
          children: [
            _buildRow(context, LocaleKeys.totalAmount.tr(),
                getCurrency(context) + " " + amountFormatter(data.orderTotal),
                bold: true),
            _buildRow(context, LocaleKeys.items.tr(), 0.toString(), bold: true),
            _buildRow(context, LocaleKeys.paymentMethod.tr(),
                _getPaymentMethodString(data.payment["payment_method"])),
            if (data.worker != "")
              _buildRow(context, LocaleKeys.worker.tr(), data.worker),
            if (data.payment["payment_method"] == "cash_payment") ...[
              _buildRow(
                  context,
                  LocaleKeys.cashCollected.tr(),
                  amountFormatter(
                      double.parse(cashReceived ?? 0.00.toString()))),
              _buildRow(
                  context,
                  LocaleKeys.customerChange.tr(),
                  amountFormatter(
                      double.parse(customersChange ?? 0.00.toString()))),
            ],
            _buildRow(context, LocaleKeys.date.tr(),
                _getFormattedDateTimeString(data.createdDate)),
          ],
        ));
  }
}

class LoadedButtomInfo extends StatelessWidget {
  const LoadedButtomInfo({
    Key? key,
    required this.data,
    required this.itemCount,
    required this.worker,
    required this.cashReceived,
    required this.customersChange,
  }) : super(key: key);

  final Sales data;
  final int itemCount;
  final String worker;
  final String? cashReceived;
  final String? customersChange;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 0.h),
      padding: EdgeInsets.all(16.r),
      color: context.theme.primaryColorLight,
      child: Column(
        children: [
          _buildRow(
            context,
            LocaleKeys.totalAmount.tr(),
            getCurrency(context) + " " + amountFormatter(data.orderTotal),
            bold: true,
          ),
          SizedBox(height: 5.h),
          _buildRow(
            context,
            LocaleKeys.items.tr(),
            itemCount.toString(),
            bold: true,
          ),
          _buildRow(
            context,
            LocaleKeys.paymentMethod.tr(),
            _getPaymentMethodText(data),
          ),
          if (worker.isNotEmpty)
            _buildRow(
              context,
              LocaleKeys.worker.tr(),
              worker,
            ),
          if (data.payment["payment_method"] == "cash_payment")
            _buildRow(
              context,
              LocaleKeys.cashCollected.tr(),
              amountFormatter(double.parse(cashReceived ?? '0.00')),
            ),
          if (data.payment["payment_method"] == "cash_payment")
            _buildRow(
              context,
              LocaleKeys.customerChange.tr(),
              amountFormatter(double.parse(customersChange ?? '0.00')),
            ),
          _buildRow(context, LocaleKeys.date.tr(),
              _getFormattedDateTimeString(data.createdDate)),
        ],
      ),
    );
  }
}

Widget _buildRow(BuildContext context, String leftText, String rightText,
    {bool bold = false}) {
  return Row(
    children: [
      Expanded(
        child: AutoSizeText(
          leftText,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
      Expanded(
        child: AutoSizeText(
          rightText,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}

String _getPaymentMethodText(
  Sales data,
) {
  switch (data.payment["payment_method"]) {
    case "card_payment":
      return LocaleKeys.cardPayment.tr();
    case "cash_payment":
      return LocaleKeys.cashPayment.tr();
    case "mobile_money_payment":
      return LocaleKeys.mobileMoneyPayment.tr();
    default:
      return LocaleKeys.kroonPayment.tr();
  }
}

String _getPaymentMethodString(String paymentMethod) {
  switch (paymentMethod) {
    case "card_payment":
      return LocaleKeys.cardPayment.tr();
    case "cash_payment":
      return LocaleKeys.cashPayment.tr();
    case "mobile_money_payment":
      return LocaleKeys.mobileMoneyPayment.tr();
    default:
      return LocaleKeys.kroonPayment.tr();
  }
}

String _getFormattedDateTimeString(String dateTimeString) {
  return dateTimeString.substring(0, 10) +
      " " +
      dateTimeString.substring(11, 19);
}
