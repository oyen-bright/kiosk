// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kiosk/views/Screens/Profile/kyc/confirm_details.dart';
// import 'package:kiosk/constants/constant_color.dart';
// import 'package:kiosk/views/widgets/screen_header.dart';
// import 'package:kiosk/cubits/.cubits.dart';
// import 'package:kiosk/translation/locale_keys.g.dart';

// //Put Update not working
// //poping rounte
// class UserAdressKyc extends StatefulWidget {
//   final String kyctype;
//   final Map? adress;
//   final Map<String, dynamic> data;
//   final bool isId;
//   final bool isUpdating;
//   const UserAdressKyc(
//       {Key? key,
//       this.adress,
//       required this.kyctype,
//       this.isUpdating = false,
//       required this.data,
//       required this.isId})
//       : super(key: key);

//   @override
//   _UserAdressKycState createState() => _UserAdressKycState();
// }

// class _UserAdressKycState extends State<UserAdressKyc> {
//   final _formkey = GlobalKey<FormState>();

//   final stateProvinceFocusNode = FocusNode();
//   final streetHouseFocusNode = FocusNode();
//   final streetNameFocusName = FocusNode();
//   final buidingNameFocusNode = FocusNode();
//   final townAreaFocusNode = FocusNode();
//   final postalZipFocusNode = FocusNode();

//   TextEditingController stateProvinceController = TextEditingController();
//   TextEditingController streetHouseController = TextEditingController();
//   TextEditingController streetNameController = TextEditingController();
//   TextEditingController buidingNameController = TextEditingController();
//   TextEditingController townAreaController = TextEditingController();
//   TextEditingController postalZipController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     final currentUser = context.read<UserCubit>().state.currentUser;
//     if (currentUser != null && currentUser.address.isNotEmpty) {
//       Map<String, dynamic> currentAddress = currentUser.address[0];

//       stateProvinceController.text = currentAddress['state'];
//       streetHouseController.text = currentAddress['street_or_flat_number'];
//       streetNameController.text = currentAddress['street_name'];
//       buidingNameController.text = currentAddress['building_name'];
//       townAreaController.text = currentAddress['city'];
//       postalZipController.text = currentAddress['zip_post_code'];
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.adress != null && widget.isUpdating == true) {
//       stateProvinceController.text = widget.adress!['state'];
//       streetHouseController.text = widget.adress!['street_or_flat_number'];
//       streetNameController.text = widget.adress!['street_name'];
//       buidingNameController.text = widget.adress!['building_name'];
//       townAreaController.text = widget.adress!['city'];
//       postalZipController.text = widget.adress!['zip_post_code'];
//     }

//     return Stack(alignment: Alignment.topCenter, children: [
//       Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           foregroundColor: kioskBlue,
//           centerTitle: false,
//           elevation: 0,
//         ),
//         body: GestureDetector(
//           onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//           child: Form(
//             key: _formkey,
//             child: ListView(
//               children: [
//                 ScreenHeader(
//                     subTitle: LocaleKeys
//                             .This_Address_information_will_be_used_when_you_are_performing_transactions
//                         .tr(),
//                     title: LocaleKeys.Edit_Address.tr()),
//                 SizedBox(
//                   height: 20.h,
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(top: 15, left: 25.w, right: 25.w),
//                   width: double.infinity,
//                   child: TextFormField(
//                     onEditingComplete: () {
//                       FocusScope.of(context).requestFocus(streetHouseFocusNode);
//                     },
//                     controller: stateProvinceController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return LocaleKeys.required.tr();
//                       }
//                       return null;
//                     },
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 10.w, vertical: 5.h),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Colors.black, width: 1.0),
//                         ),
//                         focusedErrorBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.red, width: 1.0),
//                         ),
//                         errorBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.red, width: 1.0),
//                         ),
//                         enabledBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Colors.grey, width: 1.0),
//                         ),
//                         hintStyle:
//                             Theme.of(context).textTheme.bodyMedium!.copyWith(
//                                   color: Colors.grey,
//                                 ),
//                         hintText: LocaleKeys.State_Provinces.tr()),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                         color: const Color(0xFFffffff),
//                       ),
//                       color: const Color(0xFFffffff),
//                       borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(50.r),
//                           bottomRight: Radius.circular(50.r),
//                           topRight: Radius.circular(50.r),
//                           topLeft: Radius.circular(50.r))),
//                   child: TextFormField(
//                     onEditingComplete: () {
//                       FocusScope.of(context).requestFocus(streetNameFocusName);
//                     },
//                     focusNode: streetHouseFocusNode,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return LocaleKeys.required.tr();
//                       }
//                       return null;
//                     },
//                     controller: streetHouseController,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 10.w, vertical: 5.h),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Colors.black, width: 1.0),
//                         ),
//                         focusedErrorBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.red, width: 1.0),
//                         ),
//                         errorBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.red, width: 1.0),
//                         ),
//                         enabledBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Colors.grey, width: 1.0),
//                         ),
//                         hintStyle:
//                             Theme.of(context).textTheme.bodyMedium!.copyWith(
//                                   color: Colors.grey,
//                                 ),
//                         hintText:
//                             LocaleKeys.Enter_Street_House_Flat_Number.tr()),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                         color: const Color(0xFFffffff),
//                       ),
//                       color: const Color(0xFFffffff),
//                       borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(50.r),
//                           bottomRight: Radius.circular(50.r),
//                           topRight: Radius.circular(50.r),
//                           topLeft: Radius.circular(50.r))),
//                   child: TextFormField(
//                     onEditingComplete: () {
//                       FocusScope.of(context).requestFocus(buidingNameFocusNode);
//                     },
//                     focusNode: streetNameFocusName,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return LocaleKeys.required;
//                       }
//                       return null;
//                     },
//                     controller: streetNameController,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 10.w, vertical: 5.h),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Colors.black, width: 1.0),
//                         ),
//                         focusedErrorBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.red, width: 1.0),
//                         ),
//                         errorBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.red, width: 1.0),
//                         ),
//                         enabledBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Colors.grey, width: 1.0),
//                         ),
//                         hintStyle:
//                             Theme.of(context).textTheme.bodyMedium!.copyWith(
//                                   color: Colors.grey,
//                                 ),
//                         hintText: LocaleKeys.Enter_Street_Name.tr()),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                         color: const Color(0xFFffffff),
//                       ),
//                       color: const Color(0xFFffffff),
//                       borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(50.r),
//                           bottomRight: Radius.circular(50.r),
//                           topRight: Radius.circular(50.r),
//                           topLeft: Radius.circular(50.r))),
//                   child: TextField(
//                     onEditingComplete: () {
//                       FocusScope.of(context).requestFocus(townAreaFocusNode);
//                     },
//                     focusNode: buidingNameFocusNode,
//                     controller: buidingNameController,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 10.w, vertical: 5.h),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Colors.black, width: 1.0),
//                         ),
//                         focusedErrorBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.red, width: 1.0),
//                         ),
//                         errorBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.red, width: 1.0),
//                         ),
//                         enabledBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Colors.grey, width: 1.0),
//                         ),
//                         hintStyle:
//                             Theme.of(context).textTheme.bodyMedium!.copyWith(
//                                   color: Colors.grey,
//                                 ),
//                         hintText: LocaleKeys.Building_Name.tr()),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                         color: const Color(0xFFffffff),
//                       ),
//                       color: const Color(0xFFffffff),
//                       borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(50.r),
//                           bottomRight: Radius.circular(50.r),
//                           topRight: Radius.circular(50.r),
//                           topLeft: Radius.circular(50.r))),
//                   child: TextFormField(
//                     onEditingComplete: () {
//                       FocusScope.of(context).requestFocus(postalZipFocusNode);
//                     },
//                     focusNode: townAreaFocusNode,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return LocaleKeys.required.tr();
//                       }
//                       return null;
//                     },
//                     controller: townAreaController,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 10.w, vertical: 5.h),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Colors.black, width: 1.0),
//                         ),
//                         focusedErrorBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.red, width: 1.0),
//                         ),
//                         errorBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.red, width: 1.0),
//                         ),
//                         enabledBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Colors.grey, width: 1.0),
//                         ),
//                         hintStyle:
//                             Theme.of(context).textTheme.bodyMedium!.copyWith(
//                                   color: Colors.grey,
//                                 ),
//                         hintText: LocaleKeys.Enter_Town_Area.tr()),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                         color: const Color(0xFFffffff),
//                       ),
//                       color: const Color(0xFFffffff),
//                       borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(50.r),
//                           bottomRight: Radius.circular(50.r),
//                           topRight: Radius.circular(50.r),
//                           topLeft: Radius.circular(50.r))),
//                   child: TextFormField(
//                     focusNode: postalZipFocusNode,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return LocaleKeys.required.tr();
//                       }
//                       return null;
//                     },
//                     controller: postalZipController,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 10.w, vertical: 5.h),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Colors.black, width: 1.0),
//                         ),
//                         focusedErrorBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.red, width: 1.0),
//                         ),
//                         errorBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.red, width: 1.0),
//                         ),
//                         enabledBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Colors.grey, width: 1.0),
//                         ),
//                         hintStyle:
//                             Theme.of(context).textTheme.bodyMedium!.copyWith(
//                                   color: Colors.grey,
//                                 ),
//                         hintText: LocaleKeys.Enter_Postal_Code_Zip_Code.tr()),
//                   ),
//                 ),
//                 Container(
//                   width: double.infinity,
//                   padding:
//                       EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.white, backgroundColor: kioskBlue,
//                       minimumSize: Size.fromHeight(50.h), // foreground
//                     ),
//                     onPressed: () async {
//                       FocusManager.instance.primaryFocus?.unfocus();

//                       if (_formkey.currentState!.validate()) {
//                         widget.data.addAll({
//                           "state_province": stateProvinceController.text,
//                           "street_house": streetHouseController.text,
//                           "street_name": streetNameController.text,
//                           "town_area": townAreaController.text,
//                           "postal_zip": postalZipController.text,
//                           "buiding_name": buidingNameController.text
//                         });
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => ConfirmDetailsKyc(
//                                       kYCType: widget.kyctype,
//                                       isId: widget.isId,
//                                       data: widget.data,
//                                     )));
//                       }
//                     },
//                     child: Text(
//                       LocaleKeys.Continue.tr().toUpperCase(),
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleMedium!
//                           .copyWith(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     ]);
//   }
// }
