import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:huawei_iap/huawei_iap.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/settings.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/profile/subscription/subscription.dart';
import 'package:kiosk/views/profile/subscription/subscription_huawei.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class SubscriptionBottomsheetPlanDisplay extends StatefulWidget {
  const SubscriptionBottomsheetPlanDisplay({
    Key? key,
    required this.subscriptionType,
  }) : super(key: key);

  final SubscriptionType subscriptionType;

  @override
  State<SubscriptionBottomsheetPlanDisplay> createState() =>
      _SubscriptionBottomsheetPlanDisplayState();
}

class _SubscriptionBottomsheetPlanDisplayState
    extends State<SubscriptionBottomsheetPlanDisplay> {
  SubscriptionType? selected;
  @override
  Widget build(BuildContext context) {
    final image = widget.subscriptionType == SubscriptionType.free
        ? "assets/images/Group -2.png"
        : widget.subscriptionType == SubscriptionType.kioskPro
            ? "assets/images/Group -1.png"
            : "assets/images/Group 1.png";
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.r),
            height: 0.48.sh,
            width: double.infinity,
            child: Builder(builder: (context) {
              if (widget.subscriptionType == SubscriptionType.free) {
                return SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      10.height,
                      Text(
                        LocaleKeys.chooseYourSubscriptionPlan.tr(),
                        style: context.theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Material(
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              selected = widget.subscriptionType;
                            });
                          },
                          dense: false,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.h, horizontal: 10.w),
                          horizontalTitleGap: 1,
                          leading: Radio<SubscriptionType>(
                            value: widget.subscriptionType,
                            groupValue: selected,
                            onChanged: (SubscriptionType? value) {
                              setState(() {
                                selected = value;
                              });
                            },
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          tileColor: context.theme.canvasColor.darken(5),
                          title: Text(
                            "Basic",
                            style: context.theme.textTheme.titleSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text.rich(TextSpan(
                              text: LocaleKeys.free.tr(),
                              children: const [],
                              style: context.theme.textTheme.bodyMedium)),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        child: Text(LocaleKeys.continuE.tr()),
                        onPressed: () {
                          context.popView(count: 2);
                        },
                      ),
                    ],
                  ),
                );
              }

              if (!AppSettings.isHuaweiDevice) {
                return SubscriptionBottomSheet(
                    products: context
                        .read<SubscriptionCubit>()
                        .mapSelectedSubscription(widget.subscriptionType));
              }
              return SubscriptionBottomSheetHuawei(
                  products: context
                      .read<SubscriptionHuaweiCubit>()
                      .mapSelectedSubscription(widget.subscriptionType));
            }),
            decoration: BoxDecoration(
                color: context.theme.canvasColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
          )
        ],
      ),
    );
  }
}

class SubscriptionBottomSheetHuawei extends StatefulWidget {
  const SubscriptionBottomSheetHuawei({
    Key? key,
    required this.products,
  }) : super(key: key);

  final List<ProductInfo> products;

  @override
  _SubscriptionBottomSheetHuaweiState createState() =>
      _SubscriptionBottomSheetHuaweiState();
}

class _SubscriptionBottomSheetHuaweiState
    extends State<SubscriptionBottomSheetHuawei> {
  ProductInfo? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          10.height,
          Text(
            LocaleKeys.chooseYourSubscriptionPlan.tr(),
            style: context.theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
              child: Column(
            children: [
              for (int i = 0; i < widget.products.length; i++)
                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              _selectedPlan = widget.products[i];
                            });
                          },
                          dense: false,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.h, horizontal: 5.w),
                          horizontalTitleGap: 1,
                          leading: Radio<ProductInfo>(
                            value: widget.products[i],
                            groupValue: _selectedPlan,
                            onChanged: (ProductInfo? value) {
                              setState(() {
                                _selectedPlan = value;
                              });
                            },
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          tileColor: context.theme.canvasColor.darken(5),
                          subtitle: Text(
                            widget.products[i].productDesc!,
                            style: context.theme.textTheme.bodySmall,
                          ),
                          title: Text(
                            widget.products[i].productName!,
                            style: context.theme.textTheme.titleSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text.rich(TextSpan(
                              text: widget.products[i].price,
                              children: [
                                TextSpan(
                                    style: context.theme.textTheme.bodyMedium,
                                    text: i == widget.products.length - 1
                                        ? " " + LocaleKeys.yearly.tr()
                                        : " " + LocaleKeys.monthly.tr())
                              ],
                              style: context.theme.textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                    if (i == widget.products.length - 1)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              decoration: const BoxDecoration(
                                  color: Color.fromRGBO(0, 186, 255, 1),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5))),
                              child: Text(
                                widget.products[i].productId ==
                                        "kiosk_plus_yearly_gov"
                                    ? "90% " + LocaleKeys.discount.tr()
                                    : "16% " + LocaleKeys.discount.tr(),
                                style: context.theme.textTheme.bodySmall!
                                    .copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                            5.width,
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              decoration: const BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5))),
                              child: Text(
                                LocaleKeys.RECOMMENDED.tr(),
                                style: context.theme.textTheme.bodySmall!
                                    .copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      )
                  ],
                ),
            ],
          )),
          ElevatedButton(
            child: Text(LocaleKeys.continuE.tr()),
            onPressed: () async {
              if (_selectedPlan != null) {
                await context.pushView(
                    SubscriptionHuawei(productDetaisl: _selectedPlan));
                context.popView(count: 2);
              }
            },
          ),
        ],
      ),
    );
  }
}

class SubscriptionBottomSheet extends StatefulWidget {
  const SubscriptionBottomSheet({
    Key? key,
    required this.products,
  }) : super(key: key);
  final List<ProductDetails> products;

  @override
  State<SubscriptionBottomSheet> createState() =>
      _SubscriptionBottomSheetState();
}

class _SubscriptionBottomSheetState extends State<SubscriptionBottomSheet> {
  ProductDetails? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          10.height,
          Text(
            LocaleKeys.chooseYourSubscriptionPlan.tr(),
            style: context.theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                for (int i = 0; i < widget.products.length; i++)
                  Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                _selectedPlan = widget.products[i];
                              });
                            },
                            dense: false,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5.h, horizontal: 5.w),
                            horizontalTitleGap: 1,
                            leading: Radio<ProductDetails>(
                              value: widget.products[i],
                              groupValue: _selectedPlan,
                              onChanged: (ProductDetails? value) {
                                setState(() {
                                  _selectedPlan = value;
                                });
                              },
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            tileColor: context.theme.canvasColor.darken(5),
                            subtitle: Text(
                              widget.products[i].description,
                              style: context.theme.textTheme.bodySmall,
                            ),
                            title: Text(
                              widget.products[i].title,
                              style: context.theme.textTheme.titleSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text.rich(TextSpan(
                                text: widget.products[i].price,
                                children: [
                                  TextSpan(
                                      style: context.theme.textTheme.bodyMedium,
                                      text: i == widget.products.length - 1 ||
                                              widget.products[i].id
                                                  .contains("yearly")
                                          ? " /" + LocaleKeys.yearly.tr()
                                          : " /" + LocaleKeys.monthly.tr())
                                ],
                                style: context.theme.textTheme.titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ),
                      if (i == widget.products.length - 1)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: const BoxDecoration(
                                    color: Color.fromRGBO(0, 186, 255, 1),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5))),
                                child: Text(
                                  widget.products[i].id ==
                                          "kiosk_plus_yearly_gov"
                                      ? "90% " + LocaleKeys.discount.tr()
                                      : "16% " + LocaleKeys.discount.tr(),
                                  style: context.theme.textTheme.bodySmall!
                                      .copyWith(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                ),
                              ),
                              5.width,
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: const BoxDecoration(
                                    color: Colors.purple,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5))),
                                child: Text(
                                  LocaleKeys.RECOMMENDED.tr(),
                                  style: context.theme.textTheme.bodySmall!
                                      .copyWith(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        )
                    ],
                  ),
              ],
            ),
          )),
          5.h.height,
          ElevatedButton(
            child: Text(LocaleKeys.continuE.tr()),
            onPressed: () async {
              if (_selectedPlan != null) {
                await context
                    .pushView(Subscription(productDetaisl: _selectedPlan));
                context.popView(count: 2);
              }
            },
          ),
        ],
      ),
    );
  }
}
