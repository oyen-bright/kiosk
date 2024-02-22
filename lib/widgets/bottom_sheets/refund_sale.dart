import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/blocs/register_products/register_products_bloc.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/product_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<bool?> refundSaleBottomSheet(
    BuildContext context, String orderId) async {
  return await showCupertinoModalBottomSheet(
      isDismissible: false,
      barrierColor: Colors.black87,
      backgroundColor: context.theme.canvasColor,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(builder: (context) {
              if (Platform.isIOS) {
                return CupertinoNavigationBar(
                  previousPageTitle: LocaleKeys.back.tr(),
                  middle: Text(LocaleKeys.refundSale.tr()),
                );
              }
              return AppBar(
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                    onPressed: () => context.popView(),
                    icon: const Icon(Icons.arrow_back)),
                title: Text(
                  LocaleKeys.refundSale.tr(),
                ),
              );
            }),
            Flexible(
              child: SingleChildScrollView(
                child: _Body(
                  orderId: orderId,
                ),
              ),
            )
          ],
        );
      });
}

class _Body extends StatefulWidget {
  const _Body({
    Key? key,
    required this.orderId,
  }) : super(key: key);
  final String orderId;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void onPressed() async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        final reponse = await context.read<ProductRepository>().refundSale(
              orderId: widget.orderId,
            );

        context.read<SalesReportCubit>().getSaleReport();
        context.read<SalesCubit>().loadSales();
        context.read<RegisterProductsBloc>().add(LoadProductEvent());
        await successfulDialog(context, res: reponse);
        context.popView(value: true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      anErrorOccurredDialog(context, error: e.toString().titleCase);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return WillPopScope(
          onWillPop: () async => false,
          child: Column(
            children: [
              const LoadingWidget(
                isLinear: true,
              ),
              50.h.height,
            ],
          ));
    }
    return Form(
      key: _formKey,
      child: Material(
        color: context.theme.colorScheme.background,
        child: Column(
          children: [
            15.h.height,
            Icon(
              Icons.warning_rounded,
              size: 80.r,
              color: Colors.red,
            ),
            15.h.height,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              width: double.infinity,
              child: AutoSizeText(
                  LocaleKeys.areYouSureYouWantToRefundThisSale.tr() +
                      widget.orderId,
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodyMedium!),
            ),
            20.h.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextFormField(
                validator: (input) {
                  if (input!.isEmpty) {
                    return LocaleKeys.required.tr();
                  }

                  return null;
                },
                decoration: InputDecoration(
                    hintText: LocaleKeys.reasonForRefund.tr(),
                    labelText: LocaleKeys.reasonForRefund.tr()),
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 15.h),
              child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(
                    LocaleKeys.completeRefund.tr().toUpperCase(),
                  )),
            ),
            50.h.height,
          ],
        ),
      ),
    );
  }
}
