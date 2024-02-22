import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:group_button/group_button.dart';
import 'package:kiosk/cubits/category/productcategories_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/categories.dart';
import 'package:kiosk/repositories/product_repository.dart';
import 'package:kiosk/theme/orange_theme.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/utils.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<void> addCategoriesBottomSheet(BuildContext context) async {
  return await showCupertinoModalBottomSheet(
      barrierColor: Colors.black87,
      useRootNavigator: false,
      backgroundColor: context.theme.canvasColor,
      context: context,
      builder: (context) {
        List<int> selectedCatId = [];
        List<dynamic> categoryList = [];
        List<String> categoryListText = [];
        List<Categories> usersCategories =
            context.read<ProductCategoriesCubit>().state.categories!;
        List<int> usersCurrentCatId = [];
        for (var cat in usersCategories) {
          usersCurrentCatId.add(cat.id);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(builder: (context) {
              if (Platform.isIOS) {
                return CupertinoNavigationBar(
                  previousPageTitle: LocaleKeys.back.tr(),
                  middle: Text(LocaleKeys.addCategories.tr()),
                );
              }
              return AppBar(
                elevation: 0,
                centerTitle: true,
                title: Text(LocaleKeys.addCategories.tr()),
                leading: IconButton(
                    onPressed: () => context.popView(),
                    icon: const Icon(Icons.arrow_back)),
              );
            }),
            Flexible(
              child: SingleChildScrollView(
                child: _Body(
                    usersCurrentCatId: usersCurrentCatId,
                    categoryList: categoryList,
                    categoryListText: categoryListText,
                    selectedCatId: selectedCatId),
              ),
            )
          ],
        );
      });
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
    required this.usersCurrentCatId,
    required this.categoryList,
    required this.categoryListText,
    required this.selectedCatId,
  }) : super(key: key);

  final List<int> usersCurrentCatId;
  final List categoryList;
  final List<String> categoryListText;
  final List<int> selectedCatId;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return FutureBuilder<List<dynamic>>(
          future: context.read<ProductRepository>().getAllCategories(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      20.h.height,
                      Text(
                        snapshot.error.toString(),
                        style: context.theme.textTheme.titleMedium,
                      ),
                      10.h.height,
                      TextButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: Text(
                            LocaleKeys.tryAgain.tr(),
                          )),
                      5.height,
                    ],
                  ),
                );
              } else {
                for (var element in snapshot.data!) {
                  if (!(usersCurrentCatId.contains(element["id"]))) {
                    categoryList.add(element);
                    categoryListText.add(element["category"]);
                  }
                }

                final localizedCategories = categoryListText
                    .map((e) => Util.getLocalizedCategory(e))
                    .toList();

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: ContainerHeader(
                          showHeader: false,
                          subTitle:
                              LocaleKeys.needToAddaNewCategoryToYourStore.tr()),
                    ),
                    Wrap(
                      children: [
                        GroupButton(
                          options: groupButtonOption(context),
                          buttons: localizedCategories,
                          onSelected: (indexx, selected) {
                            if (selected) {
                              selectedCatId.add(categoryList[indexx]["id"]);
                            } else {
                              selectedCatId.remove(categoryList[indexx]["id"]);
                            }
                          },
                          isRadio: false,
                        ),
                      ],
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            top: 35.h, left: 22.w, right: 22.w, bottom: 20.h),
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () async {
                              if (selectedCatId.isNotEmpty) {
                                try {
                                  await context
                                      .read<ProductRepository>()
                                      .addCategories(selectedCatId);
                                  context.snackBar(
                                    LocaleKeys.categoriesAddedSuccessfully.tr(),
                                  );
                                  context.popView();
                                  context
                                      .read<ProductCategoriesCubit>()
                                      .loadCategories();
                                } catch (e) {
                                  context.popView();
                                  context.snackBar(e.toString());
                                }
                              }
                            },
                            child: Text(
                                LocaleKeys.addCategories.tr().toUpperCase()))),
                    50.h.height,
                  ],
                );
              }
            }

            return Column(
              children: [
                const LoadingWidget(
                  isLinear: true,
                ),
                50.h.height,
              ],
            );
          }));
    });
  }
}
