import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/navigation/show_bottom_nav_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/service/api/urls.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/web_view/web_view.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<void> viewOnWebOptions(BuildContext context, String uri) async {
  {
    return Platform.isIOS
        ? showBarModalBottomSheet(
            barrierColor: Colors.black87,
            context: context,
            builder: (context) => Container(
                padding: EdgeInsets.only(bottom: 10.h),
                color: context.theme.canvasColor,
                child: _Body(
                  uri: uri,
                )),
          )
        : showModalBottomSheet(
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
                  uri: uri,
                )),
          );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
    required this.uri,
  }) : super(key: key);
  final String uri;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        15.h.height,
        ListTile(
            horizontalTitleGap: 1,
            onTap: () async {
              // context.popView();
              await context.pushView(
                  KioskWebView(url: EndPoints.base + uri, title: "Web view"));
              context
                  .read<ShowBottomNavCubit>()
                  .toggleShowBottomNav(showNav: true, fromm: "WebView");
            },
            leading: const Icon(Icons.web),
            title: Text(LocaleKeys.webView.tr(),
                style: context.theme.textTheme.titleSmall)),
        15.h.height,
      ],
    );
  }
}
