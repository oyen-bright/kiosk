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

import 'add_item.dart';

class AddItem extends StatelessWidget {
  const AddItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Color> bgColor = categoriesBgColor;

    return Scaffold(
        appBar: customAppBar(context,
            title: LocaleKeys.addItem.tr(),
            subTitle: LocaleKeys.selectCategory.tr(),
            showSubtitle: true,
            showNewsAndPromo: false,
            showNotifications: true,
            showBackArrow: true),
        body: BlocConsumer<ProductCategoriesCubit, ProductCategoriesState>(
            listener: (context, state) {
          if (state.status == CatStatus.error) {
            context.snackBar(state.msg);
          }
        }, builder: (context, state) {
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
                padding: EdgeInsets.only(top: 10.h, left: 10.w, right: 10.w),
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
                        return _buildAddCategory(context, bgColor, index);
                      }

                      final data = categories[index];

                      return _buildCategory(context, data, bgColor, index);
                    }));
          }

          return const LoadingWidget();
        }));
  }

  Padding _buildCategory(
      BuildContext context, Categories data, List<Color> bgColor, int index) {
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
              onTap: () async {
                await context.pushView(AddProduct(
                  categoryData: {
                    "category": data.category,
                    "id": data.id,
                  },
                ));
                context
                    .read<ShowBottomNavCubit>()
                    .toggleShowBottomNav(showNav: true, fromm: "Home");
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
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Container(),
                              ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.r),
                        width: double.infinity,
                        child: AutoSizeText(
                          Util.getLocalizedCategory(data.category),
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildAddCategory(
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
              final offlineMode = context.read<OfflineCubit>().isOffline();
              if (offlineMode) {
                offlineDialog(context);
              } else {
                addCategoriesBottomSheet(context);
              }
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
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
