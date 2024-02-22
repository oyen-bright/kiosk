import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/blocs/cart/cart_bloc.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/cubits/settings/user_settings_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/amount_formatter.dart';
import 'package:kiosk/utils/get_currency.dart';
import 'package:kiosk/views/navigator/navigation.dart';
import 'package:kiosk/views/payment/sale_success.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class PayWithCash extends StatefulWidget {
  const PayWithCash({
    Key? key,
  }) : super(key: key);

  @override
  State<PayWithCash> createState() => _PayWithCashState();
}

class _PayWithCashState extends State<PayWithCash> {
  final _formKeyPayWithcard = GlobalKey<FormState>();
  final List<GlobalKey> _showCaseKeysPayWithCash =
      List.generate(5, (index) => GlobalKey());

  double _customersChange = 0.0;
  String _cashReceived = '';

  @override
  Widget build(BuildContext context) {
    final customerToPay = context.read<CartBloc>().state.totalAmount;
    final cartItem = context.read<CartBloc>().state.cartProducts;
    return BlocConsumer<LoadingCubit, LoadingState>(
        listener: (context, state) async {
      if (state.status == Status.loaded) {
        await context.pushView(
            SaleSuccess(
              customerToPay: customerToPay,
              cartItem: cartItem,
              orderId: state.msg,
            ),
            cupertino: true);
        context.pushView(const KioskNavigator(), clearStack: true);
      }

      //TODO: Think about switching ot sale cancle screen
      if (state.status == Status.error) {
        anErrorOccurredDialog(context, error: state.msg);
      }
    }, builder: (context, state) {
      final isLoading = state.status == Status.loading;

      return ShowCaseWidget(
          onFinish: () =>
              context.read<UserSettingsCubit>().changeShowIntro("cashPayment"),
          builder: Builder(builder: (context) {
            if (context
                    .read<UserSettingsCubit>()
                    .state
                    .showIntroTour["cashPayment"] ==
                true) {
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => ShowCaseWidget.of(context).startShowCase([
                        _showCaseKeysPayWithCash[0],
                        _showCaseKeysPayWithCash[1],
                        _showCaseKeysPayWithCash[2],
                        _showCaseKeysPayWithCash[3],
                        _showCaseKeysPayWithCash[4],
                      ]));
            }

            return WillPopScope(
                onWillPop: () async => !isLoading,
                child: Stack(
                  children: [
                    Scaffold(
                      appBar: customAppBar(context,
                          subTitle: LocaleKeys.completeSale.tr(),
                          title: LocaleKeys.cashPayment.tr(),
                          actions: []),
                      body: Form(
                        key: _formKeyPayWithcard,
                        child: Column(children: [
                          Expanded(
                              child: ListView(
                            children: [
                              _buildCustomerToPay(context),
                              _buildCustomersChange(),
                              20.h.height,
                              _buildAmountPaid(context),
                            ],
                          )),
                          _buildCompletCancleButton(context)
                        ]),
                      ),
                    ),
                    Visibility(
                      child: const LoadingWidget(),
                      visible: isLoading,
                    )
                  ],
                ));
          }));
    });
  }

  CompleteCancleSaleButton _buildCompletCancleButton(BuildContext context) {
    return CompleteCancleSaleButton(
      key1: _showCaseKeysPayWithCash[3],
      key2: _showCaseKeysPayWithCash[4],
      onPressedCancleSale: (() {
        context.read<CartBloc>().add(ClearCartEvent());
        context.popView(count: 2);
      }),
      onPressedCompleteSale: (() {
        context.unFocus();
        if (_formKeyPayWithcard.currentState!.validate()) {
          context.read<CartBloc>().add(CheckOutEvent(
              checkOUtMethod: "cash_payment",
              customersChange: _customersChange.toStringAsFixed(2),
              cashReceived: _cashReceived));
        }
      }),
    );
  }

  Showcase _buildAmountPaid(BuildContext context) {
    return Showcase(
      key: _showCaseKeysPayWithCash[2],
      title: LocaleKeys.cashRecieved.tr(),
      targetBorderRadius: BorderRadius.circular(16.r),
      description: LocaleKeys
          .inputTheTotalAmountTheCustomerGaveYouToDetermineTheCustomerChange
          .tr(),
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  double totalAmount = double.parse(context
                      .read<CartBloc>()
                      .state
                      .totalAmount
                      .replaceAll(",", ""));

                  if (value == null || value.isEmpty) {
                    return LocaleKeys.required.tr();
                  } else if (totalAmount > double.parse(_cashReceived)) {
                    return LocaleKeys.cashReceivedLessThanAmountToBePaid.tr();
                  }

                  return null;
                },
                inputFormatters: <TextInputFormatter>[
                  CurrencyTextInputFormatter(
                    locale: 'en',
                    decimalDigits: 2,
                    symbol: getCurrency(context) + " ",
                  ),
                ],
                onChanged: (value) {
                  final currency = getCurrency(context);

                  double total;
                  double totalAmount = double.parse(context
                      .read<CartBloc>()
                      .state
                      .totalAmount
                      .replaceAll(",", ""));

                  if (value.length > (currency.length)) {
                    total = double.parse(value
                        .substring(currency.length)
                        .trim()
                        .replaceAll(",", ""));
                    _cashReceived = total.toString();

                    if (totalAmount < total) {
                      setState(() {
                        _customersChange = total - totalAmount;
                      });
                    } else {
                      setState(() {
                        _customersChange = 0.0;
                      });
                    }
                  }
                },
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                width: double.infinity,
                child: Text(
                  LocaleKeys.cashRecieved.tr().toUpperCase(),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )),
    );
  }

  Padding _buildCustomersChange() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Showcase(
        key: _showCaseKeysPayWithCash[1],
        title: LocaleKeys.customerChange.tr(),
        targetBorderRadius: BorderRadius.circular(16.r),
        description: LocaleKeys
            .showTheAmountTheCustomerShouldReceiveAsChangeForTheAmountReceived
            .tr(),
        child: BalanceDisplayLarge(
          value: amountFormatter(_customersChange),
          title: LocaleKeys.customerChange.tr(),
        ),
      ),
    );
  }

  Padding _buildCustomerToPay(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Showcase(
        key: _showCaseKeysPayWithCash[0],
        title: LocaleKeys.customerToPay.tr(),
        targetBorderRadius: BorderRadius.circular(16.r),
        description: LocaleKeys
            .showsTheTotalAmountToBePaidByTheCustomerBasedOnTheItemsInTheCart
            .tr(),
        child: BalanceDisplayLarge(
          value: context.watch<CartBloc>().state.totalAmount,
          currency: getCurrency(context),
          title: LocaleKeys.customerToPay.tr(),
        ),
      ),
    );
  }
}
