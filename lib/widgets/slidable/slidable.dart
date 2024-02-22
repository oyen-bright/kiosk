import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kiosk/constants/.constants.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class KioskSlidable extends StatelessWidget {
  const KioskSlidable(
      {Key? key,
      required this.child,
      this.icon,
      this.backgroundColor,
      this.foregroundColor,
      this.label,
      this.onPressed,
      this.slidableAction})
      : super(key: key);
  final Widget child;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? label;
  final Function(BuildContext)? onPressed;
  final SlidableAction? slidableAction;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: const ValueKey(0),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            autoClose: true,
            borderRadius: BorderRadius.circular(16.r),
            onPressed: onPressed,
            backgroundColor: backgroundColor ?? refundBG,
            foregroundColor: foregroundColor ?? kioskBlue,
            icon: icon ?? MdiIcons.cashRefund,
            label: label ?? LocaleKeys.refundSale.tr(),
          ),
          slidableAction ?? const SizedBox()
        ],
      ),
      child: child,
    );
  }
}
