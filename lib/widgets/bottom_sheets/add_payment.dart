import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/payment/payment_method_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/profile/payment/payment_mobile_money.dart';
import 'package:kiosk/widgets/headers/container_header.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future addPaymentMethod(BuildContext context) async {
  return await showCupertinoModalBottomSheet(
      expand: true,
      barrierColor: Colors.black87,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      context: context,
      builder: (context) {
        return Container(
          margin: EdgeInsets.only(bottom: 50.h),
          child: Column(
            children: [
              Builder(builder: (context) {
                if (Platform.isIOS) {
                  return CupertinoNavigationBar(
                    previousPageTitle: LocaleKeys.back.tr(),
                    middle: Text(LocaleKeys.addAPaymentMethods.tr()),
                  );
                }
                return AppBar(
                  elevation: 0,
                  centerTitle: true,
                  leading: IconButton(
                      onPressed: () => context.popView(),
                      icon: const Icon(Icons.arrow_back)),
                  backgroundColor: context.theme.canvasColor.darken(30),
                  title: Text(
                    LocaleKeys.addAPaymentMethods.tr(),
                  ),
                );
              }),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: const _Body(),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paymentMethods =
        context.read<PaymentMethodCubit>().getPaymentMethodsList();
    final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            ContainerHeader(
                showHeader: false,
                subTitle: LocaleKeys
                    .clickontheplusicontoAddANewPaymentMethodToYourBusiness
                    .tr()),
            SizedBox(
              height:
                  MediaQuery.of(context).size.height - kToolbarHeight - 280.h,
              child: Navigator(
                key: _navigatorKey,
                onGenerateRoute: (settings) {
                  switch (settings.name) {
                    case '/':
                      return MaterialPageRoute(
                        builder: (_) => SizedBox(
                          child: Column(
                            children: List.generate(
                              paymentMethods.length,
                              (index) => Card(
                                child: ListTile(
                                  leading: Text(paymentMethods[index]),
                                  trailing: IconButton(
                                    onPressed: () {
                                      if (paymentMethods[index] ==
                                          "Mobile Money") {
                                        _navigatorKey.currentState!
                                            .pushNamed('/Mobile-Money');
                                      } else {
                                        context
                                            .read<PaymentMethodCubit>()
                                            .addPaymentMethod(PaymentMethod(
                                                name: paymentMethods[index],
                                                description:
                                                    "Accept ${paymentMethods[index]} "));
                                        context.popView();
                                      }
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: context.theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    case '/Mobile-Money':
                      return MaterialPageRoute(
                          builder: (_) => const AddMobileMoneyPayment());
                    default:
                      return null;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
