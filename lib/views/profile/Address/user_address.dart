import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/navigation_extention.dart';
import 'package:kiosk/extensions/theme_extention.dart';
import 'package:kiosk/extensions/unfocus_extention.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/dialogs/error_alert_dialog.dart';
import 'package:kiosk/widgets/headers/screen_header.dart';
import 'package:kiosk/widgets/loader/loading_widget.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class EditUserAddress extends StatefulWidget {
  final Map? currentAddress;
  const EditUserAddress({
    Key? key,
    this.currentAddress,
  }) : super(key: key);

  @override
  State<EditUserAddress> createState() => _EditUserAddressState();
}

class _EditUserAddressState extends State<EditUserAddress> {
  late String? _addressType = "Permanent Address";

  final _formkey = GlobalKey<FormState>();
  final streetHouseFN = FocusNode();
  final streetNameFN = FocusNode();
  final townAreaFN = FocusNode();
  final postalZipFN = FocusNode();

  late final TextEditingController stateProvince;
  late final TextEditingController streetHouse;
  late final TextEditingController streetName;
  late final TextEditingController buidingName;
  late final TextEditingController townArea;
  late final TextEditingController postalZip;

  @override
  void initState() {
    stateProvince = TextEditingController();
    streetHouse = TextEditingController();
    streetName = TextEditingController();
    buidingName = TextEditingController();
    townArea = TextEditingController();
    postalZip = TextEditingController();

    if (widget.currentAddress != null) {
      stateProvince.text = widget.currentAddress!['state'];
      streetHouse.text = widget.currentAddress!['street_or_flat_number'];
      streetName.text = widget.currentAddress!['street_name'];
      buidingName.text = widget.currentAddress!['building_name'];
      townArea.text = widget.currentAddress!['city'];
      postalZip.text = widget.currentAddress!['zip_post_code'];
      _addressType = widget.currentAddress!['type'] == "current"
          ? "Current Address"
          : "Permanent Address";
    }
    super.initState();
  }

  @override
  void dispose() {
    stateProvince.dispose();
    streetHouse.dispose();
    streetName.dispose();
    buidingName.dispose();
    townArea.dispose();
    postalZip.dispose();
    super.dispose();
  }

  void onPressed() async {
    context.unFocus();
    if (_formkey.currentState!.validate()) {
      try {
        if (widget.currentAddress == null) {
          //creating a new address
          context.read<LoadingCubit>().loading();

          final response = await context
              .read<UserRepository>()
              .createUserAddress(
                  type: _addressType!,
                  flatNumber: streetHouse.text,
                  streetName: streetName.text,
                  buildingName: buidingName.text,
                  state: stateProvince.text,
                  city: townArea.text,
                  zipPostCode: postalZip.text);
          context.read<LoadingCubit>().loaded();
          context.read<UserCubit>().getUserDetails();
          await successfulDialog(context, res: response);
          context.popView();
        } else {
          //updating address
          context.read<LoadingCubit>().loading(message: "Updating Address");

          final response = await context
              .read<UserRepository>()
              .createUserAddress(
                  type: _addressType!,
                  id: widget.currentAddress!["id"],
                  flatNumber: streetHouse.text,
                  streetName: streetName.text,
                  buildingName: buidingName.text,
                  state: stateProvince.text,
                  city: townArea.text,
                  zipPostCode: postalZip.text);
          context.read<LoadingCubit>().loaded();
          context.read<UserCubit>().getUserDetails();
          await successfulDialog(context, res: response);
          context.popView();
        }
      } catch (e) {
        context.read<LoadingCubit>().loaded();
        anErrorOccurredDialog(context, error: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingCubit, LoadingState>(
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Stack(children: [
            Scaffold(
              backgroundColor: context.theme.canvasColor,
              appBar: AppBar(
                backgroundColor: context.theme.canvasColor,
                foregroundColor: context.theme.colorScheme.primary,
                centerTitle: false,
                elevation: 0,
              ),
              body: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScreenHeader(
                                subTitle: LocaleKeys
                                    .youCanChooseToEditEitherYourPermanentOrCurrentAddressBySelectingTheAppropriateAddressType
                                    .tr(),
                                title: LocaleKeys.editAddress.tr()),
                            20.h.height,
                            _buildDropDownButton(),
                            20.h.height,
                            CustomInput(
                              controller: streetHouse,
                              nextFocusNode: streetNameFN,
                              title: LocaleKeys.enterStreetHouseFlatNumber.tr(),
                            ),
                            20.h.height,
                            CustomInput(
                              controller: streetName,
                              nextFocusNode: townAreaFN,
                              focusNode: streetNameFN,
                              title: LocaleKeys.enterStreetName.tr(),
                            ),
                            20.h.height,
                            CustomInput(
                              controller: townArea,
                              nextFocusNode: streetHouseFN,
                              focusNode: townAreaFN,
                              title: LocaleKeys.enterTownArea.tr(),
                            ),
                            20.h.height,
                            CustomInput(
                              controller: stateProvince,
                              nextFocusNode: postalZipFN,
                              focusNode: streetHouseFN,
                              title: LocaleKeys.stateProvinces.tr(),
                            ),
                            20.h.height,
                            CustomInput(
                              controller: postalZip,
                              focusNode: postalZipFN,
                              title: LocaleKeys.enterPostalCodeZipCode.tr(),
                            ),
                            20.h.height,
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => onPressed(),
                          child: Text(
                            LocaleKeys.continuE.tr(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              child: const LoadingWidget(),
              visible: isLoading,
            )
          ]),
        );
      },
    );
  }

  Widget _buildDropDownButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Address Type',
        ),
        value: _addressType,
        onChanged: (value) {
          setState(() {
            _addressType = value;
          });
        },
        items: <String>['Current Address', 'Permanent Address']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return LocaleKeys.required.tr();
          }
          return null;
        },
      ),
    );
  }
}

class CustomInput extends StatelessWidget {
  final String title;
  final FocusNode? focusNode;
  final TextEditingController controller;
  final FocusNode? nextFocusNode;
  const CustomInput(
      {Key? key,
      required this.title,
      required this.controller,
      this.focusNode,
      this.nextFocusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: AutoSizeText(title,
                style: Theme.of(context).textTheme.titleSmall!),
          ),
          5.h.height,
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              onEditingComplete: nextFocusNode == null
                  ? () {
                      FocusScope.of(context).requestFocus(nextFocusNode);
                    }
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocaleKeys.required.tr();
                }
                return null;
              },
              focusNode: focusNode,
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}
