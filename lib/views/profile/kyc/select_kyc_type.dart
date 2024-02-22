// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kiosk/views/Screens/Profile/kyc/onboard_kyc.dart';
// import 'package:kiosk/mobile/constants.dart';
// import 'package:kiosk/translation/locale_keys.g.dart';
// import 'package:sizedbox_extention/sizedbox_extention.dart';

// class SelectKYCType extends StatelessWidget {
//   const SelectKYCType({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     List merchantBusinessProfle = ["Personal", "Business"];

//     return Scaffold(
//         appBar: AppBar(
//           foregroundColor: kioskBlue,
//           elevation: 0,
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(LocaleKeys.Select_a_KYC_type.tr(),
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleLarge!
//                       .copyWith(color: kioskBlue, fontWeight: FontWeight.bold)),
//               SizedBox(
//                 height: 18.h,
//               ),
//               Wrap(
//                   children:
//                       List.generate(merchantBusinessProfle.length, (index) {
//                 return Padding(
//                   padding: EdgeInsets.all(0.r),
//                   child: SizedBox(
//                     width: 120.w,
//                     height: 120.h,
//                     child: GestureDetector(
//                       onTap: () => onBusinessSelect(
//                           context, merchantBusinessProfle[index]),
//                       child: Card(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.r),
//                         ),
//                         elevation: 10,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(10.r),
//                           child: GridTile(
//                             footer: SizedBox(
//                               height: 28.h,
//                               child: GridTileBar(
//                                 backgroundColor: kioskBlue,
//                                 title: Padding(
//                                   padding: EdgeInsets.symmetric(vertical: 5.h),
//                                   child: FittedBox(
//                                     child: AutoSizeText(
//                                       merchantBusinessProfle[index],
//                                       textAlign: TextAlign.center,
//                                       maxLines: 3,
//                                       style: TextStyle(fontSize: 15.sp),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             child: const FittedBox(
//                                 child: Padding(
//                               padding: EdgeInsets.all(10.0),
//                               child: Icon(
//                                 Icons.business,
//                                 color: Colors.black12,
//                               ),
//                             )),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               })),
//               56.height,
//               70.h.height
//             ],
//           ),
//         ));
//   }

//   void onBusinessSelect(
//       BuildContext context, String merchantBusinessProfle) async {
//     Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//             builder: (_) => KYCONboard(
//                   kyctype: merchantBusinessProfle,
//                 )));
//   }
// }
