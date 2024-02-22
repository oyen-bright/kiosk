import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/categories.dart';
import 'package:kiosk/models/permission.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/repositories/product_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/item/add_item.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

import 'inventory_edit_item.dart';

class InventoryProductsByCategory extends StatefulWidget {
  final Categories category;

  const InventoryProductsByCategory({Key? key, required this.category})
      : super(key: key);

  @override
  State<InventoryProductsByCategory> createState() =>
      _InventoryProductsByCategoryState();
}

class _InventoryProductsByCategoryState
    extends State<InventoryProductsByCategory> {
  @override
  Widget build(BuildContext context) {
    // context.read<AnalyticsService>().logCheckInventory({
    //   "cat_name": widget.category.category,
    //   "cat_id": widget.category.id,
    // });

    final permissions = context.read<UserCubit>().state.permissions!;
    final kiosksBlue = context.theme.colorScheme.primary;

    return Scaffold(
      appBar: customAppBar(context,
          showBackArrow: true,
          subTitle: widget.category.category,
          title: LocaleKeys.inventory.tr(),
          actions: [_buildDeleteCategory(permissions, context), 10.w.width]),
      body: FutureBuilder<List<Products>>(
          future: context
              .read<ProductRepository>()
              .getProductByCategory(categoryId: widget.category.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Error(
                  info: snapshot.error.toString(),
                );
              }
              if (snapshot.hasData) {
                final products = snapshot.data!;
                return _buildItems(products, kiosksBlue);
              }
            }
            return const LoadingWidget();
          }),
    );
  }

  Widget _buildItems(List<Products> products, Color kiosksBlue) {
    return Scrollbar(
        child: Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: GridView.builder(
          shrinkWrap: true,
          itemCount: products.length + 1,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            if (index == products.length) {
              return Padding(
                padding: EdgeInsets.all(2.r),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: GestureDetector(
                      onTap: () {
                        context.pushView(AddProduct(
                          categoryData: {
                            "category": widget.category.category,
                            "id": widget.category.id
                          },
                        ));
                      },
                      child: GridTile(
                        child: SizedBox(
                          height: 60.h,
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.asset(
                                  "assets/images/add items.png",
                                  fit: BoxFit.fitHeight,
                                  color: kiosksBlue,
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                  bottom: 4.h,
                                  left: 1.w,
                                  right: 1.w,
                                ),
                                child: AutoSizeText(
                                  LocaleKeys.addItem.tr(),
                                  textAlign: TextAlign.center,
                                  style: context.theme.textTheme.bodyMedium!
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            final data = products[index];
            return Padding(
              padding: EdgeInsets.all(2.r),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: GestureDetector(
                    onTap: () async {
                      await context.pushView(
                        EditItemInInventory(
                          product: data,
                        ),
                        animate: true,
                      );
                      setState(() {});
                    },
                    child: GridTile(
                      footer: SizedBox(
                        height: 45.h,
                        child: GridTileBar(
                          backgroundColor: context.theme.canvasColor,
                          title: AutoSizeText(
                            data.productName,
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            style: context.theme.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: AutoSizeText(
                            // getCurrency(context) +
                            LocaleKeys.stock.tr() +
                                ": ${data.chargeByWeight ? data.weightQuantity : data.stock}",
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            style: context.theme.textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      child: Hero(
                        tag: data.id,
                        child: SizedBox(
                          height: 60.h,
                          child: data.image.isEmpty
                              ? Image.asset(
                                  "assets/images/empty.jpg",
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  data.image,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    ));
  }

  Builder _buildDeleteCategory(Permissions permissions, BuildContext context) {
    return Builder(builder: (cx) {
      if (!permissions.isAWorker) {
        return IconButton(
          onPressed: () async {
            final categoryDeleted =
                await deleteCategoryBottomSheet(cx, widget.category.id);

            if (categoryDeleted != null) {
              context.snackBar(LocaleKeys.categoryDeletedSuccessfully.tr());

              if (categoryDeleted) {
                context.read<ProductCategoriesCubit>().loadCategories();
                context.popView();
              }
            }
          },
          icon: Icon(
            Icons.more_vert,
            color: cx.theme.colorScheme.primary,
          ),
        );
      }
      return Container();
    });
  }
}
