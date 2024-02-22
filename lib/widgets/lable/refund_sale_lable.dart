import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiosk/extensions/theme_extention.dart';
import 'package:kiosk/translations/locale_keys.g.dart';

class RefundLable extends StatelessWidget {
  const RefundLable({Key? key, this.isSale = false, this.isSaleDetails = false})
      : super(key: key);
  final bool isSale;
  final bool isSaleDetails;

  @override
  Widget build(BuildContext context) {
    if (isSale) {
      if (isSaleDetails) {
        return Positioned(
            top: 5,
            right: 21,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(LocaleKeys.saleRefunded.tr(),
                  style: context.theme.textTheme.labelMedium!
                      .copyWith(color: Colors.white)),
            ));
      }
      return Positioned(
        top: 12,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(LocaleKeys.saleRefunded.tr(),
              style: context.theme.textTheme.labelMedium!
                  .copyWith(color: Colors.white)),
        ),
      );
    }
    return Positioned(
      top: 5,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Text(LocaleKeys.productRefunded.tr(),
            maxLines: 1,
            style: context.theme.textTheme.labelMedium!
                .copyWith(color: Colors.white)),
      ),
    );
  }
}
