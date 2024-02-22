import 'dart:convert';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/permission.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/models/variation.dart';
import 'package:kiosk/repositories/product_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/amount_formatter.dart';
import 'package:kiosk/utils/get_currency.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

//Todo: refactor widget its a mess

class EditItemInInventory extends StatefulWidget {
  final Products product;
  const EditItemInInventory({Key? key, required this.product})
      : super(key: key);

  @override
  State<EditItemInInventory> createState() => _EditItemInInventoryState();
}

class _EditItemInInventoryState extends State<EditItemInInventory> {
  final box = GetStorage();
  late Products currentProduct;

  @override
  void initState() {
    box.write("bkProduct", json.encode(widget.product));
    context.read<LoadingCubit>().loaded();
    currentProduct = widget.product;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final usersPermissions = context.read<UserCubit>().state.permissions!;

    return BlocBuilder<LoadingCubit, LoadingState>(
      builder: (context, state) {
        final isLoading = state.status == Status.loading;
        final isService = currentProduct.category == "16";

        return Stack(alignment: Alignment.topCenter, children: [
          Scaffold(
              appBar: customAppBar(context,
                  showBackArrow: true,
                  subTitle: currentProduct.productName,
                  title: LocaleKeys.editItem.tr(),
                  showNewsAndPromo: false,
                  showNotifications: false),
              body: Padding(
                  padding: EdgeInsets.only(
                    top: 10.h,
                    left: 5.w,
                    right: 5.w,
                  ),
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(children: [
                        _buidProductImage(context),
                        10.h.height,
                        _buildEditProductButton(context, isService),
                        3.h.height,
                        _buildDeleteProductButton(usersPermissions, context),
                        25.h.height,
                        isService
                            ? Container()
                            : _buildProductVariations(
                                context, usersPermissions),
                        40.h.height
                      ])))),
          Visibility(
            child: const LoadingWidget(),
            visible: isLoading,
          )
        ]);
      },
    );
  }

  CustomContainer _buildProductVariations(
      BuildContext context, Permissions usersPermissions) {
    return CustomContainer(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                    child: SizedBox(
                  width: double.infinity,
                  child: AutoSizeText(
                    LocaleKeys.variations.tr(),
                    style: context.theme.textTheme.titleMedium!.copyWith(),
                  ),
                )),
                Expanded(
                    child: Container(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                      child: TextButton(
                          onPressed: () async {
                            final variation = await addVariationBottomSheet(
                                context, currentProduct.chargeByWeight);
                            if (variation != null) {
                              try {
                                context.unFocus();
                                context
                                    .read<LoadingCubit>()
                                    .loading(message: "Adding Variation");
                                await context
                                    .read<ProductRepository>()
                                    .addProductVariation(
                                        product: currentProduct,
                                        variation: variation);
                                context.read<LoadingCubit>().loaded();
                                context.snackBar(
                                    LocaleKeys.productVariationAdded.tr());

                                context
                                    .read<ProductsCubit>()
                                    .getUsersProducts();
                              } catch (e) {
                                context.read<LoadingCubit>().loaded();

                                context.snackBar(e.toString());

                                setState(() {
                                  final bkProduct = Products.fromJson(
                                      jsonDecode(box.read("bkProduct")));

                                  currentProduct.productsVariation =
                                      bkProduct.productsVariation;
                                });
                              }
                            }
                          },
                          child: Text(
                            LocaleKeys.add.tr(),
                            textAlign: TextAlign.right,
                          ))),
                ))
              ],
            ),
          ),
          Column(
            children:
                List.generate(currentProduct.productsVariation.length, (index) {
              final data = currentProduct.productsVariation[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.5.h),
                child: Slidable(
                  key: ValueKey(index),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      Builder(builder: (contextB) {
                        if (!usersPermissions.isAWorker) {
                          return SlidableAction(
                            onPressed: (context1) async {
                              try {
                                context.unFocus();
                                currentProduct.productsVariation
                                    .removeAt(index);
                                context
                                    .read<LoadingCubit>()
                                    .loading(message: "Deleting Variation");
                                await context
                                    .read<ProductRepository>()
                                    .deleteProductVariation(
                                      product: currentProduct,
                                    );
                                context.read<LoadingCubit>().loaded();
                                context.snackBar(
                                    LocaleKeys.productVariationDeleted.tr());

                                context
                                    .read<ProductsCubit>()
                                    .getUsersProducts();
                              } catch (e) {
                                context.read<LoadingCubit>().loaded();
                                context.snackBar(e.toString());

                                setState(() {
                                  final bkProduct = Products.fromJson(
                                      jsonDecode(box.read("bkProduct")));

                                  currentProduct.productsVariation =
                                      bkProduct.productsVariation;
                                });
                              }
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: LocaleKeys.deleteVariation.tr(),
                          );
                        }

                        return Container();
                      })
                    ],
                  ),
                  child: Builder(builder: (cx) {
                    return ListTile(
                      onTap: () {
                        Slidable.of(cx)!.openEndActionPane();
                      },
                      title: AutoSizeText(
                        data["variation_value"],
                        style: context.theme.textTheme.titleMedium!.copyWith(),
                      ),
                      subtitle: AutoSizeText(
                        getProductVariationStock(currentProduct, data),
                        style: context.theme.textTheme.bodyMedium!.copyWith(
                            color: isVariationOutOfStock(currentProduct, data)
                                ? Colors.orange
                                : null,
                            fontWeight: FontWeight.normal),
                      ),
                      trailing: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            final variation = Variation(
                                variationType: data["variations_category"],
                                variationValue: data["variation_value"],
                                variationQuantity: currentProduct.chargeByWeight
                                    ? data["weight_quantity"].toString()
                                    : data["quantity"].toString());

                            final editedVariation =
                                await editVariationBottomSheet(
                              context,
                              currentProduct.chargeByWeight,
                              variation,
                            );

                            if (editedVariation != null) {
                              try {
                                FocusManager.instance.primaryFocus?.unfocus();

                                context
                                    .read<LoadingCubit>()
                                    .loading(message: "Editing Variation");
                                await context
                                    .read<ProductRepository>()
                                    .editProductVariation(
                                        variation: editedVariation,
                                        product: currentProduct,
                                        index: index);
                                context.read<LoadingCubit>().loaded();
                                context.snackBar(
                                    LocaleKeys.productVariationEdited.tr());

                                context
                                    .read<ProductsCubit>()
                                    .getUsersProducts();
                              } catch (e) {
                                context.read<LoadingCubit>().loaded();

                                context.snackBar(e.toString());

                                setState(() {
                                  final bkProduct = Products.fromJson(
                                      jsonDecode(box.read("bkProduct")));

                                  currentProduct.productsVariation =
                                      bkProduct.productsVariation;
                                });
                              }
                            }
                          },
                          icon: Icon(
                            Icons.edit,
                            color: context.theme.colorScheme.primary,
                          )),
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Builder _buildDeleteProductButton(
      Permissions usersPermissions, BuildContext context) {
    return Builder(builder: (context1) {
      if (!usersPermissions.isAWorker) {
        return CustomElevatedButton(
            icon: Icons.delete,
            onPressed: () async {
              final isDeleted = await deleteProductBottomSheet(
                  context, currentProduct.id, currentProduct.productName);
              if (isDeleted != null) {
                if (isDeleted) {
                  try {
                    context
                        .read<LoadingCubit>()
                        .loading(message: "Deleting product");
                    await context
                        .read<ProductRepository>()
                        .deleteProduct(productId: currentProduct.id);
                    context.read<LoadingCubit>().loaded();
                    context.read<ProductsCubit>().getUsersProducts();
                    context.snackBar("Product deleted");
                    context.popView();
                  } catch (e) {
                    context.read<LoadingCubit>().loaded();
                    context.snackBar(e.toString());
                  }
                }
              }
            },
            title: LocaleKeys.deleteItem.tr(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red));
      }
      return Container();
    });
  }

  CustomElevatedButton _buildEditProductButton(
      BuildContext context, bool isService) {
    return CustomElevatedButton(
      icon: Icons.edit,
      onPressed: () async {
        final editedProduct = await editProductBottomSheet(
            context, currentProduct,
            isService: isService);
        if (editedProduct != null) {
          try {
            log((editedProduct[0] as Products).expireNotify.toString(),
                name: "outside");
            context.read<LoadingCubit>().loading(message: "Updating product");
            await context.read<ProductRepository>().editProduct(
                product: editedProduct[0], productImage: editedProduct[1]);
            setState(() {
              currentProduct = editedProduct[0];
            });
            context.read<LoadingCubit>().loaded();
            context.snackBar("Product updated");
            context.read<ProductsCubit>().getUsersProducts();
          } catch (e) {
            log(e.toString());
            context.read<LoadingCubit>().loaded();
            context.snackBar(e.toString());
          }
        }
      },
      title: LocaleKeys.editItem.tr(),
    );
  }

  CustomContainer _buidProductImage(BuildContext context) {
    return CustomContainer(
      height: 200.w,
      padding: EdgeInsets.zero,
      width: 200.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: GridTile(
            footer: SizedBox(
              child: GridTileBar(
                backgroundColor: context.theme.canvasColor,
                title: AutoSizeText(
                  currentProduct.productName,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  style: context.theme.textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: AutoSizeText(
                  getProductStock(currentProduct),
                  textAlign: TextAlign.left,
                  style: context.theme.textTheme.bodyMedium!.copyWith(
                      color:
                          isOutOfStock(currentProduct) ? Colors.orange : null),
                ),
                trailing: AutoSizeText(
                  amountFormatter(
                      double.parse(currentProduct.price), getCurrency(context)),
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodyMedium!.copyWith(),
                ),
              ),
            ),
            child: Hero(
              tag: currentProduct.id,
              child: Builder(builder: (_) {
                if (currentProduct.image.isEmpty) {
                  return Image.asset(
                    "assets/images/empty.jpg",
                    fit: BoxFit.cover,
                  );
                }
                return Image.network(
                  currentProduct.image,
                  fit: BoxFit.cover,
                );
              }),
            )),
      ),
    );
  }

  String getProductStock(Products product) {
    if (product.chargeByWeight) {
      return double.parse(product.weightQuantity == null.toString()
                  ? 0.0.toString()
                  : product.weightQuantity) <=
              0.0
          ? LocaleKeys.outOfStock.tr()
          : LocaleKeys.stock.tr() +
              ":${product.weightQuantity + product.weightUnit}";
    }

    return int.parse(product.stock) <= 0
        ? LocaleKeys.outOfStock.tr()
        : LocaleKeys.stock.tr() +
            ":${product.chargeByWeight ? product.weightQuantity + product.weightUnit : product.stock}";
  }

  String getProductVariationStock(Products product, dynamic data) {
    if (product.chargeByWeight) {
      return double.parse(data["weight_quantity"].toString() == null.toString()
                  ? 0.0.toString()
                  : data["weight_quantity"].toString()) <=
              0.0
          ? LocaleKeys.outOfStock.tr()
          : LocaleKeys.stock.tr() +
              ": ${data["weight_quantity"] + " ${currentProduct.weightUnit}"}";
    }
    return int.parse(data["quantity"].toString()) <= 0
        ? LocaleKeys.outOfStock.tr()
        : LocaleKeys.stock.tr() +
            ": ${currentProduct.chargeByWeight ? data["weight_quantity"] + " ${currentProduct.weightUnit}" : data["quantity"]}";
  }

  bool isOutOfStock(Products product) {
    if (product.chargeByWeight) {
      return double.parse(currentProduct.weightQuantity == null.toString()
              ? 0.0.toString()
              : currentProduct.weightQuantity) <=
          0.0;
    }
    return int.parse(currentProduct.stock) <= 0;
  }

  bool isVariationOutOfStock(Products product, dynamic data) {
    if (product.chargeByWeight) {
      return double.parse(data["weight_quantity"].toString() == null.toString()
              ? 0.0.toString()
              : data["weight_quantity"].toString()) <=
          0.0;
    }
    return int.parse(data["quantity"].toString()) <= 0;
  }
}

class CustomElevatedButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData? icon;
  final ButtonStyle? style;
  final String title;
  const CustomElevatedButton(
      {Key? key,
      required this.onPressed,
      this.style,
      required this.title,
      required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 80.w),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon),
          SizedBox(
            width: 5.w,
          ),
          Expanded(
            child: AutoSizeText(
              title,
              maxLines: 1,
            ),
          ),
        ]),
        style: style,
      ),
    );
  }
}
