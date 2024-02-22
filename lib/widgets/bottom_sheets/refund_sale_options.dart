import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<bool?> refundsalesOptionsButtomSheet(
    BuildContext context, String orderId) async {
  {
    return Platform.isIOS
        ? showBarModalBottomSheet(
            useRootNavigator: false,
            barrierColor: Colors.black87,
            context: context,
            builder: (context) => Container(
                padding: EdgeInsets.only(bottom: 10.h),
                color: context.theme.canvasColor,
                child: _Body(
                  orderId: orderId,
                )),
          )
        : showModalBottomSheet(
            useRootNavigator: false,
            barrierColor: Colors.black87,
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) => Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: context.theme.canvasColor,
                ),
                width: double.infinity,
                child: _Body(
                  orderId: orderId,
                )),
          );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        15.h.height,
        ListTile(
            horizontalTitleGap: 1,
            onTap: () async {
              context.popView();
              await refundSaleBottomSheet(context, orderId);
            },
            leading: Image.asset(
              "assets/images/refundsale.png",
              scale: 50,
              color: context.theme.listTileTheme.iconColor,
            ),
            title: Text(
              LocaleKeys.refundSale.tr(),
            )),
        ListTile(
            horizontalTitleGap: 1,
            onTap: () async {
              context.popView(value: true);
            },
            leading: Image.asset(
              "assets/images/refundsale.png",
              scale: 50,
              color: context.theme.listTileTheme.iconColor,
            ),
            title: Text(LocaleKeys.refundProductFromSale.tr())),
        15.h.height,
        15.h.height,
      ],
    );
  }
}
