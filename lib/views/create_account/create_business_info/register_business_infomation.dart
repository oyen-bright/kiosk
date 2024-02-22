// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:kiosk/controllers/.controllers.dart';
import 'package:kiosk/controllers/categories_controller.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/countries.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/utils.dart';
import 'package:kiosk/views/create_account/promo_code/promo_code.dart';
import 'package:kiosk/views/create_account/wellcome.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class RegisterBusinessInformation extends StatefulWidget {
  final bool fromLogin;
  final String? userEmail;
  final String? userPassword;
  final PhoneNumber? phoneNumber;
  final bool isSME;
  const RegisterBusinessInformation(
      {Key? key,
      this.fromLogin = false,
      this.isSME = false,
      this.phoneNumber,
      this.userEmail,
      this.userPassword})
      : super(key: key);

  @override
  State<RegisterBusinessInformation> createState() =>
      _RegisterBusinessInformationState();
}

class _RegisterBusinessInformationState
    extends State<RegisterBusinessInformation> {
  late final TextEditingController businessName;
  late final TextEditingController businessContactNumber;
  late final TextEditingController businessType;
  late final TextEditingController businessAddress;
  late final TextEditingController businessRegNumber;

  final stateProvinceFocusNode = FocusNode();
  final streetHouseFocusNode = FocusNode();
  final streetNameFocusNode = FocusNode();
  final buidingNameFocusNode = FocusNode();
  final townAreaFocusNode = FocusNode();
  final postalZipFocusNode = FocusNode();

  late final TextEditingController stateProvince;
  late final TextEditingController streetHouse;
  late final TextEditingController streetName;
  late final TextEditingController buidingName;
  late final TextEditingController townArea;
  late final TextEditingController postalZip;

  late final PhoneNumberController phoneNumberController;
  late final ImageFileController logoController;
  late final CategoriesController categoriesController;

  final ScrollController _scrollController = ScrollController();

  PhoneNumber? userNumber;
  File? userImage;

  final _formKey = GlobalKey<FormState>();

  List<Countries> countries = [];
  List<String> countryISO = [];

  List<dynamic> categoryList = [];
  List<String> categoryListText = [];

  List<int> selectedCatB = [];
  List<String> selectedCatToDisplay = [];
  List<int> currentselction = [];

  String countryISOCode = "";

  @override
  void initState() {
    super.initState();

    getCountryList();
    getCategories();

    businessName = TextEditingController();
    businessContactNumber = TextEditingController();
    businessType = TextEditingController();
    businessAddress = TextEditingController();
    businessRegNumber = TextEditingController();
    stateProvince = TextEditingController();
    streetHouse = TextEditingController();
    streetName = TextEditingController();
    buidingName = TextEditingController();
    townArea = TextEditingController();
    postalZip = TextEditingController();
    phoneNumberController = PhoneNumberController(null);

    logoController = ImageFileController(null);
    categoriesController = CategoriesController();
    if (widget.phoneNumber != null) {
      phoneNumberController.value = widget.phoneNumber!;
    }
  }

  @override
  void dispose() {
    businessName.dispose();
    businessContactNumber.dispose();
    businessType.dispose();
    businessAddress.dispose();
    businessRegNumber.dispose();
    stateProvince.dispose();
    streetHouse.dispose();
    streetName.dispose();
    buidingName.dispose();
    townArea.dispose();
    postalZip.dispose();

    phoneNumberController.dispose();
    logoController.dispose();
    categoriesController.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  Future getCountryList() async {
    try {
      final response = await context.read<UserRepository>().getCountries();
      setState(() {
        countries = response;
        for (var element in countries) {
          countryISO.add(element.iso2!);
        }
        countryISOCode = Country.parse(countryISO[0]).countryCode;
      });
    } catch (e) {
      await anErrorOccurredDialog(context, error: e.toString());
      context.popView();
    }
  }

  Future getCategories() async {
    try {
      final response =
          await context.read<ProductRepository>().getAllCategories();

      setState(() {
        categoryList = response;

        for (var element in categoryList) {
          categoryListText.add(element["category"]);
        }
      });
    } catch (e) {
      await anErrorOccurredDialog(context, error: e.toString());
      context.popView();
    }
  }

  void createBusinessProfile() async {
    context.unFocus();

    if (categoriesController.value.isEmpty) {
      context.snackBar(LocaleKeys.pleaseSelectAtLeastACateogory.tr());
    } else if (_formKey.currentState!.validate()) {
      try {
        final payload = {
          "business_type": businessType.text,
          "business_registration_number": businessRegNumber.text,
          "business_logo": logoController.value,
          "business_category": categoriesController.value,
          "business_name": businessName.text.titleCase,
          "business_contact_number": phoneNumberController.value.phoneNumber,
          "business_address": toBeginningOfSentenceCase(businessAddress.text)
        };

        context.read<LoadingCubit>().loading();
        final response = await context
            .read<UserRepository>()
            .createBusinessProfile(
                payload, widget.userEmail, widget.userPassword);
        context.read<LoadingCubit>().loaded();

        await successfulDialog(context,
            res: response.toString(),
            title: LocaleKeys.businessInformationUpdatedSuccessfully.tr());

        if (widget.fromLogin) {
          context.popView();
        } else {
          if (widget.isSME) {
            context.pushView(const Wellcome(), clearStack: true);
          } else {
            await context.pushView(PromoCode(
              isSME: widget.isSME,
            ));
            context.popView();
          }
        }
      } catch (e) {
        context.read<LoadingCubit>().loaded();
        anErrorOccurredDialog(context, error: e.toString().titleCase);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingCubit, LoadingState>(
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        return WillPopScope(
          onWillPop: () async => false,
          child: Stack(children: [
            Scaffold(
                backgroundColor: context.theme.canvasColor,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: context.theme.canvasColor,
                  elevation: 0,
                  title: const AppbarLogo(),
                  centerTitle: true,
                ),
                body: Form(
                    key: _formKey,
                    child: SafeArea(
                      child: Scrollbar(
                        controller: _scrollController,
                        child:
                            ListView(controller: _scrollController, children: [
                          20.h.height,
                          ScreenHeader(
                              subTitle: LocaleKeys
                                  .welcomeToTheKioskNetworkPleaseCompleteYourProfile
                                  .tr(),
                              title: LocaleKeys.businessInformation.tr()),
                          20.h.height,
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25.w),
                            child: Column(
                              children: [
                                _BusinessLogo(logoController),
                                20.h.height,
                                CustomInputField(
                                    textCapitalization:
                                        TextCapitalization.words,
                                    title: LocaleKeys.businessName.tr(),
                                    controller: businessName),
                                20.h.height,
                                CustomInputField(
                                    readOnly: true,
                                    keyboardType: TextInputType.none,
                                    title: LocaleKeys.businessType.tr(),
                                    onTap: () async {
                                      context.unFocus();
                                      final response =
                                          await businessCategoryPicker(context);
                                      if (response != null) {
                                        businessType.text = response;
                                      }
                                    },
                                    controller: businessType),
                                20.h.height,
                                _AddCategories(
                                  categoriesController,
                                  categoryListText,
                                  categoryList,
                                  selectedCatToDisplay: selectedCatToDisplay,
                                  currentselction: currentselction,
                                  selectedCatB: selectedCatB,
                                ),
                                20.h.height,
                                _InputPhoneNumber(countryISO,
                                    phoneNumberController, widget.phoneNumber),
                                20.h.height,

                                //TODO: refactor add address widget
                                CustomInputField(
                                    readOnly: true,
                                    showSurfix: false,
                                    keyboardType: TextInputType.none,
                                    title: LocaleKeys.businessAddress.tr(),
                                    onTap: () async {
                                      FocusScope.of(context).unfocus();
                                      addAddressInformation(context);
                                    },
                                    controller: businessAddress),
                                20.h.height,
                                CustomInputField(
                                    readOnly: false,
                                    showSurfix: false,
                                    keyboardType: TextInputType.text,
                                    title: LocaleKeys.businessRegistrationNumber
                                        .tr(),
                                    validator: (_) {
                                      return null;
                                    },
                                    controller: businessRegNumber),
                                20.h.height,
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: createBusinessProfile,
                                    child: Text(
                                      LocaleKeys.continuE.tr(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                25.h.height,
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ))),
            Visibility(
              child: const LoadingWidget(),
              visible: isLoading || countries.isEmpty || categoryList.isEmpty,
            ),
          ]),
        );
      },
    );
  }

  void addAddressInformation(BuildContext contex) async {
    final _formKeyAddress = GlobalKey<FormState>();

    return await showDialog(
        context: context,
        builder: (context) {
          return Builder(builder: (contextB) {
            List<Map<String, dynamic>> data = [
              {
                "LableText": LocaleKeys.enterStreetHouseFlatNumber.tr(),
                "NextNode": buidingNameFocusNode,
                "Controller": streetHouse,
              },
              {
                "LableText": LocaleKeys.buildingName.tr(),
                "NextNode": streetNameFocusNode,
                "Controller": buidingName,
                "Validate": false,
                "FocusNode": buidingNameFocusNode
              },
              {
                "LableText": LocaleKeys.enterStreetName.tr(),
                "NextNode": townAreaFocusNode,
                "Controller": streetName,
                "FocusNode": streetNameFocusNode
              },
              {
                "LableText": LocaleKeys.enterTownArea.tr(),
                "NextNode": streetHouseFocusNode,
                "Controller": townArea,
                "FocusNode": townAreaFocusNode
              },
              {
                "LableText": LocaleKeys.stateProvinces.tr(),
                "Controller": stateProvince,
                "FocusNode": streetHouseFocusNode
              },
            ];
            return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0.r))),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                titlePadding: EdgeInsets.only(top: 20.h),
                title: Container(
                    margin: EdgeInsets.symmetric(vertical: 10.h),
                    child: Text(LocaleKeys.addAddress.tr().toUpperCase(),
                        textAlign: TextAlign.center,
                        style: contex.theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold))),
                content: Form(
                  key: _formKeyAddress,
                  child: SingleChildScrollView(
                    child: Wrap(
                      children: [
                        for (var i in data)
                          AddAddressWidget(
                              lableText: i["LableText"],
                              nextNode: i["NextNode"],
                              validate: i["Validate"] ?? true,
                              focusNode: i["FocusNode"],
                              controller: i["Controller"]),
                        5.h.height,
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  return contextB.popView(value: false);
                                },
                                child: Text(
                                  LocaleKeys.cancel.tr(),
                                ),
                              ),
                              5.w.width,
                              ElevatedButton(
                                  onPressed: () {
                                    if (_formKeyAddress.currentState!
                                        .validate()) {
                                      businessAddress.text = streetHouse.text +
                                          ", " +
                                          (buidingName.text.isEmpty
                                              ? ""
                                              : buidingName.text + ", ") +
                                          streetName.text +
                                          ", " +
                                          townArea.text +
                                          ", " +
                                          stateProvince.text;
                                      contextB.popView();
                                    }
                                  },
                                  child: Text(
                                    LocaleKeys.continuE.tr(),
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ));
          });
        });
  }
}

class AddAddressWidget extends StatelessWidget {
  const AddAddressWidget({
    Key? key,
    required this.lableText,
    this.focusNode,
    required this.nextNode,
    this.validate = true,
    required this.controller,
  }) : super(key: key);

  final FocusNode? focusNode;
  final FocusNode? nextNode;
  final bool validate;
  final String lableText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: TextFormField(
        focusNode: focusNode,
        keyboardType: TextInputType.text,
        onEditingComplete: nextNode != null
            ? () {
                FocusScope.of(context).requestFocus(nextNode);
              }
            : null,
        controller: controller,
        validator: !validate
            ? null
            : (value) {
                if (value == null || value.isEmpty) {
                  return LocaleKeys.required.tr();
                }
                return null;
              },
        decoration: InputDecoration(
          labelText: lableText,
        ),
      ),
    );
  }
}

class CustomInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String title;
  final FocusNode? node;
  final FocusNode? nextFocusNode;
  final void Function()? onTap;
  final bool showSurfix;
  final TextCapitalization textCapitalization;

  final TextInputType? keyboardType;
  final bool readOnly;
  final String? Function(String?)? validator;

  const CustomInputField(
      {Key? key,
      required this.title,
      required this.controller,
      this.node,
      this.textCapitalization = TextCapitalization.none,
      this.showSurfix = true,
      this.onTap,
      this.validator,
      this.readOnly = false,
      this.keyboardType,
      this.nextFocusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(title, style: Theme.of(context).textTheme.titleSmall!),
        ),
        5.h.height,
        SizedBox(
          width: double.infinity,
          child: TextFormField(
            textCapitalization: textCapitalization,
            onTap: onTap,
            readOnly: readOnly,
            validator: validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.required.tr();
                  }
                  return null;
                },
            keyboardType: keyboardType ?? TextInputType.text,
            textAlignVertical: TextAlignVertical.center,
            controller: controller,
            focusNode: node,
            onEditingComplete: nextFocusNode != null
                ? () {
                    FocusScope.of(context).requestFocus(nextFocusNode);
                  }
                : null,
            decoration: InputDecoration(
                errorMaxLines: 2,
                labelText: "",
                suffixIcon: showSurfix
                    ? onTap != null
                        ? IconButton(
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                            ),
                            onPressed: onTap,
                          )
                        : null
                    : null),
          ),
        ),
      ],
    );
  }
}

class _InputPhoneNumber extends StatelessWidget {
  const _InputPhoneNumber(
      this.countryISO, this.phoneNumberController, this.initialPhoneNumber);
  final PhoneNumberController? phoneNumberController;
  final PhoneNumber? initialPhoneNumber;
  final List<String> countryISO;

  @override
  Widget build(BuildContext context) {
    void onInputChanged(PhoneNumber phoneNumber) {
      phoneNumberController!.value = phoneNumber;
    }

    return Visibility(
      visible: countryISO.isNotEmpty,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(LocaleKeys.businessContactNumber.tr(),
                style: context.theme.textTheme.titleSmall!),
          ),
          5.h.height,
          PhoneNumberInput(
            initialPhoneNumber: initialPhoneNumber,
            countries: countryISO,
            onInputChanged: onInputChanged,
          ),
        ],
      ),
    );
  }
}

class _BusinessLogo extends StatelessWidget {
  const _BusinessLogo(this.controller);
  final ImageFileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(LocaleKeys.businessLogo.tr(),
              style: Theme.of(context).textTheme.titleSmall),
        ),
        5.h.height,
        Row(
          children: [
            GestureDetector(
                onTap: () async {
                  final file = await imagePicker(context);
                  if (file != null) {
                    controller.value = file;
                  }
                },
                child: ValueListenableBuilder(
                    valueListenable: controller,
                    builder: (_, File? value, child) {
                      if (value == null) {
                        return Container(
                          alignment: Alignment.bottomRight,
                          padding: EdgeInsets.only(bottom: 5.h, right: 5.w),
                          width: 90.w,
                          height: 90.w,
                          decoration: BoxDecoration(
                              image: const DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                    "assets/images/background.png",
                                  )),
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20.r)),
                          child: Image.asset(
                            "assets/images/addIcon.png",
                            height: 30.h,
                            width: 30.w,
                          ),
                        );
                      }
                      return Row(
                        children: [
                          Card(
                            color:
                                context.theme.colorScheme.primary.lighten(97),
                            child: Container(
                                padding: EdgeInsets.all(3.r),
                                alignment: Alignment.center,
                                width: 90.w,
                                height: 90.w,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20.r)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0.r),
                                  child: Image.file(value, fit: BoxFit.contain),
                                )),
                          ),
                          Card(
                            color:
                                context.theme.colorScheme.primary.lighten(40),
                            child: IconButton(
                                onPressed: () {
                                  controller.clear();
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                )),
                          )
                        ],
                      );
                    })),
            Expanded(
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Text(LocaleKeys.uploadYourBusinessLogo.tr(),
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodySmall!))),
          ],
        ),
      ],
    );
  }
}

class _AddCategories extends StatelessWidget {
  const _AddCategories(
      this.controller, this.categoryListText, this.categoryList,
      {required this.currentselction,
      required this.selectedCatB,
      required this.selectedCatToDisplay});

  final CategoriesController controller;
  final List<String> categoryListText;
  final List<dynamic> categoryList;
  final List<int> selectedCatB;
  final List<String> selectedCatToDisplay;
  final List<int> currentselction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(LocaleKeys.inventoryCategory.tr(),
              style: Theme.of(context).textTheme.titleSmall!),
        ),
        5.h.height,
        SizedBox(
          child: Container(
            width: double.infinity,
            alignment: Alignment.topLeft,
            child: TextButton(
                onPressed: () {
                  context.unFocus();
                  addCategories(
                    context,
                    selectedButtons: currentselction,
                    buttons: categoryListText,
                    onSelected: (index, selected) {
                      if (selected) {
                        selectedCatToDisplay
                            .add(categoryList[index]["category"]);
                        currentselction.add(index);
                        controller.add(categoryList[index]["id"]);
                      } else {
                        currentselction.remove(index);
                        selectedCatB.remove(categoryList[index]["id"]);
                        selectedCatToDisplay
                            .remove(categoryList[index]["category"]);
                        controller.remove(categoryList[index]["id"]);
                      }
                    },
                  );
                },
                child: Text(LocaleKeys.addCategories.tr(),
                    textAlign: TextAlign.left)),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 35.h,
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, List<int> value, child) {
              return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedCatToDisplay.length,
                  itemBuilder: (BuildContext context, int index) {
                    final data = selectedCatToDisplay[index];

                    return Padding(
                        padding: EdgeInsets.only(right: 1.r),
                        child: Chip(
                          label: Text(
                            Util.getLocalizedCategory(data),
                          ),
                          onDeleted: () {
                            selectedCatToDisplay.removeAt(index);
                            currentselction.removeAt(index);
                            controller.removeAtIndex(index);
                          },
                        ));
                  });
            },
          ),
        ),
      ],
    );
  }
}
