import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/controllers/file_image_controller.dart';
import 'package:kiosk/cubits/item/add_item_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/utils/date_validation.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<List?> editProductBottomSheet(
    BuildContext context, Products currentProduct,
    {bool isService = false}) async {
  final _editProductFormKey = GlobalKey<FormState>();

  log(currentProduct.expireNotify.toString());

  ImageFileController productImage = ImageFileController(null);
  TextEditingController salesPriceTextController = TextEditingController();
  TextEditingController costPriceTextController = TextEditingController();
  TextEditingController productNameTextController = TextEditingController();
  TextEditingController quantityCountTextController = TextEditingController();
  TextEditingController lowStockLimitTextController = TextEditingController();
  TextEditingController expireDateTextController = TextEditingController();
  TextEditingController notificationPeriodTextController =
      TextEditingController();
  String? notificationPeriod;

  final product = currentProduct;
  final _focusNodeSalesPrice = FocusNode();
  final _focusCostPrice = FocusNode();
  final _focusLowStock = FocusNode();
  final _expireDateStock = FocusNode();

  productNameTextController.text = product.productName;
  lowStockLimitTextController.text = product.lowStockLimit;
  salesPriceTextController.text = product.price;
  costPriceTextController.text = product.costPrice;

  String? convertToNotificationPeriod(data) {
    return context.read<AddItemCubit>().convertToNotificationPeriod(data);
  }

  notificationPeriod = convertToNotificationPeriod(product.notificationPeriod);
  notificationPeriodTextController.text =
      convertToNotificationPeriod(product.notificationPeriod) ?? "null";

  expireDateTextController.text = product.expireDate ?? "";

  quantityCountTextController.text =
      product.chargeByWeight ? product.weightQuantity : product.stock;

  return await showCupertinoModalBottomSheet(
      useRootNavigator: false,
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: context.theme.canvasColor,
      builder: (context) {
        int numberCount = 0;
        return GestureDetector(
          onTap: (() => context.unFocus()),
          child: Form(
              key: _editProductFormKey,
              child: Material(
                child: StatefulBuilder(builder: (context, setModelState) {
                  return Column(mainAxisSize: MainAxisSize.min, children: [
                    _buildAppBar(context),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            children: [
                              20.h.height,
                              _HeaderEditProduct(
                                  productImage: productImage,
                                  product: product,
                                  productNameTextController:
                                      productNameTextController),
                              20.h.height,
                              Container(
                                margin: EdgeInsets.only(bottom: 5.h, top: 10.h),
                                width: double.infinity,
                                child: Text(LocaleKeys.itemName.tr(),
                                    style: context.theme.textTheme.titleMedium!
                                        .copyWith(fontWeight: FontWeight.bold)),
                              ),
                              _InputWidget(
                                showTitle: false,
                                controller: productNameTextController,
                                focusNode: null,
                                keyboardType: TextInputType.text,
                                inputFormatters: const [],
                                hintText: LocaleKeys.inputItemName.tr(),
                                nextFocus: _focusNodeSalesPrice,
                                title: LocaleKeys.salesPrice.tr(),
                              ),
                              10.h.height,
                              _InputWidget(
                                controller: salesPriceTextController,
                                focusNode: _focusNodeSalesPrice,
                                hintText: LocaleKeys.inputSalesPrice.tr(),
                                nextFocus: _focusCostPrice,
                                title: LocaleKeys.salesPrice.tr(),
                              ),
                              10.h.height,
                              _InputWidget(
                                controller: costPriceTextController,
                                focusNode: _focusCostPrice,
                                hintText: LocaleKeys.inputCostPrice.tr(),
                                nextFocus: _expireDateStock,
                                title: LocaleKeys.costPrice.tr(),
                              ),
                              10.h.height,
                              if (product.outOfStockNotify)
                                _InputWidget(
                                  controller: lowStockLimitTextController,
                                  focusNode: _focusLowStock,
                                  hintText: LocaleKeys.inputStockLimit.tr(),
                                  nextFocus: _expireDateStock,
                                  inputFormatters: <TextInputFormatter>[
                                    currentProduct.chargeByWeight
                                        ? CurrencyTextInputFormatter(
                                            locale: 'en',
                                            decimalDigits: 1,
                                            symbol:
                                                "${currentProduct.weightUnit} ",
                                          )
                                        : CurrencyTextInputFormatter(
                                            locale: 'en',
                                            decimalDigits: 0,
                                            symbol: "",
                                          ),
                                  ],
                                  title: LocaleKeys.lowStockLimit.tr(),
                                ),
                              10.h.height,
                              if (!isService) ...[
                                _InputWidget(
                                  keyboardType: TextInputType.none,
                                  inputFormatters: const [],
                                  controller: expireDateTextController,
                                  focusNode: _expireDateStock,
                                  onTap: () async {
                                    final response = await datePicker(context,
                                        hasMaxTime: false);
                                    if (response != null) {
                                      expireDateTextController.text =
                                          response.toString().substring(0, 10);
                                    }
                                  },
                                  validator: (String? value) {
                                    if (notificationPeriodTextController.text !=
                                            "null" &&
                                        notificationPeriodTextController
                                            .text.isNotEmpty &&
                                        (value == null || value.isEmpty)) {
                                      return LocaleKeys.required.tr();
                                    }
                                    if (value != null && value.isNotEmpty) {
                                      if (validateDateFormat(value)) {
                                        return null;
                                      } else {
                                        return LocaleKeys.invalidDateFormat
                                            .tr();
                                      }
                                    }
                                    return null;
                                  },
                                  hintText: "YYYY-MM-DD",
                                  nextFocus: null,
                                  title: LocaleKeys.expireDate.tr(),
                                ),
                                10.h.height,
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Row(
                                    children: [
                                      Text(LocaleKeys.notification.tr() + ": ",
                                          style: context
                                              .theme.textTheme.titleMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold)),
                                      Expanded(
                                        child: DropdownButtonFormField<String?>(
                                          value: notificationPeriod,
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                          onChanged: (String? newValue) {
                                            notificationPeriod = newValue;
                                            notificationPeriodTextController
                                                .text = newValue ?? "null";
                                          },
                                          validator: (value) {
                                            if (expireDateTextController
                                                .text.isNotEmpty) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return LocaleKeys.required.tr();
                                              }
                                            }
                                            return null;
                                          },
                                          items: context
                                              .read<AddItemCubit>()
                                              .notificationPeriodOptions
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          decoration: InputDecoration(
                                            helperText: LocaleKeys
                                                .notificationBeforeItemExpire
                                                .tr(),
                                            hintText: LocaleKeys
                                                .notificationPeriod
                                                .tr(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              10.h.height,
                              _buildInputProductQuantity(
                                  product,
                                  context,
                                  quantityCountTextController,
                                  setModelState,
                                  numberCount),
                              20.h.height,
                              _buildSaveButton(
                                  _editProductFormKey,
                                  salesPriceTextController,
                                  productNameTextController,
                                  quantityCountTextController,
                                  costPriceTextController,
                                  lowStockLimitTextController,
                                  expireDateTextController,
                                  notificationPeriodTextController,
                                  product,
                                  productImage,
                                  notificationPeriod,
                                  context),
                              50.h.height,
                            ],
                          ),
                        ),
                      ),
                    )
                  ]);
                }),
              )),
        );
      });
}

int? convertToDays(BuildContext context, String? data) {
  return int.tryParse(
      context.read<AddItemCubit>().convertToDays(data) ?? "null");
}

ElevatedButton _buildSaveButton(
    GlobalKey<FormState> _editProductFormKey,
    TextEditingController salesPriceTextController,
    TextEditingController productNameTextController,
    TextEditingController quantityCountTextController,
    TextEditingController costPriceTextController,
    TextEditingController lowStockLimitTextController,
    TextEditingController expireDateTextController,
    TextEditingController notificationPeriodTextController,
    Products product,
    ImageFileController productImage,
    String? notificationPeriod,
    BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      FocusManager.instance.primaryFocus?.unfocus();

      if (_editProductFormKey.currentState!.validate()) {
        final salesPrice = salesPriceTextController.text;
        final productName = productNameTextController.text;
        final quantityCount = quantityCountTextController.text;
        final costPrice = costPriceTextController.text;
        final lowStockLimit = lowStockLimitTextController.text;
        final expireDate = expireDateTextController.text;

        if (double.tryParse(quantityCount) != null) {
          if (salesPrice == product.price &&
              productName == product.productName &&
              (quantityCount == product.stock ||
                  quantityCount == product.weightQuantity) &&
              costPrice == product.costPrice &&
              lowStockLimit == product.lowStockLimit &&
              productImage.value == null &&
              expireDate == product.expireDate &&
              convertToDays(context, notificationPeriodTextController.text) ==
                  product.notificationPeriod) {
            context.popView();
          } else {
            String salesPrice = salesPriceTextController.text;
            String productName = productNameTextController.text;
            String quantityCount = quantityCountTextController.text;
            String costPrice = costPriceTextController.text;
            String lowStockLimit = lowStockLimitTextController.text;

            final weightUnit = product.weightUnit;
            final currency = getCurrency(context);

            if (salesPrice.substring(0, currency.length).toString() ==
                (currency)) {
              salesPrice = salesPrice
                  .substring(currency.length)
                  .replaceAll(",", "")
                  .trim();
            } else {
              salesPrice = salesPrice.replaceAll(",", "").trim();
            }
            if (costPrice.substring(0, currency.length).toString() ==
                (currency)) {
              costPrice = costPrice
                  .substring(currency.length)
                  .replaceAll(",", "")
                  .trim();
            } else {
              costPrice = costPrice.replaceAll(",", "").trim();
            }

            if (product.chargeByWeight) {
              if (product.outOfStockNotify) {
                if (lowStockLimit.substring(0, weightUnit.length).toString() ==
                    weightUnit) {
                  lowStockLimit = lowStockLimit
                      .substring(weightUnit.length)
                      .replaceAll(",", "");
                } else {
                  lowStockLimit = lowStockLimit.replaceAll(",", "").trim();
                }
              }
            } else {
              lowStockLimit = lowStockLimit.replaceAll(",", "").trim();
            }

            final generatedProduct = Products(
                notificationPeriod: int.tryParse(context
                        .read<AddItemCubit>()
                        .convertToDays(notificationPeriodTextController.text) ??
                    ""),
                expireNotify: product.expireNotify,
                expireDate: expireDateTextController.text,
                id: product.id,
                lowStockLimit: lowStockLimit,
                chargeByWeight: product.chargeByWeight,
                productsVariation: product.productsVariation,
                category: product.category,
                image: product.image,
                price: salesPrice,
                outOfStockNotify: product.outOfStockNotify,
                weightUnit: product.weightUnit,
                productName: productName,
                productSku: product.productSku,
                weightQuantity: product.chargeByWeight ? quantityCount : "0",
                costPrice: costPrice,
                stock: !product.chargeByWeight ? quantityCount : "0");

            context.popView(value: [generatedProduct, productImage.value]);
          }
        } else {
          context.popView();
        }
      }
    },
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.check),
      5.w.width,
      Text(
        LocaleKeys.save.tr(),
      ),
    ]),
  );
}

Builder _buildInputProductQuantity(
    Products product,
    BuildContext context,
    TextEditingController quantityCountTextController,
    StateSetter setModelState,
    int numberCount) {
  return Builder(builder: (_) {
    if (product.productsVariation.isEmpty) {
      return Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 5.h, top: 20.h),
            width: double.infinity,
            child: Text(LocaleKeys.stock.tr(),
                style: context.theme.textTheme.titleMedium!
                    .copyWith(fontWeight: FontWeight.bold)),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10.h),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();

                    if (double.parse(quantityCountTextController.text)
                            .toInt() !=
                        1) {
                      setModelState(() {
                        numberCount =
                            double.parse(quantityCountTextController.text)
                                    .toInt() -
                                1;
                        quantityCountTextController.text =
                            numberCount.toString();
                      });
                    }
                  },
                  child: const Text(
                    "-",
                  ),
                ),
                5.w.width,
                Container(
                  alignment: Alignment.center,
                  height: 60.w,
                  width: 60.w,
                  child: TextField(
                    style: context.theme.textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                    controller: quantityCountTextController,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: false, decimal: true),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
                ),
                5.w.width,
                ElevatedButton(
                  onPressed: () {
                    context.unFocus();
                    setModelState(() {
                      numberCount =
                          double.parse(quantityCountTextController.text)
                                  .toInt() +
                              1;
                      quantityCountTextController.text = numberCount.toString();
                    });
                  },
                  child: const Text(
                    "+",
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Container();
  });
}

Widget _buildAppBar(BuildContext context) {
  if (Platform.isIOS) {
    return CupertinoNavigationBar(
      previousPageTitle: LocaleKeys.back.tr(),
      middle: Text(LocaleKeys.editProduct.tr()),
    );
  }
  return AppBar(
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
        onPressed: () => context.popView(), icon: const Icon(Icons.arrow_back)),
    title: Text(
      LocaleKeys.editProduct.tr(),
    ),
  );
}

class _HeaderEditProduct extends StatelessWidget {
  const _HeaderEditProduct({
    Key? key,
    required this.product,
    required this.productImage,
    required this.productNameTextController,
  }) : super(key: key);

  final Products product;
  final ImageFileController productImage;
  final TextEditingController productNameTextController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              try {
                final image = await imagePicker(context);

                if (image != null) {
                  productImage.value = image;
                }
              } catch (e) {
                context.snackBar(e.toString());
              }
            },
            child: Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.only(bottom: 5.h, right: 5.w),
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0.r),
                  child: ValueListenableBuilder(
                    valueListenable: productImage,
                    builder:
                        (BuildContext context, dynamic value, Widget? child) {
                      if (value != null) {
                        return Image.file(value, fit: BoxFit.contain);
                      }
                      if (product.image.isEmpty) {
                        return Image.asset(
                          "assets/images/empty.jpg",
                          fit: BoxFit.fitHeight,
                        );
                      }

                      return Image.network(
                        product.image,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                )),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10.w, top: 10.h),
              width: double.infinity,
              color: context.theme.canvasColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Column(children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(right: 25.w),
                        child: AutoSizeText(
                            productNameTextController.text.isEmpty
                                ? LocaleKeys.itemName.tr()
                                : productNameTextController.text,
                            maxLines: 1,
                            style: context.theme.textTheme.titleLarge!
                                .copyWith(fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(product.productSku,
                            style:
                                context.theme.textTheme.bodyMedium!.copyWith()),
                      )
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputWidget extends StatelessWidget {
  final String title;
  final FocusNode? nextFocus;
  final bool showTitle;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final String hintText;
  final void Function()? onTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _InputWidget(
      {Key? key,
      this.inputFormatters,
      this.onTap,
      required this.hintText,
      required this.title,
      this.showTitle = true,
      this.keyboardType,
      required this.nextFocus,
      required this.controller,
      required this.focusNode,
      this.validator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //todo:check the border
    return Container(
        margin: EdgeInsets.only(top: 5.h),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Row(
          children: [
            showTitle
                ? Text(title + " : ",
                    style: context.theme.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.bold))
                : Container(),
            Expanded(
              child: TextFormField(
                  onTap: onTap,
                  onEditingComplete: () {
                    nextFocus == null
                        ? FocusScope.of(context).unfocus()
                        : FocusScope.of(context).requestFocus(nextFocus);
                  },
                  validator: validator ??
                      (value) {
                        if (value == null || value.isEmpty) {
                          return LocaleKeys.required.tr();
                        }
                        return null;
                      },
                  inputFormatters: inputFormatters ??
                      <TextInputFormatter>[
                        CurrencyTextInputFormatter(
                          locale: 'en',
                          decimalDigits: 2,
                          symbol: getCurrency(context) + " ",
                        ),
                      ],
                  focusNode: focusNode,
                  textAlign: showTitle ? TextAlign.right : TextAlign.left,
                  controller: controller,
                  keyboardType: keyboardType ?? TextInputType.number,
                  decoration: InputDecoration(
                    hintText: hintText,
                  )),
            )
          ],
        ));
  }
}
