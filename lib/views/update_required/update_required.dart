import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/theme_extention.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';
import 'package:store_redirect/store_redirect.dart';

class UpdateRequired extends StatelessWidget {
  const UpdateRequired({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Material(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.updateRequired.tr().toUpperCase(),
                      textAlign: TextAlign.center,
                      style: context.theme.textTheme.headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    20.h.height,
                    Text(
                      LocaleKeys.toAccessAllOfTheFeatures.tr(),
                      textAlign: TextAlign.justify,
                      style: context.theme.textTheme.titleMedium,
                    ),
                    30.h.height,
                    ElevatedButton(
                      onPressed: () {
                        StoreRedirect.redirect();
                      },
                      child: Text(
                        LocaleKeys.uPDATEAPP.tr().toUpperCase(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
