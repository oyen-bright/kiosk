import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kiosk/constants/constant_categories_color.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/categories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/utils.dart';
import 'package:kiosk/widgets/.widgets.dart';

import 'inventory_view_item.dart';

class Inventory extends StatelessWidget {
  const Inventory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Color> bgColor = categoriesBgColor;

    return Scaffold(
        appBar: customAppBar(context,
            showSubtitle: false,
            title: LocaleKeys.inventory.tr(),
            showBackArrow: false),
        body: Builder(builder: (_) {
          final offlineMode = context.watch<OfflineCubit>().isOffline();
          if (offlineMode) {
            return const Error();
          }

          return BlocConsumer<ProductCategoriesCubit, ProductCategoriesState>(
            listener: (context, state) {
              if (state.status == CatStatus.error) {
                context.snackBar(state.msg);
              }
            },
            builder: (context, state) {
              if (state.status == CatStatus.error && state.categories == null) {
                return Error(
                  info: state.msg,
                  onPressed: () {
                    context.read<ProductCategoriesCubit>().loadCategories();
                  },
                  buttonTitle: LocaleKeys.continuE.tr(),
                );
              }
              if (state.categories != null) {
                final categories = state.categories!;
                return Container(
                    padding:
                        EdgeInsets.only(top: 10.h, left: 10.w, right: 10.w),
                    child: GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(bottom: 40.h),
                        physics: const BouncingScrollPhysics(),
                        itemCount: categories.length + 1,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, childAspectRatio: 1.4),
                        itemBuilder: (context, index) {
                          if (index + 1 == categories.length + 1) {
                            return _buidAddCategory(context, bgColor, index);
                          }
                          final data = categories[index];
                          return _buildCategory(bgColor, index, data, context);
                        }));
              }
              return const LoadingWidget();
            },
          );
        }));
  }

  Padding _buildCategory(
      List<Color> bgColor, int index, Categories data, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.r),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        elevation: 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: GridTile(
              child: InkWell(
            onTap: () {
              context.pushView(InventoryProductsByCategory(
                category: data,
              ));
            },
            onLongPress: () async {
              final categoryDeleted =
                  await deleteCategoryBottomSheet(context, data.id);

              if (categoryDeleted != null && categoryDeleted) {
                context.read<ProductCategoriesCubit>().loadCategories();
              }
            },
            child: Ink(
              decoration: BoxDecoration(
                  color: bgColor[index],
                  borderRadius: BorderRadius.circular(10.r)),
              child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerRight,
                        child: data.image == "null"
                            ? const SizedBox()
                            : CachedNetworkImage(
                                imageUrl: data.image,
                                placeholder: (context, url) => Center(
                                    child: SpinKitFoldingCube(
                                  size: 15,
                                  color: context.theme.colorScheme.primary,
                                )),
                                errorWidget: (context, url, error) =>
                                    Container(),
                              ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.r),
                        width: double.infinity,
                        child: AutoSizeText(
                          Util.getLocalizedCategory(data.category),
                          style: context.theme.textTheme.bodyMedium!.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 2,
                        ),
                      )
                    ],
                  )),
            ),
          )),
        ),
      ),
    );
  }

  Widget _buidAddCategory(
      BuildContext context, List<Color> bgColor, int index) {
    return Padding(
      padding: EdgeInsets.all(5.r),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        elevation: 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: GestureDetector(
            onTap: () {
              addCategoriesBottomSheet(context);
            },
            child: GridTile(
                child: Container(
                    alignment: Alignment.center,
                    color: bgColor[index],
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.r),
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: Image.asset(
                            "assets/images/add items.png",
                            fit: BoxFit.fitHeight,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10.r),
                          width: double.infinity,
                          child: AutoSizeText(
                            LocaleKeys.addCategory.tr(),
                            style: context.theme.textTheme.bodyMedium!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                          ),
                        )
                      ],
                    ))),
          ),
        ),
      ),
    );
  }
}
