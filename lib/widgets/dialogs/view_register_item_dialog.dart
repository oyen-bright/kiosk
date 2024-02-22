import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:group_button/group_button.dart';
import 'package:kiosk/cubits/cart/addtocart_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/theme/orange_theme.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/widgets/.widgets.dart';

Future<void> viewProductDialog(
  BuildContext context,
  Products _product,
) async {
  TextEditingController quantityController = TextEditingController();

  GroupButtonController variationCatController =
      GroupButtonController(selectedIndex: 0);
  GroupButtonController variationValController =
      GroupButtonController(selectedIndex: 0);

  return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(

            // backgroundColor: context.theme.canvasColor,
            scrollable: false,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0.r))),
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
            title: Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close)),
            ),
            content: BlocBuilder<AddtocartCubit, AddtocartState>(
                builder: (context, state) {
              final product = state.addToCart;
              quantityController.text = state.quantity.toString();

              variationCatController.selectIndex(state.selectedCategoryindex);
              variationValController.selectIndex(state.selectedVariationIndex);

              return SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ItemSaleHeader(
                      state: state,
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    ItemSaleCustomerToPay(
                      state: state,
                    ),
                    Builder(builder: ((context) {
                      if (product!.variationCategory!.isNotEmpty) {
                        return ItemSaleVariation(
                          state: state,
                          variationCatController: variationCatController,
                          variationValController: variationValController,
                        );
                      }
                      return Container();
                    })),
                    SizedBox(
                      height: 20.h,
                    ),
                    ItemSaleQuantity(
                      quantityController: quantityController,
                      state: state,
                    ),
                    ItemSaleButtons(state: state)
                  ],
                ),
              );
            }));
      });
}

class ItemSaleButtons extends StatelessWidget {
  final AddtocartState state;

  const ItemSaleButtons({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    context.popView();
                  },
                  child: Text(
                    LocaleKeys.cancel.tr(),
                  ),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.red))),
          SizedBox(
            width: 20.w,
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (state.quantity > 0.0) {
                  context.read<AddtocartCubit>().addProductToCart();
                  context.popView();
                }
              },
              child: AutoSizeText(
                LocaleKeys.addToCart.tr(),
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      height: 35.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.r),
            topRight: Radius.circular(10.r),
          )),
    );
  }
}

class ItemSaleQuantity extends StatelessWidget {
  final AddtocartState state;
  final TextEditingController quantityController;
  const ItemSaleQuantity(
      {Key? key, required this.state, required this.quantityController})
      : super(key: key);

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
              style: context.theme.textTheme.titleSmall!),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 25.h),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<AddtocartCubit>().reduceQuantity();
                },
                child: const Text(
                  "-",
                ),
              ),
              SizedBox(
                width: 5.h,
              ),
              Builder(builder: (context) {
                if (state.addToCart!.chargebyWeight) {
                  return Container(
                    alignment: Alignment.center,
                    height: 50.w,
                    width: 60.w,
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      controller: quantityController,
                      textAlign: TextAlign.center,
                      onSubmitted: ((value) {
                        context.read<AddtocartCubit>().quantityInput(value);
                      }),
                      style: context.theme.textTheme.bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none),
                    ),
                    decoration: BoxDecoration(
                        color: kioskGrayBGColor(context),
                        borderRadius: BorderRadius.circular(10.r)),
                  );
                }
                return Container(
                  alignment: Alignment.center,
                  height: 50.w,
                  width: 60.w,
                  child: Text(
                    state.quantity.toString(),
                    style: context.theme.textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  decoration: BoxDecoration(
                      color: kioskGrayBGColor(context),
                      // border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10.r)),
                );
              }),
              SizedBox(
                width: 5.h,
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AddtocartCubit>().increaseQuantity();
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
}

class ItemSaleVariation extends StatelessWidget {
  final AddtocartState state;
  final GroupButtonController variationCatController;
  final GroupButtonController variationValController;

  const ItemSaleVariation(
      {Key? key,
      required this.state,
      required this.variationCatController,
      required this.variationValController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = state.addToCart!;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          width: double.infinity,
          child: Text(LocaleKeys.variationCategory.tr(),
              textAlign: TextAlign.left,
              style: context.theme.textTheme.titleSmall!),
        ),
        Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: GroupButton(
              controller: variationCatController,
              options: groupButtonOption(
                context,
                spacing: 5,
                borderRadius: BorderRadius.circular(5.r),
                groupingType: GroupingType.row,
              ),
              isRadio: true,
              onSelected: (index, isSelected) {
                context.read<AddtocartCubit>().switchCategoryIndex(index);
              },
              buttons: product.variationCategory!,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          margin: EdgeInsets.only(top: 10.h),
          width: double.infinity,
          child: Text(LocaleKeys.variationType.tr(),
              textAlign: TextAlign.left,
              style: context.theme.textTheme.titleSmall!),
        ),
        Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: GroupButton(
                controller: variationValController,
                options: groupButtonOption(
                  context,
                  spacing: 5,
                  borderRadius: BorderRadius.circular(5.r),
                  groupingType: GroupingType.row,
                ),
                isRadio: true,
                onSelected: ((index, isSelected) {
                  context.read<AddtocartCubit>().switchVarationType(index);
                }),
                buttons: product.variationType!),
          ),
        ),
      ],
    );
  }
}

class ItemSaleCustomerToPay extends StatelessWidget {
  final AddtocartState state;

  const ItemSaleCustomerToPay({Key? key, required this.state})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final kioskBlue = context.theme.colorScheme.primary;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            width: double.infinity,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    child: AutoSizeText(
                      getCurrency(context),
                      style: context.theme.textTheme.titleLarge!
                          .copyWith(color: kioskBlue),
                    ),
                  ),
                  Expanded(
                      child: AutoSizeText(
                    state.customerToPay,
                    textAlign: TextAlign.right,
                    style: context.theme.textTheme.titleLarge!.copyWith(
                        color: kioskBlue, fontWeight: FontWeight.bold),
                  )),
                ]),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          margin: EdgeInsets.only(bottom: 30.h),
          width: double.infinity,
          child: Text(
            LocaleKeys.customerToPay.tr(),
            textAlign: TextAlign.left,
            style: context.theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class ItemSaleHeader extends StatelessWidget {
  final AddtocartState state;
  const ItemSaleHeader({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = state.addToCart;

    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: CustomContainer(
            height: 110.w,
            width: 110.w,
            padding: EdgeInsets.zero,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0.r),
                child: product!.productImage.isEmpty
                    ? Image.asset(
                        "assets/images/empty.jpg",
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: product.productImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                            child: SpinKitFoldingCube(
                          size: 15,
                          color: context.theme.colorScheme.primary,
                        )),
                        errorWidget: (context, url, error) => Center(
                          child: Image.asset(
                            "assets/images/empty.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
          ),
        ),
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 10.h),
          child: AutoSizeText(
            product.productName,
            textAlign: TextAlign.center,
            style: context.theme.textTheme.titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 10.h),
          child: Text(
            product.chargebyWeight
                ? LocaleKeys.price.tr() +
                    ": ${product.productPrice} " +
                    LocaleKeys.per1.tr() +
                    product.weightUnit
                : LocaleKeys.price.tr() + ": ${product.productPrice}",
            style: context.theme.textTheme.titleMedium!
                .copyWith(color: Colors.grey, fontWeight: FontWeight.normal),
          ),
        ),
        Builder(builder: (context) {
          if (state.variationStock!.isEmpty) {
            return Container(
              width: double.infinity,
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 10.h),
              child: Text(
                state.isOutOfStock
                    ? LocaleKeys.outOfStock.tr()
                    : LocaleKeys.stock.tr() + " : " + state.totalStock,
                style: context.theme.textTheme.titleMedium!.copyWith(
                    color: state.isOutOfStock ? Colors.orange : Colors.grey,
                    fontWeight: FontWeight.normal),
              ),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 5.h),
                child: Text(
                  state.isOutOfStock
                      ? LocaleKeys.outOfStock.tr()
                      : "Total " +
                          LocaleKeys.stock.tr() +
                          " : " +
                          state.totalStock,
                  style: context.theme.textTheme.titleMedium!.copyWith(
                      color: state.isOutOfStock ? Colors.orange : Colors.grey,
                      fontWeight: FontWeight.normal),
                ),
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 10.h),
                child: Text(
                  LocaleKeys.stock.tr() + " : " + state.variationStock!,
                  style: context.theme.textTheme.titleSmall!.copyWith(
                      color: state.addToCart!.chargebyWeight
                          ? double.parse(
                                    state.totalStock,
                                  ) <=
                                  0.0
                              ? Colors.orange
                              : Colors.grey
                          : int.parse(state.totalStock) <= 0
                              ? Colors.orange
                              : Colors.grey,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
