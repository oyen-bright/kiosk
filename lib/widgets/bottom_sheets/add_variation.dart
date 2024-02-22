import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:group_button/group_button.dart';
import 'package:kiosk/cubits/item/add_item_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/variation.dart';
import 'package:kiosk/theme/orange_theme.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<Variation?> addVariationBottomSheet(
  final BuildContext context,
  final bool chargeByWeight,
) async {
  List<String> typeList = context.read<AddItemCubit>().variationTypeList;
  List<String> sizeList = context.read<AddItemCubit>().sizeList;
  List<String> colorLIst = context.read<AddItemCubit>().colorLIst;

  return await showCupertinoModalBottomSheet(
      barrierColor: Colors.black87,
      backgroundColor: context.theme.colorScheme.onPrimary,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Material(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAppBar(context),
                Flexible(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: _Body(
                        chargeByWeight: chargeByWeight,
                        typeList: typeList,
                        sizeList: sizeList,
                        colorLIst: colorLIst),
                  ),
                )
              ],
            ),
          );
        });
      });
}

Widget _buildAppBar(BuildContext context) {
  if (Platform.isIOS) {
    return CupertinoNavigationBar(
      previousPageTitle: LocaleKeys.back.tr(),
      middle: Text(LocaleKeys.productVariation.tr()),
    );
  }
  return AppBar(
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
        onPressed: () => context.popView(), icon: const Icon(Icons.arrow_back)),
    title: Text(
      LocaleKeys.productVariation.tr(),
    ),
  );
}

class _Body extends StatefulWidget {
  final List<String> typeList;
  final List<String> sizeList;
  final List<String> colorLIst;
  final bool chargeByWeight;
  const _Body(
      {Key? key,
      required this.chargeByWeight,
      required this.typeList,
      required this.sizeList,
      required this.colorLIst})
      : super(key: key);

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _formKeyPersonal = GlobalKey<FormState>();

  int selectedTypeButton = 0;
  int selectedValueButton = 0;
  int quantityCount = 0;
  bool inputVariationValue = false;

  late final TextEditingController inputVariationValueController;
  late final TextEditingController quantityCountController;
  late final GroupButtonController sizeGroupButtonController;
  late final GroupButtonController colorGroupButtonController;
  late final GroupButtonController typeGroupButtonController;

  @override
  void initState() {
    inputVariationValueController = TextEditingController();
    quantityCountController = TextEditingController();
    sizeGroupButtonController = GroupButtonController();
    colorGroupButtonController = GroupButtonController();
    typeGroupButtonController = GroupButtonController();
    quantityCountController.text = "0";

    super.initState();
  }

  @override
  void dispose() {
    inputVariationValueController.dispose();
    quantityCountController.dispose();
    sizeGroupButtonController.dispose();
    colorGroupButtonController.dispose();
    typeGroupButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sizeGroupButtonController.selectIndex(selectedValueButton);
    colorGroupButtonController.selectIndex(selectedValueButton);
    typeGroupButtonController.selectIndex(selectedTypeButton);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Form(
        key: _formKeyPersonal,
        child: Column(
          children: [
            ContainerHeader(
                showHeader: false,
                subTitle: LocaleKeys
                    .addingproductvariationsallowsyoutooffermoreoptionstoyourcustomers
                    .tr()),
            10.h.height,
            Container(
                alignment: Alignment.centerLeft,
                width: double.infinity,
                child: CustomGroupButton(
                  buttons: widget.typeList,
                  controller: typeGroupButtonController,
                  onselected: ((index, _) {
                    setState(() {
                      selectedValueButton = 0;
                      selectedTypeButton = index;
                    });
                  }),
                )),
            15.h.height,
            SizedBox(
              width: double.infinity,
              height: 30.h,
              child: Text(
                !inputVariationValue
                    ? LocaleKeys.selectVariationValue.tr()
                    : LocaleKeys.inputVariationValue.tr(),
                style: context.theme.textTheme.bodyMedium,
              ),
            ),
            Builder(builder: (_) {
              if (!inputVariationValue) {
                return Container(
                    margin: EdgeInsets.only(bottom: 15.h),
                    alignment: Alignment.centerLeft,
                    width: double.infinity,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Builder(
                          builder: (_) {
                            if (selectedTypeButton == 0) {
                              return CustomGroupButton(
                                  buttons: widget.sizeList,
                                  controller: sizeGroupButtonController,
                                  onselected: (index, _) {
                                    setState(() {
                                      selectedValueButton = index;
                                    });
                                  });
                            }

                            return CustomGroupButton(
                                buttons: widget.colorLIst,
                                controller: colorGroupButtonController,
                                onselected: (index, _) {
                                  setState(() {
                                    selectedValueButton = index;
                                  });
                                });
                          },
                        )));
              }
              return SizedBox(
                width: double.infinity,
                child: TextFormField(
                  style: context.theme.textTheme.bodyMedium,
                  controller: inputVariationValueController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return LocaleKeys.required.tr();
                    }
                    return null;
                  },
                ),
              );
            }),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      inputVariationValue = !inputVariationValue;
                    });
                  },
                  child: Text(
                    inputVariationValue
                        ? LocaleKeys.selectVariationValue.tr()
                        : LocaleKeys.inputVariationValue.tr(),
                  )),
            ),
            20.h.height,
            _buildInputQuantity(context),
            Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 30.h),
                child: ElevatedButton(
                  onPressed: () {
                    if (inputVariationValue) {
                      if (_formKeyPersonal.currentState!.validate()) {
                        if (quantityCountController.text != 0.toString()) {
                          dynamic quantity = 0;

                          if (widget.chargeByWeight) {
                            quantity =
                                double.tryParse(quantityCountController.text);
                          } else {
                            quantity =
                                int.tryParse(quantityCountController.text);
                          }

                          if (quantity != null) {
                            final variation = Variation(
                                variationQuantity: quantity.toString(),
                                variationType: widget.typeList[
                                    typeGroupButtonController.selectedIndex!],
                                variationValue:
                                    inputVariationValueController.text);
                            context.popView(value: variation);
                          }
                        }
                      }
                    } else {
                      if (quantityCountController.text != 0.toString()) {
                        dynamic quantity = 0;

                        if (widget.chargeByWeight) {
                          quantity =
                              double.tryParse(quantityCountController.text);
                        } else {
                          quantity = int.tryParse(quantityCountController.text);
                        }

                        if (quantity != null) {
                          final typeSelectedIndex =
                              typeGroupButtonController.selectedIndex!;

                          final variation = Variation(
                              variationQuantity: quantity.toString(),
                              variationType: widget.typeList[typeSelectedIndex],
                              variationValue: typeSelectedIndex == 0
                                  ? widget.sizeList[
                                      sizeGroupButtonController.selectedIndex!]
                                  : widget.colorLIst[colorGroupButtonController
                                      .selectedIndex!]);
                          context.popView(value: variation);
                        }
                      }
                    }
                  },
                  child: AutoSizeText(
                    LocaleKeys.continuE.tr(),
                  ),
                )),
            30.h.height,
          ],
        ),
      ),
    );
  }

  Column _buildInputQuantity(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 30.h,
          child: Text(
            LocaleKeys.quantity.tr(),
            style: context.theme.textTheme.bodyMedium,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              VariationElevationButton(
                onPressed: () {
                  context.unFocus();

                  final quantityCount1 =
                      double.parse(quantityCountController.text).toInt();
                  if (quantityCount1 != 0) {
                    setState(() {
                      quantityCount =
                          double.parse(quantityCountController.text).toInt() -
                              1;
                      quantityCountController.text = quantityCount.toString();
                    });
                  }
                },
                title: "-",
              ),
              5.w.width,
              Container(
                alignment: Alignment.center,
                height: 50.w,
                width: 60.w,
                child: TextField(
                  style: context.theme.textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                  controller: quantityCountController,
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
              ),
              5.w.width,
              VariationElevationButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() {
                    quantityCount =
                        double.parse(quantityCountController.text).toInt() + 1;
                    quantityCountController.text = quantityCount.toString();
                  });
                },
                title: "+",
              ),
            ],
          ),
        ),
        10.h.height
      ],
    );
  }
}

class CustomGroupButton extends StatelessWidget {
  final GroupButtonController? controller;
  final List<String> buttons;
  final dynamic Function(int, bool) onselected;
  const CustomGroupButton(
      {Key? key,
      required this.buttons,
      required this.controller,
      required this.onselected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupButton(
        controller: controller,
        options: groupButtonOption(context,
            spacing: 5,
            borderRadius: BorderRadius.circular(5.r),
            groupingType: GroupingType.row),
        isRadio: true,
        onSelected: onselected,
        buttons: buttons);
  }
}

class VariationElevationButton extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  const VariationElevationButton(
      {Key? key, required this.onPressed, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        child: Text(
          title,
        ),
        style: ElevatedButton.styleFrom(
          fixedSize: Size.fromHeight(25.h),
        ));
  }
}
