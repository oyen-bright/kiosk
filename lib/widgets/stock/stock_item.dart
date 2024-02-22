import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/widgets/.widgets.dart';

class StockReportProduct extends StatelessWidget {
  final void Function()? ontTap;
  final bool isLowOnStock;
  final Products data;

  const StockReportProduct(
      {Key? key,
      required this.data,
      this.isLowOnStock = false,
      required this.ontTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontTap,
      child: CustomContainer(
        height: 91,
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
        padding: EdgeInsets.all(13.r),
        color: context.theme.primaryColorLight,
        child: Row(
          children: [_buildImageContainer(context), _buildItemBody(context)],
        ),
      ),
    );
  }

  Widget _buildItemBody(BuildContext context) {
    return Flexible(
        child: Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: double.infinity,
                child: AutoSizeText(data.productName,
                    maxLines: 1, style: context.theme.textTheme.bodyLarge),
              ),
              SizedBox(
                width: double.infinity,
                child: AutoSizeText(
                    data.chargeByWeight
                        ? LocaleKeys.stock.tr() +
                            ": ${data.weightQuantity} ${data.weightUnit}"
                        : LocaleKeys.stock.tr() + ": ${data.stock}",
                    maxLines: 1,
                    style: context.theme.textTheme.bodySmall),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      height: 5.w,
                      width: 5.w,
                      margin: EdgeInsets.only(right: 5.w),
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(100)),
                    ),
                    Expanded(
                      child: AutoSizeText(
                          isLowOnStock
                              ? LocaleKeys.lowStock.tr()
                              : LocaleKeys.outOfStock.tr(),
                          minFontSize: 8,
                          style: context.theme.textTheme.bodySmall!.copyWith(
                            color: Colors.orange,
                          )),
                    )
                  ],
                ),
              ),
            ],
          )),
          _buildPriceContainer(context)
        ],
      ),
    ));
  }

  AutoSizeText _buildPriceContainer(BuildContext context) {
    return AutoSizeText(
      getCurrency(context) + " " + amountFormatter(double.parse(data.price)),
      textAlign: TextAlign.right,
      style: context.theme.textTheme.bodySmall!
          .copyWith(fontWeight: FontWeight.bold),
    );
  }

  Hero _buildImageContainer(BuildContext context) {
    return Hero(
      tag: data.id,
      child: Container(
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
                  offset: Offset(
                    0,
                    3,
                  ),
                ),
              ],
              color: context.theme.canvasColor,
              borderRadius: BorderRadius.circular(9.r)),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: data.image.isEmpty
                  ? Image.asset(
                      "assets/images/empty.jpg",
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      data.image,
                      fit: BoxFit.cover,
                    ))),
    );
  }
}
