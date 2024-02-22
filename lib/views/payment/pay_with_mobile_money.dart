import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/blocs/cart/cart_bloc.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/navigator/navigation.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

import 'sale_success.dart';

class PaywithMobileMoney extends StatelessWidget {
  const PaywithMobileMoney({
    Key? key,
  }) : super(key: key);

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

        //TODO: Think about switching ot sale cancle screen
        if (state.status == Status.error) {
          anErrorOccurredDialog(context, error: state.msg);
        }
      },
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Stack(children: [
            Scaffold(
                appBar: customAppBar(context,
                    subTitle: LocaleKeys.completeSale.tr(),
                    title: LocaleKeys.mobileMoneyPayment.tr(),
                    actions: []),
                body: Column(children: [
                  Expanded(
                      child: ListView(
                    children: [
                      10.h.height,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: BalanceDisplayLarge(
                          value: context.watch<CartBloc>().state.totalAmount,
                          title: LocaleKeys.customerToPay.tr(),
                        ),
                      ),
                      20.h.height,
                    ],
                  )),
                  CompleteCancleSaleButton(
                    onPressedCancleSale: (() {
                      context.read<CartBloc>().add(ClearCartEvent());
                      context.popView(count: 2);
                    }),
                    onPressedCompleteSale: () {
                      context.read<CartBloc>().add(const CheckOutEvent(
                            checkOUtMethod: "mobile_money_payment",
                          ));
                    },
                  )
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
}
