import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:kiosk/controllers/.controllers.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/countries.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/email_validation.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class WorkersCreateAccount extends StatefulWidget {
  const WorkersCreateAccount({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  State<WorkersCreateAccount> createState() => _WorkersCreateAccountState();
}

class _WorkersCreateAccountState extends State<WorkersCreateAccount> {
  late final TextEditingController _firstNameTextEditingController;
  late final TextEditingController _lastNameTextEditingController;
  late final TextEditingController _genderTextEditingController;
  late final TextEditingController _passwordTextEditingController;
  late final TextEditingController _contactTextEditingController;
  late final TextEditingController _emailTextEditingController;
  late final TextEditingController _contryTextEditingController;
  late final PhoneNumberController phoneNumberController;

  late final FocusNode firstNameFocusNode;
  late final FocusNode lastNameFocusNode;
  late final FocusNode emailFocusNode;
  late final FocusNode passwordFocusNode;
  late final FocusNode contactFocusNode;

  final _formKey = GlobalKey<FormState>();

  List<Countries> countries = [];

  Future getCountryList() async {
    try {
      final response = await context.read<UserRepository>().getCountries();
      setState(() {
        countries = response;
      });
    } catch (e) {
      await anErrorOccurredDialog(context, error: e.toString());
      context.popView();
    }
  }

  @override
  void initState() {
    getCountryList();

    firstNameFocusNode = FocusNode();
    lastNameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    contactFocusNode = FocusNode();

    _genderTextEditingController = TextEditingController();
    _firstNameTextEditingController = TextEditingController();
    _lastNameTextEditingController = TextEditingController();
    _passwordTextEditingController = TextEditingController();
    _contactTextEditingController = TextEditingController();
    _emailTextEditingController = TextEditingController();
    _contryTextEditingController = TextEditingController();

    phoneNumberController = PhoneNumberController(null);

    _emailTextEditingController.text = widget.email;

    super.initState();
  }

  @override
  void dispose() {
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    contactFocusNode.dispose();

    _genderTextEditingController.dispose();
    _firstNameTextEditingController.dispose();
    _lastNameTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    _contactTextEditingController.dispose();
    _emailTextEditingController.dispose();
    _contryTextEditingController.dispose();

    super.dispose();
  }

  Future<void> onContinue() async {
    context.unFocus();

    if (_formKey.currentState!.validate()) {
      try {
        context.read<LoadingCubit>().loading();
        final response = await context.read<UserRepository>().createWorker(
            countryISO2: _contryTextEditingController.text,
            firstName: _firstNameTextEditingController.text,
            lastName: _lastNameTextEditingController.text,
            password: _passwordTextEditingController.text,
            email: _emailTextEditingController.text,
            contactNumber: phoneNumberController.value.parseNumber(),
            gender: _genderTextEditingController.text);
        context.read<LoadingCubit>().loaded();
        await successfulDialog(context, res: response.titleCase);
        context.popView(count: 2);
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
          onWillPop: () async => !isLoading,
          child: Stack(alignment: Alignment.topCenter, children: [
            Scaffold(
                appBar: customAppBar(context,
                    title: LocaleKeys.myWorkers.tr(),
                    showBackArrow: true,
                    showNewsAndPromo: false,
                    showNotifications: false,
                    showSubtitle: false),
                body: BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                    if (countries.isEmpty) {
                      return const LoadingWidget();
                    }

                    final usersCountryId = context
                            .read<UserCubit>()
                            .state
                            .currentUser
                            ?.countryOfResidences ??
                        1;
                    final getDefaultContry = countries
                        .where((element) => element.id == usersCountryId)
                        .toList()[0];
                    phoneNumberController.value =
                        PhoneNumber(isoCode: getDefaultContry.iso2);

                    return ListView(children: [
                      Form(
                        key: _formKey,
                        child: CustomContainer(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                                horizontal: 22.w, vertical: 10.h),
                            padding: EdgeInsets.all(16.r),
                            child: Column(children: [
                              ContainerHeader(
                                  title: LocaleKeys.createWorkerAccount.tr(),
                                  subTitle: LocaleKeys
                                      .whenAddingANewWorkerYouWillNeedToInputTheirEmailAddressForVerificationIfTheWorkerIsAlreadyOnOurPlatformYouCanSimplyConfirmTheirDetailsAndProceedHoweverIfTheWorkerIsNewToOurPlatformWeWillSendAnOtpToTheirEmailForVerificationBeforeTheyCanBeAddedAsANewWorker
                                      .tr()),
                              _InputLable(lable: LocaleKeys.firstName.tr()),
                              _InputFormField(
                                  focusNode: firstNameFocusNode,
                                  nextocusNode: lastNameFocusNode,
                                  controller: _firstNameTextEditingController),
                              10.h.height,
                              _InputLable(lable: LocaleKeys.lastName.tr()),
                              _InputFormField(
                                  focusNode: lastNameFocusNode,
                                  nextocusNode: contactFocusNode,
                                  controller: _lastNameTextEditingController),
                              10.h.height,
                              _InputLable(lable: LocaleKeys.email.tr()),
                              _EmailTextFormField(
                                  focusNode: emailFocusNode,
                                  nextocusNode: contactFocusNode,
                                  controller: _emailTextEditingController),
                              10.h.height,
                              _InputLable(lable: LocaleKeys.contactNumber.tr()),
                              _InputPhoneNumber(
                                  countries.map((e) => e.iso2!).toList(),
                                  phoneNumberController,
                                  contactFocusNode,
                                  passwordFocusNode),
                              10.h.height,
                              _InputLable(lable: LocaleKeys.password.tr()),
                              _PasswordFormField(
                                  focusNode: passwordFocusNode,
                                  controller: _passwordTextEditingController),
                              10.h.height,
                              _InputLable(lable: LocaleKeys.country.tr()),
                              _CountryDropdownField(
                                  countriesList: countries,
                                  controller: _contryTextEditingController),
                              10.h.height,
                              _InputLable(lable: LocaleKeys.gender.tr()),
                              _GenderDropdownField(
                                  controller: _genderTextEditingController),
                              10.h.height,
                            ])),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onContinue,
                          child: Text(
                            LocaleKeys.continuE.tr(),
                          ),
                        ),
                      )
                    ]);
                  },
                )),
            Visibility(
              child: const LoadingWidget(),
              visible: isLoading,
            ),
          ]),
        );
      },
    );
  }
}

class _InputLable extends StatelessWidget {
  const _InputLable({
    Key? key,
    required this.lable,
  }) : super(key: key);
  final String lable;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Text(lable, style: context.theme.textTheme.bodySmall!));
  }
}

class _GenderDropdownField extends StatefulWidget {
  final TextEditingController? controller;

  const _GenderDropdownField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  _GenderDropdownFieldState createState() => _GenderDropdownFieldState();
}

class _GenderDropdownFieldState extends State<_GenderDropdownField> {
  String? _selectedGender;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });

        widget.controller?.text = value ?? '';
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a gender';
        }
        return null;
      },
      items: const [
        DropdownMenuItem<String>(
          value: 'male',
          child: Text('Male'),
        ),
        DropdownMenuItem<String>(
          value: 'female',
          child: Text('Female'),
        ),
      ],
    );
  }
}

class _CountryDropdownField extends StatefulWidget {
  final List<Countries> countriesList;
  final TextEditingController controller;

  const _CountryDropdownField({
    Key? key,
    required this.countriesList,
    required this.controller,
  }) : super(key: key);

  @override
  _CountryDropdownFieldState createState() => _CountryDropdownFieldState();
}

class _CountryDropdownFieldState extends State<_CountryDropdownField> {
  Countries? _selectedCountry;

  @override
  void initState() {
    final defaultContry =
        context.read<UserCubit>().state.currentUser?.countryOfResidences ?? 0;
    _selectedCountry = widget.countriesList
        .where((element) => element.id == defaultContry)
        .first;
    widget.controller.text = _selectedCountry!.iso2!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Countries>(
      value: _selectedCountry,
      onChanged: (Countries? newValue) {
        setState(() {
          _selectedCountry = newValue;
          widget.controller.text = _selectedCountry!.iso2!;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a country';
        }
        return null;
      },
      items: widget.countriesList
          .map<DropdownMenuItem<Countries>>(
            (Countries country) => DropdownMenuItem<Countries>(
              value: country,
              child: Text(country.name!),
            ),
          )
          .toList(),
      decoration: const InputDecoration(),
    );
  }
}

class _PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _PasswordFormField({
    Key? key,
    required this.controller,
    required this.focusNode,
  }) : super(key: key);

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<_PasswordFormField> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: widget.focusNode,
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: _toggleObscureText,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters long';
        }
        return null;
      },
    );
  }
}

class _InputFormField extends StatelessWidget {
  final TextEditingController controller;

  const _InputFormField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.nextocusNode,
  }) : super(key: key);
  final FocusNode focusNode;
  final FocusNode nextocusNode;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: TextCapitalization.words,
      focusNode: focusNode,
      onEditingComplete: () => nextocusNode.requestFocus(),
      controller: controller,
      validator: (value) {
        if (value!.isEmpty) {
          return LocaleKeys.required.tr();
        }

        return null;
      },
      keyboardType: TextInputType.text,
    );
  }
}

class _InputPhoneNumber extends StatelessWidget {
  const _InputPhoneNumber(this.countryISO, this.phoneNumberController,
      this.focusNode, this.nextFocusNode);
  final PhoneNumberController phoneNumberController;
  final List<String> countryISO;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;

  @override
  Widget build(BuildContext context) {
    void onInputChanged(PhoneNumber phoneNumber) {
      phoneNumberController.value = phoneNumber;
    }

    return Visibility(
      visible: countryISO.isNotEmpty,
      child: ValueListenableBuilder(
        builder: (context, PhoneNumber value, child) {
          return PhoneNumberInput(
            focusNode: focusNode,
            onFieldSubmitted: nextFocusNode != null
                ? (p0) {
                    FocusScope.of(context).requestFocus(nextFocusNode);
                  }
                : null,
            countries: countryISO,
            initialPhoneNumber: value,
            onInputChanged: onInputChanged,
          );
        },
        valueListenable: phoneNumberController,
      ),
    );
  }
}

class _EmailTextFormField extends StatelessWidget {
  const _EmailTextFormField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.nextocusNode,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextocusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: false,
      onEditingComplete: () => nextocusNode.requestFocus(),
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: 'Enter workers email',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return LocaleKeys.required.tr();
        }
        if (!isValidEmail(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }
}
