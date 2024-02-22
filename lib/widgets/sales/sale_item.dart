import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/get_currency.dart';
import 'package:kiosk/utils/utils.dart';
import 'package:kiosk/widgets/.widgets.dart';

class ItemSale2 extends StatelessWidget {
  final void Function()? increase;
  final void Function()? decrease;
  final String name;
  final String variation;
  final String price;
  final String? refundPrice;
  final String count;
  final int? refundCount;
  final bool cartItemSale;
  final bool isRefunded;

  final String currency;

  final String imageUrl;
  final Function(BuildContext)? slidablePressed;
  const ItemSale2(
      {Key? key,
      this.refundPrice,
      this.increase,
      required this.imageUrl,
      this.decrease,
      this.refundCount,
      required this.currency,
      this.cartItemSale = false,
      this.isRefunded = false,
      required this.name,
      required this.count,
      required this.price,
      required this.variation,
      this.slidablePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KioskSlidable(
      onPressed: slidablePressed,
      label: LocaleKeys.refundProduct.tr(),
      child: Builder(builder: (context) {
        return GestureDetector(
          onTap: () => Slidable.of(context)!.openEndActionPane(),
          child: ItemSale2Details(
              imageUrl: imageUrl,
              isRefunded: isRefunded,
              name: name,
              variation: variation,
              price: price,
              refundPrice: refundPrice,
              refundCount: refundCount,
              cartItemSale: cartItemSale,
              increase: increase,
              count: count,
              decrease: decrease),
        );
      }),
    );
  }
}

class ItemSale2Details extends StatelessWidget {
  const ItemSale2Details({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.variation,
    this.refundPrice,
    required this.price,
    required this.cartItemSale,
    required this.increase,
    this.refundCount,
    required this.count,
    required this.decrease,
    this.isRefunded = false,
  }) : super(key: key);

  final String imageUrl;
  final String name;
  final String? refundPrice;

  final int? refundCount;
  final bool isRefunded;
  final String variation;
  final String price;
  final bool cartItemSale;
  final void Function()? increase;
  final String count;
  final void Function()? decrease;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomContainer(
          margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
          padding: EdgeInsets.all(13.r),
          color: context.theme.primaryColorLight.withOpacity(0.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildImageContainer(context),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNameText(context),
                      _buildVariationText(context),
                      SizedBox(height: 2.h),
                      _buildPriceRow(context),
                      if (isRefunded) _buildRefundPriceRow(context)
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCountText(context, count),
                  if (isRefunded)
                    _buildRefundCountText(
                        context,
                        refundCount != null
                            ? refundCount == 0
                                ? '1'
                                : refundCount.toString()
                            : "")
                ],
              ),
            ],
          ),
        ),
        if (isRefunded) const RefundLable()
      ],
    );
  }

  Widget _buildImageContainer(BuildContext context) {
    final kioskBlue = context.theme.colorScheme.primary;

    return Container(
      height: 55.w,
      width: 55.w,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.16),
            spreadRadius: -6.0,
            blurRadius: 6.0,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 25, 219, 0.32),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
        color: context.theme.canvasColor,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Builder(
        builder: (context) {
          if (imageUrl == "MS") {
            return Center(
              child: Text(
                "MS",
                style: TextStyle(color: kioskBlue),
              ),
            );
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: SpinKitFoldingCube(
                    color: kioskBlue,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Image.asset(
                "assets/images/empty.jpg",
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNameText(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AutoSizeText(
        Util.decodeString(name),
        maxLines: 1,
        style: context.theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildVariationText(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AutoSizeText(
        variation,
        maxLines: 1,
        style: context.theme.textTheme.bodySmall,
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            SizedBox(
              child: AutoSizeText(
                getCurrency(context),
                maxLines: 1,
                textAlign: TextAlign.left,
                style: context.theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 5.w),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: AutoSizeText(
                  price,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  style: context.theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildRefundPriceRow(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            SizedBox(
              child: AutoSizeText(
                getCurrency(context),
                maxLines: 1,
                textAlign: TextAlign.left,
                style: context.theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 5.w),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: AutoSizeText(
                  refundPrice.toString() + "  " + LocaleKeys.refunded.tr(),
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  style: context.theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ));
  }
}

Widget _buildCountText(BuildContext context, String count) {
  return AutoSizeText(
    "X $count",
    style: context.theme.textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.bold),
  );
}

Widget _buildRefundCountText(BuildContext context, String count) {
  return AutoSizeText(
    "- $count",
    style: context.theme.textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.bold, color: Colors.red),
  );
}
