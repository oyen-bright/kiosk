import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:kiosk/constants/constant_color.dart';
import 'package:kiosk/controllers/bool_controller.dart';
import 'package:kiosk/controllers/phone_number_controller.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/countries.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/create_account/create_business_info/register_business_infomation.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

import 'components/country_state_picker.dart';
import 'components/government_organization.dart';
import 'components/input_field.dart';

class CreateAccount extends StatefulWidget {
  final Map<String, dynamic> userData;

  const CreateAccount({Key? key, required this.userData}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  Country? country;

  List<Countries> countries = [];
  List<Map> countryState = [];
  List<String> countryISO = [];
  List<String> governmentOrganization = [];
  final _formkey = GlobalKey<FormState>();
  final lastNameFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  late final TextEditingController passwordTextController;
  late final TextEditingController countryStateTextController;
  late final TextEditingController countryTextController;
  late final TextEditingController confirmPasswordTextController;
  late final TextEditingController firstNameTextController;
  late final TextEditingController lastNameTextController;
  late final TextEditingController genderTextController;
  late final TextEditingController birthdayTextController;
  late final MyBoolController checkBoxController;
  late final PhoneNumberController phoneNumberController;
  late final PhoneNumberController phoneNumberController2;
  late final TextEditingController governmentOrganizationController;
  late final TextEditingController governmentOrganizationController2;
  late final TextEditingController governmentOrganizationController3;

  late final ScrollController _scrollController;

  @override
  void initState() {
    getCountryList();
    _scrollController = ScrollController();
    checkBoxController = MyBoolController(false);
    phoneNumberController = PhoneNumberController(null);
    phoneNumberController2 = PhoneNumberController(null);
    passwordTextController = TextEditingController();
    countryTextController = TextEditingController();
    confirmPasswordTextController = TextEditingController();
    firstNameTextController = TextEditingController();
    lastNameTextController = TextEditingController();
    genderTextController = TextEditingController();
    birthdayTextController = TextEditingController();
    governmentOrganizationController = TextEditingController();
    governmentOrganizationController2 = TextEditingController();
    governmentOrganizationController3 = TextEditingController();
    countryStateTextController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    checkBoxController.dispose();
    passwordTextController.dispose();
    countryTextController.dispose();
    confirmPasswordTextController.dispose();
    firstNameTextController.dispose();
    lastNameTextController.dispose();
    genderTextController.dispose();
    birthdayTextController.dispose();
    countryStateTextController.dispose();
    governmentOrganizationController.dispose();
    governmentOrganizationController2.dispose();
    governmentOrganizationController3.dispose();
    phoneNumberController.dispose();
    phoneNumberController2.dispose();

    super.dispose();
  }

  Future getCountryList() async {
    try {
      final response = await Future.wait([
        context.read<UserRepository>().getCountries(),
        context.read<UserRepository>().getGovernmentList(),
      ]);

      setState(() {
        countries = response[0] as List<Countries>;
        governmentOrganization = response[1] as List<String>;
        for (var element in countries) {
          countryISO.add(element.iso2!);
        }
        country = Country.parse(countryISO[0]);
      });
    } catch (e) {
      await anErrorOccurredDialog(context, error: e.toString());
      context.popView();
    }
  }

  int? getCountryIdByIOS({required String iOS}) {
    return (countries.where((e) => e.iso2 == iOS).first).id;
  }

  int? getStateIdByProvince({required String province}) {
    if (province.isEmpty) {
      return null;
    }
    return (countryState.where((e) => e['province'] == province).first)['id'];
  }

  Future getCountryStates({required String id}) async {
    try {
      context.read<LoadingCubit>().loading();

      final response =
          await context.read<UserRepository>().getCountryStates(id);
      context.read<LoadingCubit>().loaded();
      setState(() {
        countryState = response;
      });
    } catch (e) {
      context.read<LoadingCubit>().loaded();
      await anErrorOccurredDialog(context, error: e.toString());
    }
  }

  Future<void> createAccount() async {
    context.unFocus();

    final _isChecked = checkBoxController.value;

    if (_formkey.currentState!.validate()) {
      if (_isChecked) {
        try {
          context.read<LoadingCubit>().loading();
          await context.read<UserRepository>().createAccount(
              stateProvince: getStateIdByProvince(
                  province: countryStateTextController.text),
              governmentOrganizationName:
                  governmentOrganizationController3.text == "Yes"
                      ? "NASME Lagos"
                      : governmentOrganizationController.text,
              firstName: firstNameTextController.text,
              lastName: lastNameTextController.text,
              email: widget.userData["Email"],
              gender: genderTextController.text,
              dob: birthdayTextController.text,
              phoneNumber: phoneNumberController2.value.parseNumber(),
              countryISO2: countryTextController.text,
              password: confirmPasswordTextController.text);

          context.read<LoadingCubit>().loaded();
          await successfulDialog(
            context,
            color: kioskYellow,
            res: LocaleKeys.accountCreatedSuccessfully.tr(),
          );

          await context.pushView(RegisterBusinessInformation(
            isSME: governmentOrganizationController3.text == "Yes" ||
                (governmentOrganizationController.text.isNotEmpty),
            userPassword: passwordTextController.text,
            phoneNumber: phoneNumberController.value,
            userEmail: widget.userData["Email"],
          ));
        } catch (e) {
          context.read<LoadingCubit>().loaded();
          await anErrorOccurredDialog(context, error: e.toString());
        }
      } else {
        context.snackBar(LocaleKeys.pleaseAgreeToOurTermsAndConditions.tr());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingCubit, LoadingState>(builder: (context, state) {
      final isLoading = state.status == Status.loading;

      return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Stack(children: [
            Scaffold(
              backgroundColor: context.theme.canvasColor,
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: context.theme.canvasColor,
                  elevation: 0,
                  centerTitle: false,
                  title: const AppbarLogo()),
              body: Scrollbar(
                controller: _scrollController,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: Form(
                    key: _formkey,
                    child: ListView(
                        controller: _scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        children: [
                          0.2.sh.height,
                          InputField(
                            hintText: LocaleKeys.firstName.tr(),
                            textCapitalization: TextCapitalization.words,
                            controller: firstNameTextController,
                            title: LocaleKeys.firstName.tr(),
                            nextFocusNode: lastNameFocusNode,
                          ),
                          20.h.height,
                          InputField(
                            textCapitalization: TextCapitalization.words,
                            controller: lastNameTextController,
                            title: LocaleKeys.lastName.tr(),
                            hintText: LocaleKeys.lastName.tr(),
                            node: lastNameFocusNode,
                            nextFocusNode: null,
                          ),
                          20.h.height,
                          _SelectCountry(
                            onSelect: (c) {
                              if (c.countryCode != "NG") {
                                governmentOrganizationController.clear();
                                governmentOrganizationController2.clear();
                                governmentOrganizationController3.clear();
                                countryStateTextController.clear();
                                countryState.clear();
                              }
                              setState(() {});
                            },
                            phoneNumberController: phoneNumberController,
                            controller: countryTextController,
                            countryISO: countryISO,
                          ),
                          if (countryTextController.text == "NG") ...[
                            20.h.height,
                            InputField(
                              controller: countryStateTextController,
                              title: LocaleKeys.StateProvince.tr(),
                              hintText: LocaleKeys.StateProvince.tr(),
                              keyboardType: TextInputType.none,
                              nextFocusNode: null,
                              readOnly: true,
                              onTap: () async {
                                context.unFocus();

                                try {
                                  if (countryState.isEmpty) {
                                    await getCountryStates(
                                        id: getCountryIdByIOS(
                                                iOS: countryTextController.text)
                                            .toString());
                                  }
                                  final response = await countryStatePicker(
                                      context, countryState);
                                  if (response != null) {
                                    countryStateTextController.text =
                                        response['province'];
                                    setState(() {});
                                  }
                                } catch (_) {}
                              },
                            ),
                          ],
                          20.h.height,
                          InputField(
                            controller: genderTextController,
                            title: LocaleKeys.gender.tr(),
                            hintText: LocaleKeys.gender.tr(),
                            keyboardType: TextInputType.none,
                            nextFocusNode: null,
                            readOnly: true,
                            onTap: () async {
                              context.unFocus();
                              final response = await genderPicker(context);
                              if (response != null) {
                                genderTextController.text = response;
                              }
                            },
                          ),
                          20.h.height,
                          InputField(
                              controller: birthdayTextController,
                              keyboardType: TextInputType.none,
                              title: LocaleKeys.dateOfBirth.tr(),
                              hintText: LocaleKeys.dateOfBirth.tr(),
                              nextFocusNode: null,
                              readOnly: true,
                              onTap: () async {
                                context.unFocus();
                                final response = await datePicker(context);
                                if (response != null) {
                                  birthdayTextController.text =
                                      response.toString().substring(0, 10);
                                }
                              }),
                          20.h.height,
                          _InputPhoneNumber(countryISO, phoneNumberController,
                              phoneNumberController2),
                          20.h.height,
                          _PasswordInput(
                            controller: passwordTextController,
                            nextFocusNode: confirmPasswordFocusNode,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LocaleKeys.required.tr();
                              } else if (value.length < 8) {
                                return LocaleKeys.mustBeatLeast8Charactersuse
                                    .tr();
                              }
                              return null;
                            },
                            title: LocaleKeys.password.tr(),
                          ),
                          20.h.height,
                          _PasswordInput(
                            controller: confirmPasswordTextController,
                            focusNode: confirmPasswordFocusNode,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LocaleKeys.required.tr();
                              } else if (value.length < 8 ||
                                  passwordTextController.text != value) {
                                return LocaleKeys.passwordDoesNotMatch.tr();
                              }

                              return null;
                            },
                            title: LocaleKeys.confirmPassword.tr(),
                          ),
                          if (governmentOrganization.isNotEmpty &&
                              countryTextController.text == "NG") ...[
                            20.h.height,
                            GovernmentOrganization(
                              countryStateTextController:
                                  countryStateTextController,
                              affiliatedControllerNasme:
                                  governmentOrganizationController3,
                              affiliatedController:
                                  governmentOrganizationController2,
                              controller: governmentOrganizationController,
                              organization: governmentOrganization,
                            ),
                          ],
                          15.h.height,
                          _TermsAndConditions(
                            controller: checkBoxController,
                          ),
                          15.h.height,
                          ElevatedButton(
                            onPressed: () => createAccount(),
                            child: Text(
                              LocaleKeys.continuE.tr(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          25.h.height,
                        ]),
                  ),
                ),
              ),
            ),
            Visibility(
              child: const LoadingWidget(),
              visible: isLoading || countries.isEmpty,
            ),
          ]));
    });
  }
}

class _SelectCountry extends StatefulWidget {
  final List<String> countryISO;
  final TextEditingController controller;
  final PhoneNumberController phoneNumberController;
  final void Function(Country) onSelect;

  const _SelectCountry({
    Key? key,
    required this.phoneNumberController,
    required this.controller,
    required this.countryISO,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<_SelectCountry> createState() => _SelectCountryState();
}

class _SelectCountryState extends State<_SelectCountry> {
  Country? country;

  late final TextEditingController countryName;

  @override
  void initState() {
    countryName = TextEditingController();

    if (widget.controller.text.isNotEmpty) {
      country = Country.parse(widget.controller.text);
      countryName.text = country?.name ?? "";
    }
    super.initState();
  }

  @override
  void dispose() {
    countryName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void ontap() {
      context.unFocus();

      countryPicker(context, countryFilter: widget.countryISO,
          onSelect: (Country c) {
        widget.phoneNumberController.value =
            PhoneNumber(isoCode: c.countryCode);
        widget.onSelect(c);

        setState(() {
          country = c;
          countryName.text = c.displayNameNoCountryCode;
          widget.controller.text = c.countryCode;
        });
      });
    }

    return Visibility(
      visible: widget.countryISO.isNotEmpty,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(LocaleKeys.countryRegion.tr(),
                style: context.theme.textTheme.titleSmall!),
          ),
          5.h.height,
          TextFormField(
            onTap: ontap,
            readOnly: true,
            controller: countryName,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return LocaleKeys.required.tr();
              }
              return null;
            },
            decoration: InputDecoration(
                hintText: LocaleKeys.country.tr(),
                prefixIcon: country != null
                    ? FittedBox(
                        child: Padding(
                        padding: EdgeInsets.all(2.r),
                        child: Text(country!.flagEmoji),
                      ))
                    : null,
                suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_drop_down), onPressed: ontap)),
          ),
        ],
      ),
    );
  }
}

class _InputPhoneNumber extends StatelessWidget {
  const _InputPhoneNumber(
      this.countryISO, this.phoneNumberController, this.phoneNumberController2);
  final PhoneNumberController phoneNumberController;
  final PhoneNumberController phoneNumberController2;
  final List<String> countryISO;

  @override
  Widget build(BuildContext context) {
    void onInputChanged(PhoneNumber phoneNumber) {
      phoneNumberController2.value = phoneNumber;
    }

    return Visibility(
      visible: countryISO.isNotEmpty,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(LocaleKeys.phoneNumber.tr(),
                style: context.theme.textTheme.titleSmall!),
          ),
          5.h.height,
          5.h.height,
          ValueListenableBuilder(
            builder: (context, PhoneNumber value, child) {
              return PhoneNumberInput(
                countries: countryISO,
                initialPhoneNumber: value,
                onInputChanged: onInputChanged,
              );
            },
            valueListenable: phoneNumberController,
          ),
        ],
      ),
    );
  }
}

class _PasswordInput extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String? Function(String?)? validator;

  const _PasswordInput(
      {Key? key,
      required this.title,
      this.focusNode,
      this.nextFocusNode,
      required this.controller,
      required this.validator})
      : super(key: key);

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(widget.title, style: context.theme.textTheme.titleSmall!),
        ),
        5.h.height,
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          child: TextFormField(
            textAlignVertical: TextAlignVertical.center,
            controller: widget.controller,
            validator: widget.validator,
            obscureText: obscureText,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.visiblePassword,
            onEditingComplete: widget.nextFocusNode != null
                ? () {
                    FocusScope.of(context).requestFocus(widget.nextFocusNode);
                  }
                : null,
            decoration: InputDecoration(
              hintText: widget.title,
              errorMaxLines: 2,
              suffixIcon: IconButton(
                icon: Icon(
                    !obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey),
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class _TermsAndConditions extends StatelessWidget {
  const _TermsAndConditions({required this.controller});
  final MyBoolController controller;
  @override
  Widget build(BuildContext context) {
    void ontap() async {
      if (controller.value == true) {
        // setState(() {
        controller.value = false;
        // });
      } else {
        final response = await getTermsCondition(context);
        if (response != null) {
          // setState(() {
          controller.value = true;
          // });
        }
      }
    }

    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 35.h),
        child: GestureDetector(
          onTap: ontap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocaleKeys.byCreatingAnAccountYouAccept.tr(),
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodyMedium!),
              10.h.height,
              SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24.w,
                      width: 24.w,
                      child: ValueListenableBuilder(
                          valueListenable: controller,
                          builder: (_, bool value, c) {
                            return Checkbox(
                                value: value,
                                onChanged: (bool? value) => ontap());
                          }),
                    ),
                    Text(
                      LocaleKeys.endUserTermsAndConditions.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle()
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
