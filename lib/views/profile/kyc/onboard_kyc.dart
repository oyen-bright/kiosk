// import 'dart:io';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kiosk/views/Screens/Profile/kyc/identity_information.dart';
// import 'package:kiosk/views/widgets/screen_header.dart';
// import 'package:kiosk/constants/constant_color.dart';
// import 'package:kiosk/translation/locale_keys.g.dart';
// import 'package:kiosk/widgets/alert_dialogs_widget.dart';
// import 'package:kiosk/widgets/select_image.dart';

// class KYCONboard extends StatefulWidget {
//   final String kyctype;
//   const KYCONboard({Key? key, required this.kyctype}) : super(key: key);

//   @override
//   State<KYCONboard> createState() => _KYCONboardState();
// }

// class _KYCONboardState extends State<KYCONboard> {
//   File? idImage;
//   File? idImageBack;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: kioskBlue,
//         centerTitle: false,
//         elevation: 0,
//       ),
//       body: ListView(children: [
//         ScreenHeader(
//             subTitle: LocaleKeys.Upload_Image_of_ID_card.tr(),
//             title: LocaleKeys.Identity_Verification.tr()),
//         SizedBox(
//           height: 10.h,
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 25.w),
//           child: Column(
//             children: List.generate(6, (index) {
//               List<String> info = [
//                 LocaleKeys.Government_Issued.tr(),
//                 LocaleKeys.Original_full_size.tr(),
//                 LocaleKeys.Place_documents_against.tr(),
//                 LocaleKeys.Readable_well_lit_coloured_images.tr(),
//                 LocaleKeys.No_black_and_white_Images.tr(),
//                 LocaleKeys.No_edited_or_expired_documents.tr()
//               ];
//               return SizedBox(
//                 height: 30.h,
//                 child: ListTile(
//                   visualDensity:
//                       const VisualDensity(horizontal: 0, vertical: -4),
//                   contentPadding: EdgeInsets.symmetric(horizontal: 5.w),
//                   tileColor: Colors.white,
//                   horizontalTitleGap: 6.0,
//                   minLeadingWidth: 0,
//                   leading: Icon(
//                     Icons.check,
//                     color: index < 3 ? Colors.green : Colors.red,
//                     size: 13,
//                   ),
//                   title: Text(
//                     info[index],
//                     textAlign: TextAlign.left,
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodySmall!
//                         .copyWith(color: Colors.black54),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//         SizedBox(
//           height: 20.h,
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 25.w),
//           child: Text(
//             LocaleKeys.File_size_must_be_between.tr(),
//             textAlign: TextAlign.left,
//             style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//         ),
//         SizedBox(
//           height: 10.h,
//         ),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 25.w),
//           width: 1.sw,
//           child: Row(
//             children: [
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () async {
//                     final file = await uploadProductPicture(context);
//                     if (file != null) {
//                       setState(() {
//                         idImage = file;
//                       });
//                     }
//                   },
//                   child: Builder(builder: (context) {
//                     if (idImage != null) {
//                       return Container(
//                           height: 130.h,
//                           color: kioskGrayBackground,
//                           child: Image.file(
//                             idImage!,
//                             fit: BoxFit.fitWidth,
//                           ));
//                     }
//                     return Container(
//                       height: 130.h,
//                       color: kioskGrayBackground,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.camera_alt_sharp),
//                           Text(
//                             LocaleKeys.Upload_Front_Page.tr(),
//                             textAlign: TextAlign.center,
//                           )
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//               SizedBox(
//                 width: 5.w,
//               ),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () async {
//                     final file = await uploadProductPicture(context);
//                     if (file != null) {
//                       setState(() {
//                         idImageBack = file;
//                       });
//                     }
//                   },
//                   child: Builder(builder: (context) {
//                     if (idImageBack != null) {
//                       return Container(
//                           height: 130.h,
//                           color: kioskGrayBackground,
//                           child: Image.file(
//                             idImageBack!,
//                             fit: BoxFit.fitWidth,
//                           ));
//                     }
//                     return Container(
//                       height: 130.h,
//                       color: kioskGrayBackground,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.camera_alt_sharp),
//                           Text(
//                             LocaleKeys.Upload_back_Page.tr(),
//                             textAlign: TextAlign.center,
//                           )
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//               )
//             ],
//           ),
//         ),
//         SizedBox(
//           height: 5.h,
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 25.w),
//           child: Text(
//             LocaleKeys.This_Information_is_used_for_personal_verification_only
//                 .tr(),
//             textAlign: TextAlign.left,
//             style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                   color: Colors.grey,
//                   fontWeight: FontWeight.normal,
//                 ),
//           ),
//         ),
//         SizedBox(
//           height: 5.h,
//         ),
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: 25.w),
//           height: 50.h,
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: () async {
//               if (idImage == null) {
//                 errorAlertDialog(
//                     context, LocaleKeys.Please_upload_the_front_of_your_ID.tr(),
//                     title: LocaleKeys.No_image_selected.tr());
//               } else if (idImageBack == null) {
//                 errorAlertDialog(
//                     context, LocaleKeys.Please_upload_the_back_of_your_ID.tr(),
//                     title: LocaleKeys.No_image_selected.tr());
//               } else {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => IdentityInformation(
//                               kyctype: widget.kyctype,
//                               userData: {
//                                 "IdFront": idImage,
//                                 "IdBack": idImageBack
//                               },
//                             )));
//               }
//             },
//             child: Text(
//               LocaleKeys.Continue.tr().toUpperCase(),
//               style: Theme.of(context)
//                   .textTheme
//                   .titleMedium!
//                   .copyWith(color: Colors.white),
//             ),
//           ),
//         ),
//       ]),
//     );
//   }
// }
