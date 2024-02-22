import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class ItemSale3 extends StatelessWidget {
  final void Function()? increase;
  final void Function()? decrease;
  final String name;
  final String variation;
  final String price;
  final String count;
  final bool cartItemSale;
  final String currency;
  final String? imageUrl;
  const ItemSale3(
      {Key? key,
      this.increase,
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
    return CustomContainer(
      height: 100,
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
      padding: EdgeInsets.all(13.r),
      color: context.theme.primaryColorLight.withOpacity(0.5),
      child: Row(
        children: [
          _buildImageContainer(context),
          _buildBody(context),
          _buildCount(context)
        ],
      ),
    );
  }

  AutoSizeText _buildCount(BuildContext context) {
    return AutoSizeText(
      "X $count",
      style: context.theme.textTheme.bodyMedium!
          .copyWith(fontWeight: FontWeight.bold),
    );
  }

  Expanded _buildBody(BuildContext context) {
    return Expanded(
        child: Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: AutoSizeText(name,
                maxLines: 1,
                style: context.theme.textTheme.bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold)),
          ),
          Builder(builder: (_) {
            if (variation.isEmpty) {
              return SizedBox(
                height: 3.h,
              );
            }

            return SizedBox(
              width: double.infinity,
              child: AutoSizeText(
                variation,
                maxLines: 1,
                style: context.theme.textTheme.bodySmall,
              ),
            );
          }),
          1.h.height,
          SizedBox(
            width: double.infinity,
            child: AutoSizeText("Total Revenue",
                maxLines: 1,
                textAlign: TextAlign.left,
                style: context.theme.textTheme.bodySmall!),
          ),
          SizedBox(
            width: double.infinity,
            child: Row(children: [
              SizedBox(
                child: AutoSizeText(
                  currency,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  style: context.theme.textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              5.w.width,
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: AutoSizeText(price,
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      style: context.theme.textTheme.bodySmall!),
                ),
              )
            ]),
          )
        ],
      ),
    ));
  }

  Container _buildImageContainer(BuildContext context) {
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
          child: imageUrl == null
              ? Image.asset(
                  "assets/images/empty.jpg",
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SpinKitFoldingCube(
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    "assets/images/empty.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
        ));
  }
}
