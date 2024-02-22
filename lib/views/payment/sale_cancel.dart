// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:kiosk/translation/locale_keys.g.dart';

// class SaleCancel extends StatelessWidget {
//   final bool isError;
//   final String errorMessage;
//   const SaleCancel({Key? key, this.isError = false, this.errorMessage = ""})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Size screenSize = MediaQuery.of(context).size;
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Material(
//         child: OrientationBuilder(builder: (context, orientation) {
//           return Container(
//             height: screenSize.height,
//             width: screenSize.width,
//             decoration: const BoxDecoration(
//                 color: Colors.white,
//                 image: DecorationImage(
//                     fit: BoxFit.cover,
//                     image: AssetImage("assets/images/CancelledBg.png"))),
//             child: SafeArea(
//               child: FittedBox(
//                   child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 50.w,
//                         ),
//                         margin: EdgeInsets.only(bottom: 20.h),
//                         child: Image.asset(
//                           "assets/images/Cancelled.png",
//                           height: 280.h,
//                         )),
//                     Text(
//                       isError
//                           ? LocaleKeys.SALE_ERROR.tr()
//                           : LocaleKeys.SALE_CANCELLED.tr(),
//                       textAlign: TextAlign.center,
//                       style: Theme.of(context).textTheme.headline4!.copyWith(
//                           fontWeight: FontWeight.bold, color: Colors.black),
//                     ),
//                     SizedBox(
//                       height: 4.h,
//                     ),
//                     SizedBox(
//                       child: Text(
//                         isError
//                             ? LocaleKeys.An_error_occured_please_try_again.tr()
//                             : LocaleKeys
//                                 .You_have_successfully_cancelled_the_sale.tr(),
//                         textAlign: TextAlign.center,
//                         style: Theme.of(context)
//                             .textTheme
//                             .titleMedium!
//                             .copyWith(fontWeight: FontWeight.normal),
//                       ),
//                     ),
//                     errorMessage.isNotEmpty
//                         ? Text(
//                             errorMessage,
//                             textAlign: TextAlign.center,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleSmall!
//                                 .copyWith(fontWeight: FontWeight.normal),
//                           )
//                         : Container(),
//                     SizedBox(
//                       height: 20.h,
//                     ),
//                     Container(
//                       width: 1.sw,
//                       height: 55.h,
//                       margin: EdgeInsets.symmetric(horizontal: 25.w),
//                       padding: EdgeInsets.symmetric(horizontal: 0.w),
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: Text(
//                           LocaleKeys.Continue.tr(),
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleMedium!
//                               .copyWith(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               )),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
