import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kiosk/blocs/cart/cart_bloc.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/transaction_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/navigator/navigation.dart';
import 'package:kiosk/views/payment/sale_success.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class PayWithKroon extends StatefulWidget {
  const PayWithKroon({
    Key? key,
  }) : super(key: key);

  @override
  State<PayWithKroon> createState() => _PayWithKroonState();
}

class _PayWithKroonState extends State<PayWithKroon> {
  late String? paymentRef;
  late String totalAmount;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    totalAmount = context.read<CartBloc>().state.totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    final customerToPay = context.read<CartBloc>().state.totalAmount;
    final cartItem = context.read<CartBloc>().state.cartProducts;
    return BlocConsumer<LoadingCubit, LoadingState>(
      listener: (context, state) async {
        if (state.status == Status.loaded) {
          await context.pushView(
              SaleSuccess(
                cartItem: cartItem,
                customerToPay: customerToPay,
                orderId: state.msg,
              ),
              cupertino: true);
          context.pushView(const KioskNavigator(), clearStack: true);
        }

        //TODO: Think about switching to sale cancle screen
        if (state.status == Status.error) {
          anErrorOccurredDialog(context, error: state.msg);
        }
      },
      builder: (context, state) {
        isLoading = state.status == Status.loading;

        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Stack(children: [
            Scaffold(
                appBar: customAppBar(context,
                    subTitle: LocaleKeys.completeSale.tr(),
                    title: LocaleKeys.kroonPayment.tr(),
                    actions: []),
                body: Column(children: [
                  Expanded(
                      child: ListView(
                    children: [
                      10.h.height,
                      _buildCustomerToPay(totalAmount),
                      20.h.height,
                      _buildQrCode()
                    ],
                  )),
                  _buildCompletCanclebutton(context)
                ])),
            Visibility(
              child: const LoadingWidget(),
              visible: isLoading,
            )
          ]),
        );
      },
    );
  }

  CompleteCancleSaleButton _buildCompletCanclebutton(BuildContext context) {
    return CompleteCancleSaleButton(
      onPressedCancleSale: (() {
        context.read<CartBloc>().add(ClearCartEvent());
        context.popView(count: 2);
      }),
      onPressedCompleteSale: () {
        if (paymentRef != null) {
          context.read<CartBloc>().add(CheckOutEvent(
              checkOUtMethod: "kroon_token", paymentRef: paymentRef));
        }
      },
    );
  }

  Widget _buildQrCode() {
    final kioskBlue = context.theme.colorScheme.primary;
    return FutureBuilder<Map<String, dynamic>>(
        future: context
            .read<TransactionRepository>()
            .generateFastCheckOut(amount: totalAmount.replaceAll(",", "")),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Container(
                  alignment: Alignment.center,
                  height: 300.h,
                  width: 250.w,
                  color: Colors.transparent,
                  child: Text(
                    "Error generating payment".toUpperCase(),
                    style: context.theme.textTheme.titleMedium!
                        .copyWith(color: Colors.red),
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              Map<dynamic, dynamic> data = snapshot.data!;
              paymentRef = data["transactional_id"];

              String qrData = data["transactional_id"].toString().substring(6) +
                  "/" +
                  data["wallet_id"] +
                  "/" +
                  data["kroon_token_amount"].toString() +
                  "/" +
                  "F";

              return Column(
                children: [
                  Center(
                    child: Container(
                      alignment: Alignment.center,
                      height: 300.h,
                      width: 250.w,
                      color: Colors.transparent,
                      child: QrImage(
                        foregroundColor: kioskBlue,
                        backgroundColor: Colors.transparent,
                        data: qrData,
                        version: 3,
                        size: 400.w,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    width: double.infinity,
                    child: Text(
                      LocaleKeys.customerToScanCode.tr(),
                      textAlign: TextAlign.center,
                      style: context.theme.textTheme.titleMedium!
                          .copyWith(color: kioskBlue),
                    ),
                  ),
                ],
              );
            }
          }
          return Center(
            child: SpinKitFoldingCube(
              color: kioskBlue,
              size: 40.0,
            ),
          );
        });
  }

  Padding _buildCustomerToPay(String totalAmount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BalanceDisplayLarge(
        value: totalAmount,
        title: LocaleKeys.customerToPay.tr(),
      ),
    );
  }
}
