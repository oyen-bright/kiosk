// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_material_pickers/flutter_material_pickers.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kiosk/constants/constant_color.dart';
// import 'package:kiosk/models/countries.dart';
// import 'package:kiosk/repositories/.repositories.dart';
// import 'package:kiosk/translation/locale_keys.g.dart';
// import 'package:kiosk/views/Screens/Profile/kyc/user_address.dart';
// import 'package:kiosk/views/widgets/loading_widget.dart';
// import 'package:kiosk/views/widgets/screen_header.dart';
// import 'package:kiosk/widgets/alert_dialogs_widget.dart';
// import 'package:pattern_formatter/pattern_formatter.dart';

// class IdentityInformation extends StatefulWidget {
//   final Map<String, dynamic> userData;
//   final String kyctype;
//   const IdentityInformation(
//       {Key? key, required this.userData, required this.kyctype})
//       : super(key: key);

//   @override
//   _IdentityInformationState createState() => _IdentityInformationState();
// }

// class _IdentityInformationState extends State<IdentityInformation> {
//   String _dropDownValue = "";
//   String dropDownCountry = "";
//   String dropDownCountryId2 = "";
//   String selectedDate = "";

//   final String _dropDownValueId = "";
//   String dropDownCountryId = "";
//   String dropDownCountryIdId = "";
//   String selectedDateId = "";

//   TextEditingController passportNumberController = TextEditingController();
//   TextEditingController idNumberController = TextEditingController();

//   final idissueDateFocus = FocusNode();
//   final idExpireDaeFocus = FocusNode();
//   final passportExpDate = FocusNode();

//   final idNo = FocusNode();
//   final idIssueDate = FocusNode();
//   final idExpDate = FocusNode();

//   var date = DateTime.now();

//   String isSelectedis = "Passport";

//   final TextEditingController idExpdateController = TextEditingController();
//   final TextEditingController idIsudateController = TextEditingController();

//   String countryIos = "";
//   List<Countries> countryData2 = [];
//   Map<String, String> idOfCountryR = {};
//   Map<String, String> nameOfCountryR = {};
//   List<String> phoneCountries = [];

//   @override
//   void initState() {
//     getCountry();
//     super.initState();
//   }

//   void getCountry() async {
//     try {
//       final countryData =
//           await context.read<UserRepository>().getContriesAsMap();

//       List<Countries> _fetchedData = [];
//       List<String> _fetchedData2 = [];
//       Map<String, String> idOfCountry = {};
//       Map<String, String> nameOfCountry = {};

//       countryData['data'].forEach((value) {
//         _fetchedData.add(Countries(
//           id: value['id'],
//           name: value['name'],
//           iso2: value['iso2'],
//         ));

//         countryData['data'].forEach((value) {
//           _fetchedData2.add(value['iso2'].toString());
//           idOfCountry.addAll({value["name"]: value['id'].toString()});
//           nameOfCountry
//               .addAll({value["id"].toString(): value['name'].toString()});
//         });

//         setState(() {
//           phoneCountries = _fetchedData2;
//           idOfCountryR = idOfCountry;
//           nameOfCountryR = nameOfCountry;
//           countryData2 = _fetchedData;
//         });
//       });
//     } catch (e) {
//       await errorAlertDialog(context, e.toString());
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Builder(builder: (context) {
//       if (countryData2.isEmpty) {
//         return Container(
//             color: Colors.white,
//             child: const Center(child: LoadingWidget(title: "")));
//       }
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           foregroundColor: kioskBlue,
//           centerTitle: false,
//           elevation: 0,
//         ),
//         body: GestureDetector(
//           onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//           child: ListView(
//             children: [
//               ScreenHeader(
//                   subTitle: LocaleKeys
//                       .Please_fill_out_the_form_below_to_complete_your_KYC.tr(),
//                   title: LocaleKeys.Identity_Information.tr()),
//               SizedBox(
//                 height: 20.h,
//               ),
//               Container(
//                 margin: EdgeInsets.only(top: 15, left: 25.w, right: 25.w),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                     border: Border.all(
//                       color: const Color(0xFFffffff),
//                     ),
//                     color: const Color(0xFFffffff),
//                     borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(50.r),
//                         bottomRight: Radius.circular(50.r),
//                         topRight: Radius.circular(50.r),
//                         topLeft: Radius.circular(50.r))),
//                 child: TextField(
//                     onEditingComplete: () {
//                       FocusScope.of(context).requestFocus(idissueDateFocus);
//                     },
//                     keyboardType: TextInputType.number,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     controller: idNumberController,
//                     decoration: InputDecoration(
//                         focusColor: const Color(0xFF0000BC),
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
//                         hintText: "ID Number")),
//               ),
//               Container(
//                 margin: EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                     border: Border.all(
//                       color: const Color(0xFFffffff),
//                     ),
//                     color: const Color(0xFFffffff),
//                     borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(50.r),
//                         bottomRight: Radius.circular(50.r),
//                         topRight: Radius.circular(50.r),
//                         topLeft: Radius.circular(50.r))),
//                 child: TextField(
//                   onEditingComplete: () {
//                     FocusScope.of(context).requestFocus(idExpireDaeFocus);
//                   },
//                   focusNode: idissueDateFocus,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [
//                     DateInputFormatter(),
//                   ],
//                   controller: idIsudateController,
//                   style: Theme.of(context).textTheme.bodyMedium,
//                   decoration: InputDecoration(
//                       focusColor: const Color(0xFF0000BC),
//                       contentPadding:
//                           EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
//                       focusedBorder: const OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.black, width: 1.0),
//                       ),
//                       focusedErrorBorder: const OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.red, width: 1.0),
//                       ),
//                       errorBorder: const OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.red, width: 1.0),
//                       ),
//                       enabledBorder: const OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey, width: 1.0),
//                       ),
//                       hintStyle:
//                           Theme.of(context).textTheme.bodyMedium!.copyWith(
//                                 color: Colors.grey,
//                               ),
//                       hintText: "ID Issue Date"),
//                 ),
//               ),
//               Container(
//                 margin: EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                     border: Border.all(
//                       color: const Color(0xFFffffff),
//                     ),
//                     color: const Color(0xFFffffff),
//                     borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(50.r),
//                         bottomRight: Radius.circular(50.r),
//                         topRight: Radius.circular(50.r),
//                         topLeft: Radius.circular(50.r))),
//                 child: TextField(
//                   focusNode: idExpireDaeFocus,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [
//                     DateInputFormatter(),
//                   ],
//                   controller: idExpdateController,
//                   style: Theme.of(context).textTheme.bodyMedium,
//                   decoration: InputDecoration(
//                       focusColor: const Color(0xFF0000BC),
//                       contentPadding:
//                           EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
//                       focusedBorder: const OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.black, width: 1.0),
//                       ),
//                       focusedErrorBorder: const OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.red, width: 1.0),
//                       ),
//                       errorBorder: const OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.red, width: 1.0),
//                       ),
//                       enabledBorder: const OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey, width: 1.0),
//                       ),
//                       hintStyle:
//                           Theme.of(context).textTheme.bodyMedium!.copyWith(
//                                 color: Colors.grey,
//                               ),
//                       hintText: "ID Expiration Date"),
//                 ),
//               ),
//               SizedBox(
//                 height: 10.h,
//               ),
//               GestureDetector(
//                 onTap: () {
//                   FocusScope.of(context).unfocus();
//                   showMaterialScrollPicker(
//                     headerColor: kioskGrayBackground,
//                     headerTextColor: kioskBlue,
//                     // backgroundColor: greybacground,
//                     maxLongSide: 400.h,
//                     buttonTextColor: Colors.black,

//                     context: context,
//                     title: LocaleKeys.Select_Your_Gender.tr().toUpperCase(),
//                     items: ["Male", "Female"],
//                     selectedItem: _dropDownValue,
//                     onChanged: (value) =>
//                         setState(() => _dropDownValue = value.toString()),
//                   );
//                 },
//                 child: Container(
//                     margin: EdgeInsets.only(top: 0, left: 25.w, right: 25.w),
//                     width: double.infinity,
//                     padding: EdgeInsets.fromLTRB(10.w, 6.h, 5.w, 6.h),
//                     decoration: BoxDecoration(
//                         border: Border.all(color: Colors.black),
//                         color: const Color(0xFFffffff),
//                         borderRadius: BorderRadius.only(
//                             bottomLeft: Radius.circular(0.r),
//                             bottomRight: Radius.circular(0.r),
//                             topRight: Radius.circular(0.r),
//                             topLeft: Radius.circular(0.r))),
//                     child: Row(
//                       children: [
//                         Expanded(
//                             child: Text(
//                           _dropDownValue.isEmpty
//                               ? "Select Gender"
//                               : _dropDownValue,
//                           style:
//                               Theme.of(context).textTheme.bodyMedium!.copyWith(
//                                     color: _dropDownValue.isEmpty
//                                         ? Colors.grey
//                                         : Colors.black,
//                                   ),
//                         )),
//                         Icon(
//                           Icons.arrow_drop_down,
//                           size: 30.r,
//                         )
//                       ],
//                     )),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   showMaterialDatePicker(
//                     headerColor: kioskGrayBackground,
//                     headerTextColor: kioskBlue,
//                     maxLongSide: 450.h,
//                     title: LocaleKeys.Select_Date_Of_Birth.tr().toUpperCase(),
//                     context: context,
//                     selectedDate: date,
//                     onChanged: (value) => setState(
//                         () => selectedDate = value.toString().substring(0, 10)),
//                     firstDate: DateTime(1900),
//                     lastDate: DateTime.now(),
//                   );
//                 },
//                 child: Container(
//                     margin: EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
//                     width: double.infinity,
//                     padding: EdgeInsets.fromLTRB(10.w, 6.h, 5.w, 6.h),
//                     decoration: BoxDecoration(
//                         border: Border.all(),
//                         color: const Color(0xFFffffff),
//                         borderRadius: BorderRadius.only(
//                             bottomLeft: Radius.circular(0.r),
//                             bottomRight: Radius.circular(0.r),
//                             topRight: Radius.circular(0.r),
//                             topLeft: Radius.circular(0.r))),
//                     child: Row(
//                       children: [
//                         Expanded(
//                             child: Text(
//                           selectedDate.isEmpty
//                               ? "Select Date of Birth"
//                               : selectedDate,
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         )),
//                         Icon(
//                           Icons.arrow_drop_down,
//                           size: 30.r,
//                         )
//                       ],
//                     )),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   showMaterialScrollPicker(
//                     buttonTextColor: Colors.black,
//                     headerColor: kioskGrayBackground,
//                     headerTextColor: kioskBlue,
//                     // backgroundColor: greybacground,
//                     maxLongSide: 400.h,
//                     context: context,
//                     title: LocaleKeys.Select_Your_Country.tr().toUpperCase(),
//                     items: countryData2.map(
//                       (val) {
//                         return val.name!;
//                       },
//                     ).toList(),
//                     selectedItem: dropDownCountry,
//                     onChanged: (value) =>
//                         setState(() => dropDownCountry = value.toString()),
//                   );
//                 },
//                 child: Container(
//                     margin: EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
//                     width: double.infinity,
//                     padding: EdgeInsets.fromLTRB(10.w, 6.h, 5.w, 6.h),
//                     decoration: BoxDecoration(
//                         border: Border.all(),
//                         color: const Color(0xFFffffff),
//                         borderRadius: BorderRadius.only(
//                             bottomLeft: Radius.circular(0.r),
//                             bottomRight: Radius.circular(0.r),
//                             topRight: Radius.circular(0.r),
//                             topLeft: Radius.circular(0.r))),
//                     child: Row(
//                       children: [
//                         Expanded(
//                             child: Text(
//                           dropDownCountry.isEmpty
//                               ? "Select Country"
//                               : dropDownCountry,
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         )),
//                         Icon(
//                           Icons.arrow_drop_down,
//                           size: 30.r,
//                         )
//                       ],
//                     )),
//               ),
//               SizedBox(
//                 height: 10.h,
//               ),
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white, backgroundColor: kioskBlue,
//                     minimumSize: Size.fromHeight(50.h), // foreground
//                   ),
//                   onPressed: () async {
//                     if (idNumberController.text.isEmpty) {
//                       errorAlertDialog(
//                           context, LocaleKeys.Please_Input_your_Id_Number.tr(),
//                           title: LocaleKeys.Required_Field.tr());
//                     } else if (idIsudateController.text == "" ||
//                         idExpdateController.text == "") {
//                       errorAlertDialog(
//                           context, LocaleKeys.Please_check_your_inputs.tr(),
//                           title: LocaleKeys.Required_Field.tr());
//                     } else if (idIsudateController.text != "" &&
//                             idIsudateController.text.substring(
//                                     idIsudateController.text.length - 1) ==
//                                 "-" ||
//                         idIsudateController.text.substring(
//                                 idIsudateController.text.length - 1) ==
//                             "Y" ||
//                         int.parse(idIsudateController.text.substring(3, 5)) >
//                             12) {
//                       errorAlertDialog(
//                           context, LocaleKeys.Invalid_date_format_D.tr(),
//                           title: LocaleKeys.Required_Field.tr());
//                     } else if (idExpdateController.text != "" &&
//                             idExpdateController.text.substring(
//                                     idExpdateController.text.length - 1) ==
//                                 "-" ||
//                         idExpdateController.text.substring(
//                                 idExpdateController.text.length - 1) ==
//                             "Y" ||
//                         int.parse(idExpdateController.text.substring(3, 5)) >
//                             12) {
//                       errorAlertDialog(
//                           context, LocaleKeys.Invalid_input_expire_date.tr(),
//                           title: LocaleKeys.Required_Field.tr());
//                     } else if (dropDownCountry == "") {
//                       errorAlertDialog(context,
//                           LocaleKeys.Please_select_your_Id_country.tr(),
//                           title: LocaleKeys.Required_Field.tr());
//                     } else if (_dropDownValue == "") {
//                       errorAlertDialog(
//                           context, LocaleKeys.Select_Your_Gender.tr(),
//                           title: LocaleKeys.Required_Field.tr());
//                     } else if (selectedDate.isEmpty) {
//                       errorAlertDialog(
//                           context, LocaleKeys.Select_Date_Of_Birth.tr(),
//                           title: LocaleKeys.Required_Field.tr());
//                     } else {
//                       widget.userData.addAll({
//                         "IdExpdate": idExpdateController.text,
//                         "IdIsudate": idIsudateController.text,
//                         "IdNumber": idNumberController.text,
//                         "SelectedDate": selectedDate,
//                         "Gender": _dropDownValueId,
//                         "selectedCountry": idOfCountryR[dropDownCountry]
//                       });
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) => UserAdressKyc(
//                                     kyctype: widget.kyctype,
//                                     isId: true,
//                                     data: widget.userData,
//                                   )));
//                     }
//                   },
//                   child: Text(
//                     LocaleKeys.Continue.tr().toUpperCase(),
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }
