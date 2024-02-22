import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/variation.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<Variation?> editVariationBottomSheet(
  final BuildContext context,
  final bool chargeByWeight,
  final Variation variation,
) async {
  return await showCupertinoModalBottomSheet(
      barrierColor: Colors.black87,
      backgroundColor: context.theme.canvasColor,
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
                            variation: variation,
                            chargeByWeight: chargeByWeight)))
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
      middle: Text(LocaleKeys.editVariation.tr()),
    );
  }
  return AppBar(
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
        onPressed: () => context.popView(), icon: const Icon(Icons.arrow_back)),
    title: Text(
      LocaleKeys.editVariation.tr(),
    ),
  );
}

class _Body extends StatefulWidget {
  final Variation variation;
  final bool chargeByWeight;

  const _Body({Key? key, required this.variation, required this.chargeByWeight})
      : super(key: key);

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final TextEditingController inputvariationType;
  late final TextEditingController quantityCount;

  int numberCount = 0;
  String variationType = "";

  final _formKeyPersonal = GlobalKey<FormState>();

  @override
  void initState() {
    inputvariationType = TextEditingController();
    quantityCount = TextEditingController();

    quantityCount.text = widget.variation.variationQuantity;
    inputvariationType.text = widget.variation.variationValue;
    variationType = widget.variation.variationType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Form(
        key: _formKeyPersonal,
        child: Column(
          children: [
            ContainerHeader(
                showHeader: false,
                subTitle: LocaleKeys.editYourProductVariationHere.tr()),
            15.h.height,
            SizedBox(
              width: double.infinity,
              height: 30.h,
              child: Text(
                LocaleKeys.variationValue.tr(),
                style: context.theme.textTheme.bodyMedium,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextFormField(
                style: context.theme.textTheme.bodyMedium,
                controller: inputvariationType,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.required.tr();
                  }
                  return null;
                },
              ),
            ),
            20.h.height,
            _buildInputQuantity(context),
            Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 20.h),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKeyPersonal.currentState!.validate()) {
                      if (double.tryParse(quantityCount.text) != null) {
                        if (double.parse(quantityCount.text) > 0.0 &&
                            inputvariationType.text.isNotEmpty) {
                          dynamic quantity = 0;

                          if (widget.chargeByWeight) {
                            quantity = double.tryParse(quantityCount.text);
                          } else {
                            quantity = int.tryParse(quantityCount.text);
                          }

                          if (quantity != null) {
                            context.popView(
                                value: Variation(
                                    variationType: variationType,
                                    variationValue: inputvariationType.text,
                                    variationQuantity: quantity.toString()));
                          }
                        } else {
                          context.popView();
                        }
                      }
                    }
                  },
                  child: AutoSizeText(
                    LocaleKeys.continuE.tr(),
                  ),
                )),
            30.h.height
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
        Container(
          margin: EdgeInsets.only(bottom: 10.h),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomElevatedButton(
                title: "-",
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  if (double.parse(quantityCount.text).toInt() != 0) {
                    setState(() {
                      numberCount =
                          double.parse(quantityCount.text).toInt() - 1;
                      quantityCount.text = numberCount.toString();
                    });
                  }
                },
              ),
              SizedBox(
                width: 5.h,
              ),
              Container(
                alignment: Alignment.center,
                height: 50.w,
                width: 60.w,
                child: TextField(
                  style: context.theme.textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                  controller: quantityCount,
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
              ),
              SizedBox(
                width: 5.h,
              ),
              CustomElevatedButton(
                title: "+",
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() {
                    numberCount = double.parse(quantityCount.text).toInt() + 1;
                    quantityCount.text = numberCount.toString();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final String title;
  final void Function()? onPressed;
  const CustomElevatedButton(
      {Key? key, required this.title, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        child: Text(
          title,
        ),
        style: ElevatedButton.styleFrom(fixedSize: Size.fromHeight(25.h)));
  }
}
