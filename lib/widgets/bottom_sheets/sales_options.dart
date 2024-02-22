import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> salesOptionsBottomSheet(
    BuildContext context, String invoiceUrl, String orderId) async {
  {
    return Platform.isIOS
        ? showBarModalBottomSheet(
            useRootNavigator: true,
            barrierColor: Colors.black87,
            context: context,
            builder: (context) => Container(
                padding: EdgeInsets.only(bottom: 10.h),
                color: context.theme.canvasColor,
                child: _Body(
                  orderId: orderId,
                  invoiceUrl: invoiceUrl,
                )),
          )
        : showModalBottomSheet(
            useRootNavigator: true,
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
                  invoiceUrl: invoiceUrl,
                )),
          );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
    required this.invoiceUrl,
    required this.orderId,
  }) : super(key: key);

  final String invoiceUrl;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        15.h.height,
        // ListTile(
        //     horizontalTitleGap: 1,
        //     onTap: () async {
        //       context.popView();
        //       await refundSaleBottomSheet(context, orderId);
        //     },
        //     leading: Image.asset(
        //       "assets/images/refundsale.png",
        //       scale: 50,
        //       color: context.theme.listTileTheme.iconColor,
        //     ),
        //     title: const Text(
        //       "Refund Sale",
        //     )),
        ListTile(
            horizontalTitleGap: 1,
            onTap: () async {
              context.popView();
              // context
              //     .read<AnalyticsService>()
              //     .logShare("SaleReceipt", invoiceUrl, "Share");
              await FlutterShare.share(
                  title: 'kROON KIOSK', linkUrl: invoiceUrl);
            },
            leading: const Icon(Icons.share),
            title: Text(
              LocaleKeys.shareInvoice.tr(),
            )),
        ListTile(
            horizontalTitleGap: 1,
            onTap: () async {
              context.popView();
              // context
              //     .read<AnalyticsService>()
              //     .logShare("SaleReceipt", invoiceUrl, "InAppWebView");
              await launchUrl(Uri.parse(invoiceUrl),
                  mode: LaunchMode.inAppWebView);
            },
            leading: const Icon(Icons.open_in_browser),
            title: Text(
              LocaleKeys.viewInvoice.tr(),
            )),
        15.h.height,
      ],
    );
  }
}


// void viewOnWebOptions(BuildContext context, String uri) {
//   {
//     Platform.isIOS
//         ? showBarModalBottomSheet(
//             context: context,
//             builder: (context) => Container(
//                 padding: EdgeInsets.only(bottom: 10.h),
//                 color: context.theme.colorScheme.background,
//                 child: _WebViewBody(
//                   uri: uri,
//                 )),
//           )
//         : showModalBottomSheet(
//             backgroundColor: Colors.transparent,
//             context: context,
//             builder: (context) => Container(
//                 margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10.r),
//                   color: context.theme.colorScheme.background,
//                 ),
//                 width: double.infinity,
//                 child: _WebViewBody(
//                   uri: uri,
//                 )),
//           );
//   }
// }

// class _WebViewBody extends StatelessWidget {
//   const _WebViewBody({
//     Key? key,
//     required this.uri,
//   }) : super(key: key);
//   final String uri;

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       shrinkWrap: true,
//       children: [
//         15.h.height,
//         ListTile(
//             horizontalTitleGap: 1,
//             onTap: () async {
//               await context.pushView(
//                   WebViewScreen(url: EndPoints.base + uri, title: "Web view"));
//               context
//                   .read<ShowbottomnavCubit>()
//                   .toggleShowBottomNav(showNav: true);
//               context.popView();
//             },
//             leading: const Icon(Icons.web),
//             title: Text("Web View", style: context.theme.textTheme.titleSmall)),
//       ],
//     );
//   }
// }
