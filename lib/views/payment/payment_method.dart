import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/blocs/cart/cart_bloc.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/payment/pay_with_card.dart';
import 'package:kiosk/views/payment/pay_with_cash.dart';
import 'package:kiosk/views/payment/pay_with_kroon.dart';
import 'package:kiosk/views/payment/pay_with_pay@.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class PaymentMethod extends StatelessWidget {
  const PaymentMethod({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final offlineMode = context.watch<OfflineCubit>().state.offlineStatus ==
        OfflineStatus.offlineMode;

    final ScrollController _scrollController = ScrollController();
    final List<GlobalKey> _showCaseKeysPaymentMethod =
        List.generate(3, (index) => GlobalKey());

    return ShowCaseWidget(
      onFinish: () =>
          context.read<UserSettingsCubit>().changeShowIntro("payment"),
      builder: Builder(builder: (context) {
        return Scaffold(
            appBar: customAppBar(context,
                title: LocaleKeys.choosePaymentMethod.tr(),
                subTitle: LocaleKeys.completeSale.tr(),
                showBackArrow: true,
                showNewsAndPromo: false,
                showNotifications: false),
            body: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
                builder: (context, state) {
              final showIntroTour = context
                  .read<UserSettingsCubit>()
                  .state
                  .showIntroTour["payment"] as bool;

              if (showIntroTour) {
                ShowCaseWidget.of(context).enableAutoScroll;
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => ShowCaseWidget.of(context).startShowCase([
                          _showCaseKeysPaymentMethod[0],
                          _showCaseKeysPaymentMethod[1],
                        ]));
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        _buildCustomerToPay(
                            _showCaseKeysPaymentMethod, context),
                        _buildPaymentMethods(
                            _showCaseKeysPaymentMethod, offlineMode),
                        _buildCancleSale(context),
                      ],
                    ),
                  ),
                  _buildTotalAmount(context),
                  20.h.height
                ],
              );
            }));
      }),
    );
  }

  Builder _buildPaymentMethods(
      List<GlobalKey<State<StatefulWidget>>> _showCaseKeysPaymentMethod,
      bool offlineMode) {
    return Builder(builder: (context) {
      final List<Map<String, dynamic>> data = [
        {
          "Title": LocaleKeys.cASH.tr(),
          "Navigation": const PayWithCash(),
          "value": "assets/images/hand-money-icon.png"
        },
        {
          "Title": LocaleKeys.cARD.tr(),
          "Navigation": const PayWithCard(),
          "value": "assets/images/debit-card-icon.png"
        },
        // {
        //   "Title": LocaleKeys.mOBILEMONEY.tr(),
        //   "Navigation": const PaywithMobileMoney(),
        //   "value": "assets/images/1e97fe1dc44100469eb2e91b3dba7b76.png"
        // },
        {
          "Title": "Pay@",
          "Navigation": const PayWithPayAt(),
          "value": "assets/images/pay@ Logo@1x.png"
        },
        // {
        //   "Title": "Local Bank Transfer".toUpperCase(),
        //   "Navigation": null,
        //   "value": "assets/images/etransfer.png"
        // },
      ];

      final userCubit = context.read<UserCubit>();
      if (userCubit.state.permissions!.acceptKroon) {
        data.add({
          "Title": "KROON",
          "Navigation": const PayWithKroon(),
          "value": "assets/images/Kroon Icon.png"
        });
      }

      return Showcase(
        key: _showCaseKeysPaymentMethod[1],
        title: LocaleKeys.paymentMethod.tr(),
        targetBorderRadius: BorderRadius.circular(16.r),
        description: LocaleKeys
            .selectTheAppropriatePaymentMethodWhichTheCustomerIsWillingToUse
            .tr(),
        child: SizedBox(
          width: double.infinity,
          child: GridView.count(
            primary: false,
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            crossAxisCount: 2,
            children: <Widget>[
              for (var i in data)
                Container(
                  padding: const EdgeInsets.all(8),
                  child: PaymentMethodWidget(
                    callback: () {
                      final navigation = i["Navigation"];
                      if (navigation != null) {
                        if (offlineMode &&
                            navigation.toString() == "PayWithKroon") {
                          offlineDialog(context);
                        } else {
                          context.pushView(navigation);
                        }
                      }
                    },
                    title: i["Title"],
                    value: i["value"],
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Padding _buildCustomerToPay(
      List<GlobalKey<State<StatefulWidget>>> _showCaseKeysPaymentMethod,
      BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Showcase(
        key: _showCaseKeysPaymentMethod[0],
        title: LocaleKeys.customerToPay.tr(),
        targetBorderRadius: BorderRadius.circular(16.r),
        description: LocaleKeys
            .showsTheTotalAmountToBePaidByTheCustomerBasedOnTheItemsInTheCart
            .tr(),
        child: BalanceDisplayLarge(
          value: context.watch<CartBloc>().state.totalAmount,
          title: LocaleKeys.customerToPay.tr(),
        ),
      ),
    );
  }

  Padding _buildCancleSale(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ConButton(
          title: LocaleKeys.cancelSale.tr(),
          callback: () {
            context.popView();
          },
          backgroundColor: Colors.red),
    );
  }

  SafeArea _buildTotalAmount(BuildContext context) {
    return SafeArea(
      child: CustomContainer(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 0.h),
        padding: EdgeInsets.all(16.r),
        height: 90.h,
        color: context.theme.primaryColorLight,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: AutoSizeText(
                  LocaleKeys.totalAmount.tr(),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                )),
                Expanded(
                    child: AutoSizeText(
                  context.watch<CartBloc>().state.totalAmount,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.right,
                ))
              ],
            ),
            5.h.height,
            Row(
              children: [
                Expanded(
                    child: AutoSizeText(
                  LocaleKeys.items.tr(),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                )),
                Builder(builder: (context) {
                  return Expanded(
                      child: AutoSizeText(
                    context.watch<CartBloc>().state.quantityCount.toString(),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                    textAlign: TextAlign.right,
                  ));
                })
              ],
            ),
          ],
        ),
      ),
    );
  }
}
