// import 'dart:io';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kiosk/constants/constant_color.dart';
// import 'package:kiosk/views/widgets/loading_widget.dart';
// import 'package:kiosk/views/widgets/screen_header.dart';
// import 'package:kiosk/cubits/.cubits.dart';
// import 'package:kiosk/repositories/repositories.dart';
// import 'package:kiosk/translation/locale_keys.g.dart';
// import 'package:kiosk/widgets/alert_dialogs_widget.dart';
// import 'package:kiosk/widgets/select_image.dart';

// class ConfirmDetailsKyc extends StatefulWidget {
//   final Map<String, dynamic> data;
//   final String kYCType;
//   final bool isId;
//   const ConfirmDetailsKyc(
//       {Key? key, required this.data, required this.isId, required this.kYCType})
//       : super(key: key);

//   @override
//   _ConfirmDetailsKycState createState() => _ConfirmDetailsKycState();
// }

// class _ConfirmDetailsKycState extends State<ConfirmDetailsKyc> {
//   final TextEditingController _textFieldController = TextEditingController();
//   final TextEditingController _textFieldControllerBus = TextEditingController();
//   final TextEditingController _textFieldControllerBusEmail =
//       TextEditingController();
//   final TextEditingController _textFieldControllerlastName =
//       TextEditingController();
//   final TextEditingController _textFieldControllerEmail =
//       TextEditingController();
//   final TextEditingController _textFieldControllerBusRegNo =
//       TextEditingController();

//   File? userImage;
//   String firstName = "";
//   String lastName = "";
//   String email = "";
//   String businessName = "";
//   String businessEmail = "";
//   String busineesRegNo = "";

//   @override
//   void initState() {
//     super.initState();

//     final currentuser = context.read<UserCubit>().state.currentUser!;
//     firstName = currentuser.firstName;
//     lastName = currentuser.lastName;

//     email = currentuser.email;
//     _textFieldControllerlastName.text = lastName;
//     _textFieldController.text = firstName;
//     _textFieldControllerEmail.text = email;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<LoadingCubit, LoadingState>(
//         listener: (context, state) async {
//       if (state.status == Status.error) {
//         await errorAlertDialog(context, state.msg);
//         int count = 0;
//         Navigator.of(context).popUntil((_) => count++ >= 3);
//       }
//     }, builder: (context, state) {
//       final isLoading = state.status == Status.loading;

//       return WillPopScope(
//         onWillPop: () async => !isLoading,
//         child: Stack(alignment: Alignment.topCenter, children: [
//           Scaffold(
//             backgroundColor: Colors.white,
//             appBar: AppBar(
//               backgroundColor: Colors.white,
//               foregroundColor: kioskBlue,
//               centerTitle: false,
//               elevation: 0,
//             ),
//             body: GestureDetector(
//               onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//               child: ListView(
//                 children: [
//                   ScreenHeader(
//                       subTitle: LocaleKeys
//                               .Please_upload_a_valid_and_clear_image_of_your_face
//                           .tr(),
//                       title: LocaleKeys.Confirm_Details.tr()),
//                   Container(
//                     alignment: Alignment.center,
//                     margin: const EdgeInsets.all(0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           height: 10.h,
//                         ),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Expanded(
//                               flex: 1,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Container(
//                                       margin: EdgeInsets.only(
//                                           top: 10.h, left: 30.w, right: 30.w),
//                                       padding: const EdgeInsets.only(
//                                           top: 5, bottom: 5),
//                                       width: 180,
//                                       decoration: BoxDecoration(
//                                           border: Border.all(
//                                             color: const Color(0xFFffffff),
//                                           ),
//                                           color: kioskGrayBackground,
//                                           borderRadius: const BorderRadius.only(
//                                               bottomLeft: Radius.circular(10),
//                                               bottomRight: Radius.circular(10),
//                                               topRight: Radius.circular(10),
//                                               topLeft: Radius.circular(10))),
//                                       child: GestureDetector(
//                                         onTap: () async {
//                                           final file =
//                                               await uploadProductPicture(
//                                                   context);
//                                           if (file != null) {
//                                             setState(() {
//                                               userImage = file;
//                                             });
//                                           }
//                                         },
//                                         child: Builder(builder: (context) {
//                                           if (userImage != null) {
//                                             return Container(
//                                                 height: 130.h,
//                                                 color: kioskGrayBackground,
//                                                 child: ClipRRect(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           10.r),
//                                                   child: Image.file(
//                                                     userImage!,
//                                                     fit: BoxFit.fitWidth,
//                                                   ),
//                                                 ));
//                                           }
//                                           return Container(
//                                             height: 130.h,
//                                             color: kioskGrayBackground,
//                                             child: Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.center,
//                                               children: [
//                                                 const Icon(
//                                                     Icons.camera_alt_sharp),
//                                                 Text(
//                                                   LocaleKeys.Upload_picture
//                                                       .tr(),
//                                                   textAlign: TextAlign.center,
//                                                 )
//                                               ],
//                                             ),
//                                           );
//                                         }),
//                                       )),
//                                   Text(
//                                     LocaleKeys.Upload_Profile_Picture.tr(),
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12.sp,
//                                       color: Colors.white70,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 20.h,
//                         ),
//                         Container(
//                           margin:
//                               const EdgeInsets.only(top: 0, left: 0, right: 20),
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: const Color(0xFFffffff),
//                               ),
//                               color: const Color(0xFFffffff),
//                               borderRadius: BorderRadius.only(
//                                   bottomLeft: Radius.circular(20.r),
//                                   bottomRight: Radius.circular(20.r),
//                                   topRight: Radius.circular(20.r),
//                                   topLeft: Radius.circular(20.r))),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               SizedBox(
//                                 height: 10.h,
//                               ),
//                               ListTile(
//                                   leading: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: EdgeInsets.only(
//                                             left: 10.w, right: 0),
//                                         child: Text(
//                                           '${LocaleKeys.First_Name.tr()}: ',
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium!
//                                               .copyWith(
//                                                 fontWeight: FontWeight.normal,
//                                                 color: Colors.black,
//                                               ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         height: 5.h,
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.only(
//                                             left: 12.w, right: 0),
//                                         child: Text(
//                                           firstName,
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium!
//                                               .copyWith(
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   trailing: Container(
//                                     margin: EdgeInsets.only(bottom: 10.h),
//                                     child: InkWell(
//                                       onTap: () {
//                                         showDialog(
//                                             context: context,
//                                             builder: (context) {
//                                               return AlertDialog(
//                                                 title: Text(
//                                                     LocaleKeys.First_Name.tr()),
//                                                 content: TextField(
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .bodyMedium,
//                                                   onChanged: (value) {
//                                                     setState(() {
//                                                       firstName = value;
//                                                     });
//                                                   },
//                                                   controller:
//                                                       _textFieldController,
//                                                   decoration: InputDecoration(
//                                                       hintText: LocaleKeys
//                                                           .First_Name.tr()),
//                                                 ),
//                                                 actions: <Widget>[
//                                                   TextButton(
//                                                     child: const Text('OK'),
//                                                     onPressed: () {
//                                                       setState(() {
//                                                         if (_textFieldController
//                                                             .text.isNotEmpty) {
//                                                           firstName =
//                                                               _textFieldController
//                                                                   .text;
//                                                         }
//                                                         Navigator.pop(context);
//                                                       });
//                                                     },
//                                                   ),
//                                                 ],
//                                               );
//                                             });
//                                       },
//                                       child: Image.asset(
//                                         "assets/images/edit.png",
//                                         height: 20.h,
//                                         width: 20.w,
//                                         color: kioskBlue,
//                                       ),
//                                     ),
//                                   )),
//                               SizedBox(
//                                 height: 2.h,
//                               ),
//                               ListTile(
//                                   leading: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 10, right: 0),
//                                         child: Text(
//                                           '${LocaleKeys.Last_Name.tr()}: ',
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium!
//                                               .copyWith(
//                                                 fontWeight: FontWeight.normal,
//                                                 color: Colors.black,
//                                               ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         height: 2.h,
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 12, right: 0),
//                                         child: Text(
//                                           lastName,
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium!
//                                               .copyWith(
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   trailing: Container(
//                                     margin: EdgeInsets.only(bottom: 5.h),
//                                     child: InkWell(
//                                       onTap: () {
//                                         showDialog(
//                                             context: context,
//                                             builder: (context) {
//                                               return AlertDialog(
//                                                 title: Text(
//                                                     LocaleKeys.Last_Name.tr()),
//                                                 content: TextField(
//                                                   onChanged: (value) {
//                                                     setState(() {
//                                                       lastName = value;
//                                                     });
//                                                   },
//                                                   controller:
//                                                       _textFieldControllerlastName,
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .bodyMedium,
//                                                   decoration: InputDecoration(
//                                                       hintText: LocaleKeys
//                                                           .Last_Name.tr()),
//                                                 ),
//                                                 actions: <Widget>[
//                                                   TextButton(
//                                                     child: const Text('OK'),
//                                                     onPressed: () {
//                                                       setState(() {
//                                                         if (_textFieldController
//                                                             .text.isNotEmpty) {
//                                                           lastName =
//                                                               _textFieldControllerlastName
//                                                                   .text;
//                                                         }
//                                                         Navigator.pop(context);
//                                                       });
//                                                     },
//                                                   ),
//                                                 ],
//                                               );
//                                             });
//                                       },
//                                       child: Image.asset(
//                                         "assets/images/edit.png",
//                                         height: 20.h,
//                                         width: 20.w,
//                                         color: kioskBlue,
//                                       ),
//                                     ),
//                                   )),
//                               SizedBox(
//                                 height: 2.h,
//                               ),
//                               ListTile(
//                                   leading: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 10, right: 0),
//                                         child: Text(
//                                           '${LocaleKeys.Email.tr()}: ',
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium!
//                                               .copyWith(
//                                                 fontWeight: FontWeight.normal,
//                                                 color: Colors.black,
//                                               ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         height: 2.h,
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 12, right: 0),
//                                         child: Text(
//                                           email,
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium!
//                                               .copyWith(
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   trailing: Container(
//                                     margin: EdgeInsets.only(bottom: 10.h),
//                                     child: InkWell(
//                                       onTap: () {
//                                         showDialog(
//                                             context: context,
//                                             builder: (context) {
//                                               return AlertDialog(
//                                                 title:
//                                                     Text(LocaleKeys.Email.tr()),
//                                                 content: TextField(
//                                                   onChanged: (value) {
//                                                     setState(() {
//                                                       email = value;
//                                                     });
//                                                   },
//                                                   controller:
//                                                       _textFieldControllerEmail,
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .bodyMedium,
//                                                   decoration: InputDecoration(
//                                                       hintText: LocaleKeys.Email
//                                                           .tr()),
//                                                 ),
//                                                 actions: <Widget>[
//                                                   TextButton(
//                                                     child: const Text('OK'),
//                                                     onPressed: () {
//                                                       setState(() {
//                                                         if (_textFieldController
//                                                             .text.isNotEmpty) {
//                                                           email =
//                                                               _textFieldControllerEmail
//                                                                   .text;
//                                                         }
//                                                         Navigator.pop(context);
//                                                       });
//                                                     },
//                                                   ),
//                                                 ],
//                                               );
//                                             });
//                                       },
//                                       child: Image.asset(
//                                         "assets/images/edit.png",
//                                         height: 20.h,
//                                         width: 20.w,
//                                         color: kioskBlue,
//                                       ),
//                                     ),
//                                   )),
//                               SizedBox(
//                                 height: 2.h,
//                               ),
//                               ListTile(
//                                   leading: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 10, right: 0),
//                                         child: Text(
//                                           '${LocaleKeys.Identification_Type.tr()}: ',
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium!
//                                               .copyWith(
//                                                 fontWeight: FontWeight.normal,
//                                                 color: Colors.black,
//                                               ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         height: 2.h,
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 12, right: 0),
//                                         child: Text(
//                                           widget.isId
//                                               ? LocaleKeys.Identification_Card
//                                                   .tr()
//                                               : LocaleKeys
//                                                   .International_Passport.tr(),
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium!
//                                               .copyWith(
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   trailing: Container(
//                                     margin: const EdgeInsets.only(bottom: 20),
//                                     child: InkWell(
//                                       onTap: () {
//                                         int count = 0;
//                                         Navigator.of(context)
//                                             .popUntil((_) => count++ >= 2);
//                                       },
//                                       child: Image.asset(
//                                         "assets/images/edit.png",
//                                         height: 20.h,
//                                         width: 20.w,
//                                         color: kioskBlue,
//                                       ),
//                                     ),
//                                   )),
//                               SizedBox(
//                                 height: 2.h,
//                               ),
//                               ListTile(
//                                   leading: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: EdgeInsets.only(
//                                             left: 10.w, right: 0),
//                                         child: Text(
//                                           '${LocaleKeys.Address.tr()}: ',
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium!
//                                               .copyWith(
//                                                 fontWeight: FontWeight.normal,
//                                                 color: Colors.black,
//                                               ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         height: 2.h,
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 12, right: 0),
//                                         child: Text(
//                                           '${widget.data["buiding_name"] + " " + widget.data["street_house"] + "," + widget.data["street_name"] + "," + widget.data["town_area"] + "," + widget.data["state_province"]}',
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium!
//                                               .copyWith(
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   trailing: Container(
//                                     margin: const EdgeInsets.only(bottom: 20),
//                                     child: InkWell(
//                                       onTap: () {
//                                         Navigator.pop(context);
//                                       },
//                                       child: Image.asset(
//                                         "assets/images/edit.png",
//                                         height: 20.h,
//                                         width: 20.w,
//                                         color: kioskBlue,
//                                       ),
//                                     ),
//                                   )),
//                               SizedBox(
//                                 height: 2.h,
//                               ),
//                               Builder(builder: (context) {
//                                 if (widget.kYCType != "Business") {
//                                   return Container();
//                                 }
//                                 return ListTile(
//                                     leading: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 10, right: 0),
//                                           child: Text(
//                                             '${LocaleKeys.Business_Name.tr()}: ',
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodyMedium!
//                                                 .copyWith(
//                                                   fontWeight: FontWeight.normal,
//                                                   color: Colors.black,
//                                                 ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           height: 2.h,
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 12, right: 0),
//                                           child: Text(
//                                             businessName,
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodyMedium!
//                                                 .copyWith(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     trailing: Container(
//                                       margin: EdgeInsets.only(bottom: 10.h),
//                                       child: InkWell(
//                                         onTap: () {
//                                           showDialog(
//                                               context: context,
//                                               builder: (context) {
//                                                 return AlertDialog(
//                                                   title: Text(LocaleKeys
//                                                       .Business_Name.tr()),
//                                                   content: TextField(
//                                                     onChanged: (value) {
//                                                       setState(() {
//                                                         businessName = value;
//                                                       });
//                                                     },
//                                                     controller:
//                                                         _textFieldControllerBus,
//                                                     decoration: InputDecoration(
//                                                         hintText: LocaleKeys
//                                                                 .Business_Name
//                                                             .tr()),
//                                                     style: Theme.of(context)
//                                                         .textTheme
//                                                         .bodyMedium,
//                                                   ),
//                                                   actions: <Widget>[
//                                                     TextButton(
//                                                       child: const Text('OK'),
//                                                       onPressed: () {
//                                                         setState(() {
//                                                           if (_textFieldControllerBus
//                                                               .text
//                                                               .isNotEmpty) {
//                                                             businessName =
//                                                                 _textFieldControllerBus
//                                                                     .text;
//                                                           }
//                                                           Navigator.pop(
//                                                               context);
//                                                         });
//                                                       },
//                                                     ),
//                                                   ],
//                                                 );
//                                               });
//                                         },
//                                         child: Image.asset(
//                                           "assets/images/edit.png",
//                                           height: 20.h,
//                                           width: 20.w,
//                                           color: kioskBlue,
//                                         ),
//                                       ),
//                                     ));
//                               }),
//                               SizedBox(
//                                 height: 2.h,
//                               ),
//                               Builder(builder: (context) {
//                                 if (widget.kYCType != "Business") {
//                                   return Container();
//                                 }
//                                 return ListTile(
//                                     leading: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 10, right: 0),
//                                           child: Text(
//                                             '${LocaleKeys.Business_Email.tr()}: ',
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodyMedium!
//                                                 .copyWith(
//                                                   fontWeight: FontWeight.normal,
//                                                   color: Colors.black,
//                                                 ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           height: 2.h,
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 12, right: 0),
//                                           child: Text(
//                                             businessEmail,
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodyMedium!
//                                                 .copyWith(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     trailing: Container(
//                                       margin: EdgeInsets.only(bottom: 10.h),
//                                       child: InkWell(
//                                         onTap: () {
//                                           showDialog(
//                                               context: context,
//                                               builder: (context) {
//                                                 return AlertDialog(
//                                                   title: Text(LocaleKeys
//                                                       .Business_Email.tr()),
//                                                   content: TextField(
//                                                     onChanged: (value) {
//                                                       setState(() {
//                                                         businessEmail = value;
//                                                       });
//                                                     },
//                                                     controller:
//                                                         _textFieldControllerBusEmail,
//                                                     decoration: InputDecoration(
//                                                         hintText: LocaleKeys
//                                                                 .Business_Email
//                                                             .tr()),
//                                                     style: Theme.of(context)
//                                                         .textTheme
//                                                         .bodyMedium,
//                                                   ),
//                                                   actions: <Widget>[
//                                                     TextButton(
//                                                       child: const Text('OK'),
//                                                       onPressed: () {
//                                                         setState(() {
//                                                           if (_textFieldControllerBusEmail
//                                                               .text
//                                                               .isNotEmpty) {
//                                                             businessEmail =
//                                                                 _textFieldControllerBusEmail
//                                                                     .text;
//                                                           }
//                                                           Navigator.pop(
//                                                               context);
//                                                         });
//                                                       },
//                                                     ),
//                                                   ],
//                                                 );
//                                               });
//                                         },
//                                         child: Image.asset(
//                                           "assets/images/edit.png",
//                                           height: 20.h,
//                                           width: 20.w,
//                                           color: kioskBlue,
//                                         ),
//                                       ),
//                                     ));
//                               }),
//                               SizedBox(
//                                 height: 2.h,
//                               ),
//                               Builder(builder: (context) {
//                                 if (widget.kYCType != "Business") {
//                                   return Container();
//                                 }
//                                 return ListTile(
//                                     leading: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 10, right: 0),
//                                           child: Text(
//                                             '${LocaleKeys.Business_Registration_Number_profile.tr()}: ',
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodyMedium!
//                                                 .copyWith(
//                                                   fontWeight: FontWeight.normal,
//                                                   color: Colors.black,
//                                                 ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           height: 2.h,
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 12, right: 0),
//                                           child: Text(
//                                             busineesRegNo,
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodyMedium!
//                                                 .copyWith(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     trailing: Container(
//                                       margin: EdgeInsets.only(bottom: 10.h),
//                                       child: InkWell(
//                                         onTap: () {
//                                           showDialog(
//                                               context: context,
//                                               builder: (context) {
//                                                 return AlertDialog(
//                                                   title: Text(LocaleKeys
//                                                           .Business_Registration_Number
//                                                       .tr()),
//                                                   content: TextField(
//                                                     onChanged: (value) {
//                                                       setState(() {
//                                                         busineesRegNo = value;
//                                                       });
//                                                     },
//                                                     controller:
//                                                         _textFieldControllerBusRegNo,
//                                                     style: Theme.of(context)
//                                                         .textTheme
//                                                         .bodyMedium,
//                                                     decoration: InputDecoration(
//                                                         hintText: LocaleKeys
//                                                                 .Business_Registration_Number
//                                                             .tr()),
//                                                   ),
//                                                   actions: <Widget>[
//                                                     TextButton(
//                                                       child: const Text('OK'),
//                                                       onPressed: () {
//                                                         setState(() {
//                                                           if (_textFieldControllerBusRegNo
//                                                               .text
//                                                               .isNotEmpty) {
//                                                             busineesRegNo =
//                                                                 _textFieldControllerBusRegNo
//                                                                     .text;
//                                                           }
//                                                           Navigator.pop(
//                                                               context);
//                                                         });
//                                                       },
//                                                     ),
//                                                   ],
//                                                 );
//                                               });
//                                         },
//                                         child: Image.asset(
//                                           "assets/images/edit.png",
//                                           height: 20.h,
//                                           width: 20.w,
//                                           color: kioskBlue,
//                                         ),
//                                       ),
//                                     ));
//                               }),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     width: double.infinity,
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         backgroundColor: kioskBlue,
//                         minimumSize: Size.fromHeight(50.h), // foreground
//                       ),
//                       onPressed: () async {
//                         try {
//                           if (userImage == null) {
//                             errorAlertDialog(
//                                 context, LocaleKeys.Please_upload_image.tr(),
//                                 title: LocaleKeys.No_image_selected.tr());
//                           } else if (businessName.isEmpty &&
//                               widget.kYCType == "Business") {
//                             errorAlertDialog(context,
//                                 LocaleKeys.Please_input_your_business_name.tr(),
//                                 title: LocaleKeys.Required_Field.tr());

//                             // } else if (busineesRegNo.isEmpty &&
//                             //     widget.kYCType == "Business") {
//                             //   errorAlertDialog(
//                             //       context,
//                             //       LocaleKeys
//                             //               .Please_input_your_business_registration_number
//                             //           .tr(),
//                             //       title: LocaleKeys.Required_Field.tr());
//                           } else if (businessEmail.isEmpty &&
//                               widget.kYCType == "Business") {
//                             errorAlertDialog(
//                                 context,
//                                 LocaleKeys
//                                         .Please_input_your_business_email_address
//                                     .tr(),
//                                 title: LocaleKeys.Required_Field.tr());
//                           } else {
//                             widget.data.addAll({
//                               "firstName": firstName,
//                               "lastName": lastName,
//                               "email": email,
//                               "UserImage": userImage,
//                               "BusinessName": businessName,
//                               "busineesRegNo": busineesRegNo,
//                               "businessEmail": businessEmail
//                             });

//                             context
//                                 .read<LoadingCubit>()
//                                 .loadingState(message: "Creating address");

//                             final response = await context
//                                 .read<UserRepository>()
//                                 .uploadKYC(
//                                     data: widget.data,
//                                     isMerchant: widget.kYCType == "Business");
//                             context.read<LoadingCubit>().loadedingState();
//                             await successAlertDialog(context, response);
//                             int count = 0;
//                             Navigator.of(context).popUntil((_) => count++ >= 4);
//                           }
//                         } catch (e) {
//                           context
//                               .read<LoadingCubit>()
//                               .errorState(message: e.toString());
//                         }
//                       },
//                       child: Text(
//                         LocaleKeys.Continue.tr().toUpperCase(),
//                         style: Theme.of(context)
//                             .textTheme
//                             .titleMedium!
//                             .copyWith(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20.h,
//                   )
//                 ],
//               ),
//             ),
//           ),
//           isLoading
//               ? const LoadingWidget(
//                   title: "Submitting KYC",
//                 )
//               : Container()
//         ]),
//       );
//     });
//   }

//   bool isValidEmail(String email) {
//     return RegExp(
//             r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
//         .hasMatch(email.trim());
//   }
// }
