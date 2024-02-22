// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/blocs/register_products/register_products_bloc.dart';
import 'package:kiosk/cubits/sales/sales_report/sales_report_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/product_repository.dart';
import 'package:kiosk/theme/orange_theme.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/amount_formatter.dart';
import 'package:kiosk/widgets/dialogs/error_alert_dialog.dart';
import 'package:kiosk/widgets/loader/loading_widget.dart';
import 'package:kiosk/widgets/sales/sale_item.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<bool?> refundProductSaleBottomSheet(BuildContext context,
    Map<String, dynamic> productInfo, String orderId) async {
  return await showCupertinoModalBottomSheet(
      useRootNavigator: false,
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
                  middle: Text(LocaleKeys.refundProduct.tr()),
                );
              }
              return AppBar(
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                    onPressed: () => context.popView(),
                    icon: const Icon(Icons.arrow_back)),
                title: Text(
                  LocaleKeys.refundProduct.tr(),
                ),
              );
            }),
            Flexible(
              child: SingleChildScrollView(
                child: _Body(
                  productInfo: productInfo,
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
    required this.productInfo,
    required this.orderId,
  }) : super(key: key);
  final Map<String, dynamic> productInfo;
  final String orderId;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onPressed() async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        final response = await context.read<ProductRepository>().refundProduct(
            orderId: widget.orderId,
            quantity: _controller.text,
            productSKU: widget.productInfo["product"]['product_sku']);
        context.read<SalesReportCubit>().getSaleReport();
        context.read<RegisterProductsBloc>().add(LoadProductEvent());
        await successfulDialog(context, res: response);
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
        color: context.theme.canvasColor,
        child: Column(
          children: [
            10.h.height,
            Icon(
              Icons.warning_rounded,
              size: 80.r,
              color: Colors.red,
            ),
            5.h.height,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              width: double.infinity,
              child: AutoSizeText(
                  LocaleKeys.areYouSureYouWantToRefundThisProduct.tr(),
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodyMedium!),
            ),
            15.h.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ItemSale2Details(
                increase: null,
                cartItemSale: false,
                decrease: null,
                count: widget.productInfo["quantity"] == 0
                    ? "1"
                    : widget.productInfo["quantity"].toString(),
                imageUrl: widget.productInfo["product"]['product_sku'] == "MS"
                    ? "MS"
                    : widget.productInfo["product"]['image'] ?? "",
                name: widget.productInfo["product"]["product_name"],
                variation: widget.productInfo["variation"].isEmpty
                    ? widget.productInfo["product"]["product_sku"]
                    : widget.productInfo["variation"][0]["variation_value"],
                price: widget.productInfo["product"]['product_sku'] == "MS"
                    ? amountFormatter(
                        double.parse(widget.productInfo["product_total_price"]))
                    : amountFormatter(
                        double.parse(widget.productInfo["product"]["price"])),
              ),
            ),
            15.h.height,
            _ItemSaleQuantity(
              maxQuantity: widget.productInfo["quantity"] == 0
                  ? "1"
                  : widget.productInfo["quantity"].toString(),
              quantityController: _controller,
            ),
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

class _ItemSaleQuantity extends StatefulWidget {
  final TextEditingController quantityController;
  final String maxQuantity;
  const _ItemSaleQuantity(
      {Key? key, required this.quantityController, required this.maxQuantity})
      : super(key: key);

  @override
  State<_ItemSaleQuantity> createState() => _ItemSaleQuantityState();
}

class _ItemSaleQuantityState extends State<_ItemSaleQuantity> {
  @override
  void initState() {
    super.initState();
    widget.quantityController.text = "1";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          margin: EdgeInsets.only(top: 10.h),
          width: double.infinity,
          child: Text(LocaleKeys.quantity.tr(),
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.titleSmall!),
        ),
        StatefulBuilder(builder: (context, setState) {
          return Container(
            margin: EdgeInsets.only(bottom: 25.h),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onLongPress: () {
                    int currentQuantity =
                        int.parse(widget.quantityController.text);
                    if (currentQuantity - 2 > 1) {
                      setState(() {
                        widget.quantityController.text =
                            (currentQuantity - 2).toString();
                      });
                    } else if (currentQuantity > 1) {
                      setState(() {
                        widget.quantityController.text =
                            (currentQuantity - 1).toString();
                      });
                    }
                  },
                  onPressed: () {
                    int currentQuantity =
                        int.parse(widget.quantityController.text);
                    if (currentQuantity > 1) {
                      setState(() {
                        widget.quantityController.text =
                            (currentQuantity - 1).toString();
                      });
                    }
                  },
                  child: const Text(
                    "-",
                  ),
                ),
                SizedBox(
                  width: 5.h,
                ),
                Builder(builder: (context) {
                  return Container(
                    alignment: Alignment.center,
                    height: 50.w,
                    width: 60.w,
                    child: Text(
                      widget.quantityController.text,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    decoration: BoxDecoration(
                        color: kioskGrayBGColor(context),
                        borderRadius: BorderRadius.circular(10.r)),
                  );
                }),
                SizedBox(
                  width: 5.h,
                ),
                ElevatedButton(
                  onLongPress: () {
                    int currentQuantity =
                        int.parse(widget.quantityController.text);
                    int max = int.parse(widget.maxQuantity);
                    if (currentQuantity + 2 < max) {
                      setState(() {
                        widget.quantityController.text =
                            (currentQuantity + 2).toString();
                      });
                    } else if (currentQuantity < max) {
                      setState(() {
                        widget.quantityController.text =
                            (currentQuantity + 1).toString();
                      });
                    }
                  },
                  onPressed: () {
                    int currentQuantity =
                        int.parse(widget.quantityController.text);
                    int max = int.parse(widget.maxQuantity);
                    if (currentQuantity < max) {
                      setState(() {
                        widget.quantityController.text =
                            (currentQuantity + 1).toString();
                      });
                    }
                  },
                  child: const Text(
                    "+",
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
