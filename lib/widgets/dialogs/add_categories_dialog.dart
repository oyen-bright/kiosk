import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:group_button/group_button.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/theme/app_theme.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/utils.dart';

void addCategories(BuildContext context,
    {required List<String> buttons,
    List<int>? selectedButtons,
    required dynamic Function(int, bool) onSelected}) async {
  return await showDialog(
      context: context,
      builder: (contextA) {
        return AlertDialog(
            scrollable: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0.r))),
            contentPadding:
                EdgeInsets.only(left: 10.w, right: 10.w, bottom: 20.h),
            titlePadding: EdgeInsets.only(top: 10.h),
            title: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () => contextA.popView(),
                  child: Text(LocaleKeys.done.tr())),
            ),
            content: Wrap(
              children: [
                Theme(
                  data: context.theme.copyWith(
                      elevatedButtonTheme: const ElevatedButtonThemeData()),
                  child: GroupButton(
                    buttons: buttons
                        .map((e) => Util.getLocalizedCategory(e))
                        .toList(),
                    options: groupButtonOption(context),
                    // ignore: deprecated_member_use
                    selectedButtons: selectedButtons,
                    onSelected: onSelected,
                    isRadio: false,
                  ),
                ),
              ],
            ));
      });
}
