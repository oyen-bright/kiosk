import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:showcaseview/showcaseview.dart';

class CompleteCancleSaleButton extends StatelessWidget {
  final Function()? onPressedCancleSale;
  final Function()? onPressedCompleteSale;
  final GlobalKey<State<StatefulWidget>>? key1;
  final GlobalKey<State<StatefulWidget>>? key2;
  const CompleteCancleSaleButton({
    Key? key,
    this.key1,
    this.key2,
    required this.onPressedCancleSale,
    required this.onPressedCompleteSale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    var elevatedButton = ElevatedButton(
      onPressed: onPressedCancleSale,
      child: Text(
        LocaleKeys.cancelSale.tr(),
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: Size.fromHeight(60.h + (bottomPadding / 2)),
        padding: EdgeInsets.only(bottom: bottomPadding / 2),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.r),
          ),
          side: const BorderSide(color: Colors.red),
        ),
      ),
    );
    var elevatedButton2 = ElevatedButton(
      onPressed: onPressedCompleteSale,
      child: Text(
        LocaleKeys.completeSale.tr(),
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: Size.fromHeight(60.h + (bottomPadding / 2)),
        padding: EdgeInsets.only(bottom: bottomPadding / 2),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.r),
          ),
          side: const BorderSide(color: Colors.green),
        ),
      ),
    );
    return Container(
      child: Row(
        children: [
          Expanded(
            child: key1 != null
                ? Showcase(
                    key: key1!,
                    title: LocaleKeys.cancelSale.tr(),
                    targetBorderRadius: BorderRadius.circular(16.r),
                    description: LocaleKeys.cancelTheSaleAndEmptyYourCart.tr(),
                    child: elevatedButton,
                  )
                : elevatedButton,
          ),
          Expanded(
            child: key2 != null
                ? Showcase(
                    key: key2!,
                    title: LocaleKeys.completeSale.tr(),
                    targetBorderRadius: BorderRadius.circular(16.r),
                    description: LocaleKeys.clickToCompleteTheSale..tr(),
                    child: elevatedButton2,
                  )
                : elevatedButton2,
          ),
        ],
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.r),
          topRight: Radius.circular(10.r),
        ),
      ),
    );
  }
}
