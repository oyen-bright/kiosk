import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/constant_color.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/theme_extention.dart';
import 'package:kiosk/models/variation.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/utils/date_validation.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class AddProduct extends StatefulWidget {
  final Map<String, dynamic> categoryData;
  const AddProduct({Key? key, required this.categoryData}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final List<GlobalKey> _showCaseKeysAddItem =
      List.generate(8, (index) => GlobalKey());

  late final TextEditingController itemNameController;
  late final TextEditingController quantityTextController;
  late final TextEditingController productSkuTextController;
  late final TextEditingController weightUnitTextController;
  late final TextEditingController salesPriceTextController;
  late final TextEditingController costPriceTextController;
  late final TextEditingController expiringDateTextController;
  late final TextEditingController lowStockLimitTextController;
  late final ScrollController _scrollController;
  late final ScrollController _scrollControllerVariation;

  @override
  void initState() {
    context.read<LoadingCubit>().loaded();
    context.read<AddItemCubit>().addItem();

    _scrollController = ScrollController();
    _scrollControllerVariation = ScrollController();

    itemNameController = TextEditingController();
    quantityTextController = TextEditingController();
    productSkuTextController = TextEditingController();
    weightUnitTextController = TextEditingController();
    salesPriceTextController = TextEditingController();
    costPriceTextController = TextEditingController();
    lowStockLimitTextController = TextEditingController();
    expiringDateTextController = TextEditingController();
    super.initState();
  }

  final _addTypeFormkey = GlobalKey<FormState>();
  final _focusNodeQuality = FocusNode();
  final _focusNodeWeightUnit = FocusNode();
  final _focusNodeSalesPrice = FocusNode();
  final _focusCostPrice = FocusNode();
  final _focusExpiringDate = FocusNode();

  void scrollScreenUp() {
    _scrollController.animateTo(_scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  void scrollVariationRight() {
    Timer.periodic(const Duration(milliseconds: 500), (t) {
      _scrollControllerVariation.animateTo(
          _scrollControllerVariation.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn);
      t.cancel();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollControllerVariation.dispose();

    itemNameController.dispose();
    quantityTextController.dispose();
    weightUnitTextController.dispose();
    salesPriceTextController.dispose();
    costPriceTextController.dispose();
    lowStockLimitTextController.dispose();
    expiringDateTextController.dispose();

    _focusNodeQuality.dispose();
    _focusNodeWeightUnit.dispose();
    _focusNodeSalesPrice.dispose();
    _focusCostPrice.dispose();
    _focusExpiringDate.dispose();

    super.dispose();
  }

  void clearControllers() {
    itemNameController.clear();
    quantityTextController.clear();
    productSkuTextController.clear();
    weightUnitTextController.clear();
    salesPriceTextController.clear();
    costPriceTextController.clear();
    lowStockLimitTextController.clear();
  }

  void addProduct(AddItemState state, bool isService) async {
    FocusScope.of(context).unfocus();
    if (_addTypeFormkey.currentState!.validate()) {
      final costPrice = double.parse(state.costPrice);
      final salePrice = double.parse(state.price);

      Future<void> progress() async {
        try {
          context.read<LoadingCubit>().loading();
          await context
              .read<AddItemCubit>()
              .uploadProduct(isService, widget.categoryData["id"].toString());
          context.read<LoadingCubit>().loaded();
          context.read<ProductsCubit>().getUsersProducts();
          await successfulDialog(context, res: "Product uploaded successfully");
          context.read<AddItemCubit>().addItem();
          clearControllers();
          scrollScreenUp();
        } catch (e) {
          context.read<LoadingCubit>().loaded();

          anErrorOccurredDialog(context, error: e.toString());
        }
      }

      if (salePrice < costPrice) {
        final proceed = await costPriceSalePriceDialog(context);
        if (proceed != null && proceed) {
          await progress();
        }
      } else {
        await progress();
      }
    } else {
      showDialogs(state, isService);
    }
  }

  showDialogs(AddItemState state, bool isService) {
    String? message;
    if (itemNameController.text.isEmpty) {
      message = LocaleKeys.pleaseInputTheItemName.tr();
    } else if (isService
        ? false
        : quantityTextController.text.isEmpty ||
            quantityTextController.text == "0" ||
            quantityTextController.text == "0.0") {
      message = LocaleKeys.pleaseInputTheItemQuantity.tr();
    } else if (state.chargeByWeight && weightUnitTextController.text.isEmpty) {
      message = LocaleKeys.pleaseInputTheItemWeightUnit.tr();
    } else if (salesPriceTextController.text.isEmpty) {
      message = LocaleKeys.pleaseInputTheItemSalesPrice.tr();
    } else if (costPriceTextController.text.isEmpty) {
      message = LocaleKeys.pleaseInputTheItemCostPrice.tr();
    } else if (state.outOfStockNotify &&
        lowStockLimitTextController.text.isEmpty) {
      message = LocaleKeys.pleaseInputTheItemLowStockLimit.tr();
    }
    if (message != null) {
      anErrorOccurredDialog(context,
          error: message, title: LocaleKeys.required.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isService = widget.categoryData["category"] == "Service";

    return BlocBuilder<AddItemCubit, AddItemState>(
      builder: (context, state) {
        final productTitle = state.productTitle;
        final chargeByWeight = state.chargeByWeight;
        final outOfStockNonfiction = state.outOfStockNotify;
        final expiryNotification = state.expiryNotify;
        final productVariations = state.productVariation;
        final notificationPeriod = state.expiryNotifyPeriod;

        if (quantityTextController.text != state.stock) {
          quantityTextController.text = state.stock;
        }

        return ShowCaseWidget(
            enableAutoScroll: true,
            onComplete: (index, key) {},
            onFinish: (() {
              context.read<UserSettingsCubit>().changeShowIntro("newItem");
              context
                  .read<ShowBottomNavCubit>()
                  .toggleShowBottomNav(showNav: true, fromm: "AddItem");
            }),
            builder: Builder(builder: ((context) {
              final showIntroTour =
                  context.read<UserSettingsCubit>().state.showIntroTour;

              if (showIntroTour["newItem"] == true) {
                final views = [
                  _showCaseKeysAddItem[0],
                  _showCaseKeysAddItem[1],
                  _showCaseKeysAddItem[2],
                  _showCaseKeysAddItem[3],
                  _showCaseKeysAddItem[4],
                  _showCaseKeysAddItem[5],
                  _showCaseKeysAddItem[6],
                ];
                isService ? views.removeAt(5) : null;
                context
                    .read<ShowBottomNavCubit>()
                    .toggleShowBottomNav(showNav: false, fromm: "AddItem");

                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => ShowCaseWidget.of(context).startShowCase(views));
              }

              return WillPopScope(
                onWillPop: () async => true,
                child: Stack(alignment: Alignment.topCenter, children: [
                  Scaffold(
                      appBar: customAppBar(context,
                          title: LocaleKeys.addItem.tr(),
                          subTitle: widget.categoryData["category"],
                          showNewsAndPromo: false,
                          showNotifications: false,
                          showBackArrow: true),
                      body: Form(
                        key: _addTypeFormkey,
                        child: Scrollbar(
                          controller: _scrollController,
                          child: ListView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              CustomContainer(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(
                                      left: 10.w,
                                      right: 10.w,
                                      top: 10.h,
                                      bottom: 10.h),
                                  margin:
                                      EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.r),
                                  child: Column(children: [
                                    25.h.height,
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      child: Row(
                                        children: [
                                          Showcase(
                                              key: _showCaseKeysAddItem[0],
                                              title: LocaleKeys.itemImage.tr(),
                                              targetBorderRadius:
                                                  BorderRadius.circular(16.r),
                                              description: LocaleKeys
                                                  .tapToAddTheItemImage
                                                  .tr(),
                                              targetPadding:
                                                  EdgeInsets.all(5.r),
                                              child:
                                                  ProductImage(state: state)),
                                          ProductTitle(
                                              onClear: (() {
                                                context
                                                    .read<AddItemCubit>()
                                                    .addItem();

                                                clearControllers();
                                              }),
                                              productTitle: productTitle,
                                              isService: isService,
                                              categoryData:
                                                  widget.categoryData),
                                        ],
                                      ),
                                    ),
                                    _buildVariationsList(productVariations,
                                        chargeByWeight, context),
                                    20.h.height,
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10.h),
                                      width: double.infinity,
                                      child: Text(
                                          isService
                                              ? LocaleKeys.serviceName.tr()
                                              : LocaleKeys.itemName.tr(),
                                          style: context
                                              .theme.textTheme.titleMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold)),
                                    ),
                                    Showcase(
                                      key: _showCaseKeysAddItem[1],
                                      title: LocaleKeys.inputItemName.tr(),
                                      targetBorderRadius:
                                          BorderRadius.circular(16.r),
                                      targetPadding: EdgeInsets.only(
                                          top: 8.h,
                                          left: 5.w,
                                          right: 5.w,
                                          bottom: 8.h),
                                      description: LocaleKeys
                                          .inputTheNameOfTheNewItemHere
                                          .tr(),
                                      child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5.w),
                                          // decoration: BoxDecoration(
                                          //     border: Border.all(
                                          //         color: context
                                          //             .theme.colorScheme.onSurface,
                                          //         width: 0.3),
                                          //     borderRadius:
                                          //         BorderRadius.circular(10.r)),
                                          child: TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              onEditingComplete: () {
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        _focusNodeQuality);
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return LocaleKeys.required
                                                      .tr();
                                                }
                                                return null;
                                              },
                                              onChanged: ((value) {
                                                context
                                                    .read<AddItemCubit>()
                                                    .editItemName(value);
                                              }),
                                              textAlign: TextAlign.left,
                                              controller: itemNameController,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                hintText: isService
                                                    ? LocaleKeys
                                                        .inputServiceName
                                                        .tr()
                                                    : LocaleKeys.inputItemName
                                                        .tr(),
                                              ))),
                                    ),
                                    15.h.height,
                                    if (!isService)
                                      SegmentHeader(
                                        icon: Icons.line_weight,
                                        title: LocaleKeys.chargeByMetric.tr(),
                                        extraWidget: DisplaySwitch(
                                          onChanged: (val) {
                                            context
                                                .read<AddItemCubit>()
                                                .toggleChargeWeight();
                                          },
                                          value: chargeByWeight,
                                        ),
                                      ),
                                    if (chargeByWeight)
                                      TextInputChargeByMetric(
                                        onChanged: ((value) {
                                          context
                                              .read<AddItemCubit>()
                                              .editWeightUnit(value);
                                        }),
                                        keyboardType: TextInputType.text,
                                        maxLength: 2,
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                        ],
                                        title: LocaleKeys.weightUnit.tr(),
                                        nextFocus: _focusNodeQuality,
                                        isService: isService,
                                        focusNode: _focusNodeWeightUnit,
                                        controller: weightUnitTextController,
                                        hintText:
                                            LocaleKeys.inputWeightUnit.tr(),
                                      ),
                                    Showcase(
                                      key: _showCaseKeysAddItem[2],
                                      title: LocaleKeys.quantity.tr(),
                                      targetBorderRadius:
                                          BorderRadius.circular(16.r),
                                      description: LocaleKeys
                                          .inputTheTotalQuantityOfTheNewItemHere
                                          .tr(),
                                      targetPadding: EdgeInsets.only(
                                          top: 8.h, left: 5.w, right: 5.w),
                                      child: TextInputChargeByMetric(
                                        enabled: productVariations.isEmpty,
                                        onChanged: ((value) {
                                          context
                                              .read<AddItemCubit>()
                                              .editQuantity(value);
                                        }),
                                        inputFormatters: [
                                          chargeByWeight
                                              ? CurrencyTextInputFormatter(
                                                  locale: 'en',
                                                  decimalDigits: 1,
                                                  symbol: " ",
                                                )
                                              : CurrencyTextInputFormatter(
                                                  locale: 'en',
                                                  decimalDigits: 0,
                                                  symbol: "",
                                                ),
                                          UpperCaseTextFormatter(),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return LocaleKeys.required.tr();
                                          }

                                          if (value == "0" || value == "0,0") {
                                            return LocaleKeys.required.tr();
                                          }
                                          return null;
                                        },
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal:
                                              false, // Set to true if you want to allow decimal numbers
                                          signed:
                                              false, // Set to true if you want to allow negative numbers
                                        ),
                                        title: LocaleKeys.quantity.tr(),
                                        nextFocus: _focusNodeSalesPrice,
                                        isService: isService,
                                        focusNode: _focusNodeQuality,
                                        controller: quantityTextController,
                                        hintText:
                                            LocaleKeys.inputItemQuantity.tr(),
                                      ),
                                    ),
                                    20.h.height,
                                    SegmentHeader(
                                        icon: Icons.price_change,
                                        title: LocaleKeys.price.tr()),
                                    5.h.height,
                                    Showcase(
                                      key: _showCaseKeysAddItem[3],
                                      title: LocaleKeys.salesPrice.tr(),
                                      targetBorderRadius:
                                          BorderRadius.circular(16.r),
                                      description: LocaleKeys
                                          .inputTheAmountYouWantToSellTheNewItemHere
                                          .tr(),
                                      targetPadding: EdgeInsets.only(
                                          top: 8.h, left: 5.w, right: 5.w),
                                      child: TextInputChargeByMetric(
                                          onChanged: ((value) {
                                            context
                                                .read<AddItemCubit>()
                                                .editPrice(value
                                                    .substring(
                                                        getCurrency(context)
                                                            .length)
                                                    .replaceAll(",", "")
                                                    .trim());
                                          }),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            CurrencyTextInputFormatter(
                                              locale: 'en',
                                              decimalDigits: 2,
                                              symbol:
                                                  getCurrency(context) + " ",
                                            ),
                                          ],
                                          title: chargeByWeight
                                              ? LocaleKeys.salesPricePer1.tr() +
                                                  weightUnitTextController.text
                                              : LocaleKeys.salesPrice.tr(),
                                          nextFocus: _focusCostPrice,
                                          hintText:
                                              LocaleKeys.inputSalesPrice.tr(),
                                          focusNode: _focusNodeSalesPrice,
                                          controller: salesPriceTextController),
                                    ),
                                    Showcase(
                                      key: _showCaseKeysAddItem[4],
                                      title: LocaleKeys.costPrice.tr(),
                                      targetBorderRadius:
                                          BorderRadius.circular(16.r),
                                      targetPadding: EdgeInsets.only(
                                          top: 8.h, left: 5.w, right: 5.w),
                                      description: LocaleKeys
                                          .inputHowMuchTheNewItemCostThePurchasePriceOfTheItemHere
                                          .tr(),
                                      child: TextInputChargeByMetric(
                                          onChanged: ((value) {
                                            context
                                                .read<AddItemCubit>()
                                                .editCostPrice(value
                                                    .substring(
                                                        getCurrency(context)
                                                            .length)
                                                    .replaceAll(",", "")
                                                    .trim());
                                          }),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            CurrencyTextInputFormatter(
                                              locale: 'en',
                                              decimalDigits: 2,
                                              symbol:
                                                  getCurrency(context) + " ",
                                            ),
                                          ],
                                          title: LocaleKeys.costPrice.tr(),
                                          nextFocus: null,
                                          hintText:
                                              LocaleKeys.inputCostPrice.tr(),
                                          focusNode: _focusCostPrice,
                                          helperText: isService
                                              ? LocaleKeys
                                                  .thePriceItWillCostYouToRenderTheService
                                                  .tr()
                                              : LocaleKeys.purchasePriceOfItem
                                                  .tr(),
                                          controller: costPriceTextController),
                                    ),
                                    25.h.height,
                                    if (!isService)
                                      SegmentHeader(
                                        icon: Icons.notification_important,
                                        title: LocaleKeys.outOfStockNotification
                                            .tr(),
                                        extraWidget: DisplaySwitch(
                                            onChanged: (_) {
                                              context
                                                  .read<AddItemCubit>()
                                                  .toggleOutOfStockNotification();
                                            },
                                            value: outOfStockNonfiction),
                                      ),
                                    if (outOfStockNonfiction)
                                      TextInputChargeByMetric(
                                          onChanged: ((value) {
                                            context
                                                .read<AddItemCubit>()
                                                .editLowStockValue(value);
                                          }),
                                          focusNode: null,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            chargeByWeight
                                                ? CurrencyTextInputFormatter(
                                                    locale: 'en',
                                                    decimalDigits: 1,
                                                    symbol:
                                                        "${weightUnitTextController.text} ",
                                                  )
                                                : CurrencyTextInputFormatter(
                                                    locale: 'en',
                                                    decimalDigits: 0,
                                                    symbol: "",
                                                  ),
                                          ],
                                          title: LocaleKeys.lowStockLimit.tr(),
                                          nextFocus: null,
                                          hintText:
                                              LocaleKeys.inputStockLimit.tr(),
                                          isService: isService,
                                          controller:
                                              lowStockLimitTextController),
                                    if (!isService) ...[
                                      TextInputChargeByMetric(
                                          onChanged: ((value) {
                                            context
                                                .read<AddItemCubit>()
                                                .editSku(value);
                                          }),
                                          focusNode: null,
                                          validate: false,
                                          keyboardType: TextInputType.text,
                                          inputFormatters: null,
                                          title: "SKU",
                                          nextFocus: null,
                                          hintText:
                                              LocaleKeys.inputProductSKU.tr(),
                                          isService: isService,
                                          controller: productSkuTextController),
                                      SegmentHeader(
                                          icon: Icons.notification_important,
                                          title: LocaleKeys.expireNotification
                                              .tr(),
                                          extraWidget: DisplaySwitch(
                                              onChanged: (_) {
                                                context
                                                    .read<AddItemCubit>()
                                                    .toggleExpiryNotification();
                                              },
                                              value: expiryNotification)),
                                      if (expiryNotification) ...[
                                        TextInputChargeByMetric(
                                            onChanged: ((value) {
                                              context
                                                  .read<AddItemCubit>()
                                                  .editExpireDate(value);
                                            }),
                                            onTap: () async {
                                              final response = await datePicker(
                                                  context,
                                                  hasMaxTime: false);
                                              if (response != null) {
                                                expiringDateTextController
                                                        .text =
                                                    response
                                                        .toString()
                                                        .substring(0, 10);
                                                context
                                                    .read<AddItemCubit>()
                                                    .editExpireDate(
                                                        expiringDateTextController
                                                            .text);
                                              }
                                            },
                                            focusNode: null,
                                            validate: true,
                                            validator: (String? value) {
                                              if (value != null &&
                                                  value.isNotEmpty) {
                                                if (validateDateFormat(value)) {
                                                  return null;
                                                } else {
                                                  return LocaleKeys
                                                      .invalidDateFormat
                                                      .tr();
                                                }
                                              } else {
                                                return LocaleKeys.required.tr();
                                              }
                                            },
                                            keyboardType: TextInputType.none,
                                            inputFormatters: null,
                                            title: LocaleKeys.expireDate.tr(),
                                            nextFocus: null,
                                            hintText: "YYYY-MM-DD",
                                            isService: isService,
                                            helperText: LocaleKeys
                                                .expiringDateOfItem
                                                .tr(),
                                            controller:
                                                expiringDateTextController),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5.w),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                  LocaleKeys.notification.tr() +
                                                      ": ",
                                                  style: context.theme.textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              Expanded(
                                                child: DropdownButtonFormField<
                                                    String>(
                                                  value: notificationPeriod,
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down),
                                                  onChanged:
                                                      (String? newValue) {
                                                    context
                                                        .read<AddItemCubit>()
                                                        .editNotificationPeriod(
                                                            newValue);
                                                  },
                                                  items: context
                                                      .read<AddItemCubit>()
                                                      .notificationPeriodOptions
                                                      .map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return LocaleKeys.required
                                                          .tr();
                                                    }
                                                    return null;
                                                  },
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
                                    ],
                                    20.h.height,
                                    Builder(builder: (contextB) {
                                      if (!isService) {
                                        return Showcase(
                                          key: _showCaseKeysAddItem[5],
                                          title: LocaleKeys.addVariation.tr(),
                                          targetBorderRadius:
                                              BorderRadius.circular(16.r),
                                          targetPadding: EdgeInsets.only(
                                              top: 8.h,
                                              left: 5.w,
                                              right: 5.w,
                                              bottom: 8.h),
                                          description: LocaleKeys
                                              .clickToAddVariationsOfTheNewItemHere
                                              .tr(),
                                          child: CustomElevatedButton(
                                              backgroundColor: kioskYellow,
                                              icon: Icons.check,
                                              title:
                                                  LocaleKeys.addVariation.tr(),
                                              onPressed: () async {
                                                final variation =
                                                    await addVariationBottomSheet(
                                                        contextB,
                                                        chargeByWeight);
                                                if (variation != null) {
                                                  context
                                                      .read<AddItemCubit>()
                                                      .addVariation(variation);
                                                  scrollScreenUp();
                                                  scrollVariationRight();
                                                }
                                              }),
                                        );
                                      }
                                      return Container();
                                    }),
                                    15.h.height,
                                    Showcase(
                                      key: _showCaseKeysAddItem[6],
                                      title: LocaleKeys.addItem.tr(),
                                      targetBorderRadius:
                                          BorderRadius.circular(16.r),
                                      targetPadding: EdgeInsets.only(
                                          top: 8.h,
                                          left: 5.w,
                                          right: 5.w,
                                          bottom: 8.h),
                                      description: LocaleKeys
                                          .clickToAddItemToYourCashRegister
                                          .tr(),
                                      child: CustomElevatedButton(
                                          backgroundColor: kioskBlue,
                                          icon: Icons.check,
                                          title: LocaleKeys.addItem.tr(),
                                          onPressed: () =>
                                              addProduct(state, isService)),
                                    )
                                  ])),
                              70.h.height,
                            ],
                          ),
                        ),
                      )),
                  Builder(builder: (context) {
                    final isLoading =
                        (context.watch<LoadingCubit>().state.status ==
                            Status.loading);
                    if (isLoading) {
                      return const LoadingWidget();
                    }
                    return Container();
                  })
                ]),
              );
            })));
      },
    );
  }

  Builder _buildVariationsList(List<Variation> productVariations,
      bool chargeByWeight, BuildContext context) {
    return Builder(builder: (context4) {
      if (productVariations.isNotEmpty) {
        return Container(
          margin: EdgeInsets.only(top: 20.h),
          width: double.infinity,
          height: 34.h,
          child: ListView.builder(
            controller: _scrollControllerVariation,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: productVariations.length,
            itemBuilder: (BuildContext _, int index) {
              final data = productVariations[index];

              return Padding(
                  padding: EdgeInsets.only(right: 1.r),
                  child: GestureDetector(
                      onTap: () async {
                        final variation = await editVariationBottomSheet(
                          context4,
                          chargeByWeight,
                          data,
                        );
                        if (variation != null) {
                          context
                              .read<AddItemCubit>()
                              .editVariation(variation, index);
                        }
                      },
                      child: Chip(
                        label: Text(
                          data.variationQuantity +
                              "${chargeByWeight ? weightUnitTextController.text : ""} " +
                              " " +
                              "(${data.variationValue})",
                        ),
                        onDeleted: () {
                          context.read<AddItemCubit>().removeVariation(index);
                        },
                      )));
            },
          ),
        );
      }
      return Container();
    });
  }
}

class ProductTitle extends StatelessWidget {
  const ProductTitle({
    Key? key,
    required this.productTitle,
    required this.isService,
    required this.categoryData,
    required this.onClear,
  }) : super(key: key);

  final String productTitle;
  final bool isService;
  final void Function()? onClear;

  final Map<String, dynamic> categoryData;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 10.w),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: double.infinity,
                alignment: Alignment.topRight,
                child: SizedBox(
                    child: TextButton(
                        onPressed: onClear,
                        child: Text(
                          LocaleKeys.clear.tr(),
                        )))),
            Column(children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(right: 25.w),
                child: AutoSizeText(
                  productTitle.isEmpty
                      ? isService
                          ? LocaleKeys.serviceName.tr()
                          : LocaleKeys.itemName.tr()
                      : productTitle,
                  maxLines: 1,
                  style: context.theme.textTheme.titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Text(categoryData["category"],
                    style: context.theme.textTheme.bodySmall),
              )
            ]),
          ],
        ),
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  final AddItemState state;
  const ProductImage({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () async {
      final image = await imagePicker(context);
      context.read<AddItemCubit>().editImage(image);
    }, child: Builder(builder: (_) {
      final image = state.productImage;

      if (image == null) {
        return Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.only(bottom: 5.h, right: 5.w),
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
              image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    "assets/images/uploadImage.png",
                  )),
              color: Colors.green,
              borderRadius: BorderRadius.circular(20.r)),
          child: Image.asset(
            "assets/images/addIcon.png",
            height: 30.h,
            width: 30.w,
          ),
        );
      }

      return Container(
          alignment: Alignment.center,
          width: 90.w,
          height: 90.w,
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.r)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0.r),
            child: Image.file(image, fit: BoxFit.contain),
          ));
    }));
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class DisplaySwitch extends StatelessWidget {
  final void Function(bool)? onChanged;
  final bool value;
  const DisplaySwitch({Key? key, required this.onChanged, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? Switch(value: value, onChanged: onChanged, activeColor: kioskBlue)
        : CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: kioskBlue,
          );
  }
}

class TextInputChargeByMetric extends StatelessWidget {
  final String title;
  final String hintText;
  final bool isService;
  final int? maxLength;
  final FocusNode? nextFocus;
  final FocusNode? focusNode;
  final bool? enabled;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController controller;
  final bool validate;
  final String? helperText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function()? onTap;
  const TextInputChargeByMetric(
      {Key? key,
      this.keyboardType,
      this.maxLength,
      this.enabled = true,
      this.validate = true,
      this.helperText,
      required this.onChanged,
      required this.inputFormatters,
      required this.title,
      required this.nextFocus,
      required this.hintText,
      this.validator,
      this.onTap,
      this.textInputAction,
      this.isService = false,
      required this.focusNode,
      required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Row(
          children: [
            Text(title + ": ",
                style: context.theme.textTheme.bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold)),
            Expanded(child: Builder(builder: (_) {
              if (isService) {
                return Container(
                    height: 50.h,
                    alignment: Alignment.centerRight,
                    width: double.infinity,
                    child: Icon(Icons.all_inclusive,
                        color: context.theme.colorScheme.primary));
              }
              return TextFormField(
                  onTap: onTap,
                  textInputAction: textInputAction,
                  enabled: enabled,
                  maxLength: maxLength,
                  onEditingComplete: nextFocus != null
                      ? () {
                          FocusScope.of(context).requestFocus(nextFocus);
                        }
                      : null,
                  onSaved: ((newValue) {
                    FocusScope.of(context).unfocus();
                  }),
                  validator: validate
                      ? validator ??
                          (value) {
                            if (value == null || value.isEmpty) {
                              return LocaleKeys.required.tr();
                            }
                            return null;
                          }
                      : null,
                  onChanged: onChanged,
                  inputFormatters: inputFormatters,
                  focusNode: focusNode,
                  textAlign: TextAlign.right,
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                      hintText: hintText, helperText: helperText));
            }))
          ],
        ));
  }
}

class SegmentHeader extends StatelessWidget {
  final Widget? extraWidget;
  final IconData icon;
  final String title;
  const SegmentHeader(
      {Key? key, this.extraWidget, required this.icon, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon),
              SizedBox(
                width: 5.w,
              ),
              Text(title,
                  style: context.theme.textTheme.titleSmall!
                      .copyWith(fontWeight: FontWeight.bold))
            ],
          ),
          extraWidget ?? const SizedBox()
        ],
      ),
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData icon;
  final String title;
  final Color backgroundColor;
  const CustomElevatedButton(
      {Key? key,
      required this.backgroundColor,
      required this.onPressed,
      required this.icon,
      required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon),
          5.w.width,
          Text(
            title,
          ),
        ]),
        style: ElevatedButton.styleFrom(backgroundColor: backgroundColor));
  }
}
