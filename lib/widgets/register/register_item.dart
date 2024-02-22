import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';

class RegisterItem extends StatelessWidget {
  final void Function() callback;
  final bool isOutOfStock;
  final Products data;
  const RegisterItem(
      {Key? key,
      required this.callback,
      required this.data,
      required this.isOutOfStock})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: CustomContainer(
        width: 100.w,
        height: 120.h,
        margin: EdgeInsets.zero,
        color: context.theme.primaryColorLight,
        padding: EdgeInsets.zero,
        child: GridTile(
          header: Builder(builder: (context) {
            if (isOutOfStock) {
              return Container(
                color: Colors.white,
                child: AutoSizeText(
                  LocaleKeys.outOfStock.tr(),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.orange),
                ),
              );
            }
            return Container();
          }),
          child: Column(
            children: [
              Container(
                height: 77.h,
                width: double.infinity,
                margin: EdgeInsets.only(left: 15.w, right: 15.w, top: 10.h),
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
                          4,
                        ),
                      ),
                    ],
                    color: const Color.fromRGBO(202, 202, 202, 1),
                    borderRadius: BorderRadius.circular(9.r)),
                child: data.image.isEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Image.asset(
                          "assets/images/empty.jpg",
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: CachedNetworkImage(
                          imageUrl: data.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                              child: SpinKitFoldingCube(
                            size: 15,
                            color: context.theme.colorScheme.primary,
                          )),
                          errorWidget: (context, url, error) => Center(
                            child: Image.asset(
                              "assets/images/empty.jpg",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.h),
                width: double.infinity,
                child: AutoSizeText(
                  data.productName,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.theme.textTheme.bodySmall!.fontSize!),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
