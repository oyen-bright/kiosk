import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/widgets/custom_widgets/container.dart';

class StockReportAllProduct extends StatelessWidget {
  final void Function() callback;
  final Products data;

  const StockReportAllProduct({
    Key? key,
    required this.callback,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: CustomContainer(
        height: 91,
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
        padding: EdgeInsets.all(13.r),
        color: context.theme.primaryColorLight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImageContainer(context),
            _buildProductBody(context),
          ],
        ),
      ),
    );
  }

  Flexible _buildProductBody(BuildContext context) {
    final isOutOfStock = data.chargeByWeight
        ? (double.parse(data.weightQuantity) <= 0.0)
        : int.parse(data.stock.toString()) <= 0;

    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 8.w),
        height: 94.h,
        width: double.infinity,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: AutoSizeText(
                                data.productName,
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                style: context.theme.textTheme.bodyLarge,
                              ),
                            ),
                            Text(
                                getCurrency(context) +
                                    " " +
                                    amountFormatter(double.parse(data.price)),
                                textAlign: TextAlign.right,
                                style: context.theme.textTheme.bodyMedium!
                                    .copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                          ]),
                    ),
                    isOutOfStock
                        ? Container()
                        : Expanded(
                            child: Text(
                                data.chargeByWeight
                                    ? LocaleKeys.stock.tr() +
                                        ": ${data.weightQuantity} ${data.weightUnit}"
                                    : LocaleKeys.stock.tr() + ": ${data.stock}",
                                style: context.theme.textTheme.bodySmall),
                          )
                  ],
                ),
              ),
              !isOutOfStock
                  ? Container()
                  : Flexible(
                      child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      height: 6.w,
                                      width: 5.w,
                                      margin: EdgeInsets.only(right: 5.w),
                                      decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                    ),
                                    AutoSizeText(
                                      LocaleKeys.outOfStock.tr(),
                                      style: context.theme.textTheme.bodySmall!
                                          .copyWith(
                                        color: Colors.orange,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              AutoSizeText(
                                LocaleKeys.reStock.tr(),
                                style:
                                    context.theme.textTheme.bodySmall!.copyWith(
                                  color: Colors.orange,
                                ),
                              )
                            ],
                          )))
            ],
          ),
        ),
      ),
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
