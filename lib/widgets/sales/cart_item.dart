import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class ItemSale extends StatelessWidget {
  final void Function()? increase;
  final void Function()? decrease;
  final void Function(BuildContext)? slideActionOnpressed;
  final String name;
  final String variation;
  final String price;
  final String count;
  final bool cartItemSale;
  final String currency;
  final Widget imageUrl;
  const ItemSale(
      {Key? key,
      this.increase,
      required this.slideActionOnpressed,
      required this.imageUrl,
      this.decrease,
      required this.currency,
      this.cartItemSale = false,
      required this.name,
      required this.count,
      required this.price,
      required this.variation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KioskSlidable(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      icon: Icons.delete,
      label: LocaleKeys.delete.tr(),
      key: const ValueKey(0),
      onPressed: slideActionOnpressed,
      child: CustomContainer(
        height: 91,
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
        padding: EdgeInsets.all(13.r),
        color: context.theme.primaryColorLight,
        child: Builder(builder: (context) {
          return GestureDetector(
            onTap: () => Slidable.of(context)!.openEndActionPane(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildImage(),
                _buildDetails(context),
                _buildIncrementDecrement()
              ],
            ),
          );
        }),
      ),
    );
  }

  Builder _buildIncrementDecrement() {
    return Builder(builder: (context) {
      if (cartItemSale) {
        return Column(
          children: [
            Container(
              height: 20.w,
              width: 20.w,
              decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(100)),
              child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: increase,
                  icon: Icon(
                    Icons.add,
                    size: 20.r,
                    color: const Color.fromRGBO(217, 217, 240, 1),
                  )),
            ),
            Flexible(
              child: Center(
                child: AutoSizeText(
                  count,
                  maxLines: 1,
                  style: context.theme.textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              height: 20.w,
              width: 20.w,
              decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(100)),
              child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: decrease,
                  icon: Icon(
                    Icons.remove,
                    size: 20.r,
                    color: const Color.fromRGBO(217, 217, 240, 1),
                  )),
            ),
          ],
        );
      }
      return AutoSizeText(
        count,
        style: context.theme.textTheme.bodyMedium!
            .copyWith(fontWeight: FontWeight.bold),
      );
    });
  }

  Expanded _buildDetails(BuildContext context) {
    return Expanded(
        child: Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: AutoSizeText(name,
                maxLines: 1, style: context.theme.textTheme.titleSmall),
          ),
          SizedBox(
            width: double.infinity,
            child: AutoSizeText(
              variation,
              maxLines: 1,
              style: context.theme.textTheme.bodySmall,
            ),
          ),
          2.h.height,
          SizedBox(
            width: double.infinity,
            child: Row(children: [
              SizedBox(
                child: AutoSizeText(
                  currency,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  style: context.theme.textTheme.bodySmall!
                      .copyWith(fontWeight: FontWeight.w400),
                ),
              ),
              4.w.width,
              Flexible(
                child: SizedBox(
                  width: double.infinity,
                  child: AutoSizeText(
                    price,
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    style: context.theme.textTheme.bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ]),
          )
        ],
      ),
    ));
  }

  Container _buildImage() {
    return Container(
        height: 55.w,
        width: 55.w,
        decoration: BoxDecoration(boxShadow: const [
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
        ], color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
        child: imageUrl);
  }
}
