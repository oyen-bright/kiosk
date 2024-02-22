// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:currency_picker/currency_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sizedbox_extention/sizedbox_extention.dart';

import 'components/country_picker.dart';

//Todo: change design

class GenerateEmployeeAgreement extends StatefulWidget {
  const GenerateEmployeeAgreement({
    Key? key,
  }) : super(key: key);

  @override
  State<GenerateEmployeeAgreement> createState() =>
      _GenerateEmployeeAgreementState();
}

class _GenerateEmployeeAgreementState extends State<GenerateEmployeeAgreement> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController businessNameController;
  late final TextEditingController industryController;
  late final TextEditingController businessAddressController;
  late final TextEditingController countryController;
  late final TextEditingController employeeNameController;
  late final TextEditingController employeeAddressController;
  late final TextEditingController employeePositionController;
  late final TextEditingController employeeStartDateController;
  late final TextEditingController employmentTermController;
  late final TextEditingController employmentEndDateController;
  late final TextEditingController employeeSalaryController;
  late final TextEditingController paymentFrequencyController;
  late final TextEditingController employeeResponsibilitiesController;
  late final TextEditingController weeklyHoursController;
  late final TextEditingController travelRequiredController;

  late final FocusNode businessNameFocusNode;
  late final FocusNode industryFocusNode;
  late final FocusNode businessAddressFocusNode;
  late final FocusNode countryFocusNode;
  late final FocusNode employeeNameFocusNode;
  late final FocusNode employeeAddressFocusNode;
  late final FocusNode employeePositionFocusNode;
  late final FocusNode employeeStartDateFocusNode;
  late final FocusNode employmentTermFocusNode;
  late final FocusNode employmentEndDateFocusNode;
  late final FocusNode employeeSalaryFocusNode;
  late final FocusNode paymentFrequencyFocusNode;
  late final FocusNode employeeResponsibilitiesFocusNode;
  late final FocusNode weeklyHoursFocusNode;
  late final FocusNode travelRequiredFocusNode;

  @override
  void initState() {
    businessNameController = TextEditingController();
    industryController = TextEditingController();
    businessAddressController = TextEditingController();
    countryController = TextEditingController();
    employeeNameController = TextEditingController();
    employeeAddressController = TextEditingController();
    employeePositionController = TextEditingController();
    employeeStartDateController = TextEditingController();
    employmentTermController = TextEditingController();
    employmentEndDateController = TextEditingController();
    employeeSalaryController = TextEditingController();
    paymentFrequencyController = TextEditingController();
    employeeResponsibilitiesController = TextEditingController();
    weeklyHoursController = TextEditingController();
    travelRequiredController = TextEditingController();

    businessNameFocusNode = FocusNode();
    industryFocusNode = FocusNode();
    businessAddressFocusNode = FocusNode();
    countryFocusNode = FocusNode();
    employeeNameFocusNode = FocusNode();
    employeeAddressFocusNode = FocusNode();
    employeePositionFocusNode = FocusNode();
    employeeStartDateFocusNode = FocusNode();
    employmentTermFocusNode = FocusNode();
    employmentEndDateFocusNode = FocusNode();
    employeeSalaryFocusNode = FocusNode();
    paymentFrequencyFocusNode = FocusNode();
    employeeResponsibilitiesFocusNode = FocusNode();
    weeklyHoursFocusNode = FocusNode();
    travelRequiredFocusNode = FocusNode();

    super.initState();
    context.read<LoadingCubit>().loaded();
  }

  @override
  void dispose() {
    businessNameController.dispose();
    industryController.dispose();
    businessAddressController.dispose();
    countryController.dispose();
    employeeNameController.dispose();
    employeeAddressController.dispose();
    employeePositionController.dispose();
    employeeStartDateController.dispose();
    employmentTermController.dispose();
    employmentEndDateController.dispose();
    employeeSalaryController.dispose();
    paymentFrequencyController.dispose();
    employeeResponsibilitiesController.dispose();
    weeklyHoursController.dispose();
    travelRequiredController.dispose();

    businessNameFocusNode.dispose();
    industryFocusNode.dispose();
    businessAddressFocusNode.dispose();
    countryFocusNode.dispose();
    employeeNameFocusNode.dispose();
    employeeAddressFocusNode.dispose();
    employeePositionFocusNode.dispose();
    employeeStartDateFocusNode.dispose();
    employmentTermFocusNode.dispose();
    employmentEndDateFocusNode.dispose();
    employeeSalaryFocusNode.dispose();
    paymentFrequencyFocusNode.dispose();

    super.dispose();
  }

  static DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  final formattedDate2 = DateFormat("d'th day of' MMMM, yyyy").format(now);

  Map<String, String> getFormValues() {
    final formValues = <String, String>{
      'businessName': businessNameController.text,
      'industry': industryController.text,
      'ownerName': context.read<UserCubit>().state.currentUser!.name.toString(),
      'businessAddress': businessAddressController.text,
      'country': countryController.text,
      'formattedDate': formattedDate2.toString(),
      'employeeName': employeeNameController.text,
      'employeeAddress': employeeAddressController.text,
      'employeePosition': employeePositionController.text,
      'employeeStartDate': employeeStartDateController.text,
      'employmentTerm': employmentTermController.text,
      'employmentEndDate': employmentEndDateController.text,
      'employeeSalary': selectedCurrency.code + employeeSalaryController.text,
      'paymentFrequency': paymentFrequencyController.text,
      'employeeResponsibilities': employeeResponsibilitiesController.text,
      'weeklyHours': weeklyHoursController.text,
      'travelRequired': travelRequiredController.text,
      'companyPolicies': "non",
    };

    return formValues;
  }

  onPressed() async {
    context.unFocus();
    if (_formKey.currentState!.validate()) {
      final userSignature = await showSignaturePad(context);

      if (userSignature != null) {
        final dir = await path_provider.getTemporaryDirectory();
        final targetPath = dir.absolute.path;

        final signature = convertUint8ListToFile(
            userSignature, targetPath + "/signature${generateNumber()}.png");
        try {
          context.read<LoadingCubit>().loading(message: "");
          await context
              .read<UserRepository>()
              .generateEmployeeAgreement(getFormValues(), signature);
          context.read<LoadingCubit>().loaded();
          await successfulDialog(context,
              res: "Employee Agreement Generated Successfully");
          context.popView();
        } catch (e) {
          context.read<LoadingCubit>().loaded();
          anErrorOccurredDialog(context, error: e.toString());
        }
      }
    }
  }

  Currency selectedCurrency = Currency.from(json: {
    'code': 'USD',
    'name': 'United States Dollar',
    'symbol': '\$',
    'number': 840,
    'flag': 'USD',
    'decimal_digits': 2,
    'name_plural': 'US dollars',
    'symbol_on_left': true,
    'decimal_separator': '.',
    'thousands_separator': ',',
    'space_between_amount_and_symbol': false,
  });

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
                  key: _formKey,
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 25.w),
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ScreenHeader(
                                padding: 0,
                                subTitle:
                                    "Please provide the relevant information about your business and the employee to generate your Employment Agreement",
                                title: "Employment Agreement"),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.business,
                              title: "Business Details",
                            ),
                            _InputField(
                              node: businessNameFocusNode,
                              controller: businessNameController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "What is the legal name of your business?",
                              title: "Business Name",
                              nextFocusNode: industryFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: industryFocusNode,
                              controller: industryController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "In what industry does your business operate?",
                              title: "Business Industry",
                              nextFocusNode: businessAddressFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: businessAddressFocusNode,
                              controller: businessAddressController,
                              keyboardType: TextInputType.text,
                              helperText: "What is your business address?",
                              title: "Business Address",
                              nextFocusNode: countryFocusNode,
                            ),
                            20.h.height,
                            CountrySelectionFormField(
                              controller: countryController,
                              nextFocusNode: employeeNameFocusNode,
                              focusNode: countryFocusNode,
                              helperText:
                                  "In which country is your business based?",
                              title: "Business Country",
                            ),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.person,
                              title: "Employee Details",
                            ),
                            _InputField(
                              node: employeeNameFocusNode,
                              controller: employeeNameController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "What is the full name of the employee?",
                              title: "Employee Name",
                              nextFocusNode: employeeAddressFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: employeeAddressFocusNode,
                              controller: employeeAddressController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "What is the address of the employee?",
                              title: "Employee Address",
                              nextFocusNode: employeePositionFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: employeePositionFocusNode,
                              controller: employeePositionController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "What is the position/title of the employee?",
                              title: "Employee Position",
                              nextFocusNode: employeeStartDateFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: employeeStartDateFocusNode,
                              controller: employeeStartDateController,
                              keyboardType: TextInputType.text,
                              hintText: formattedDate,
                              helperText: "What is the employee's start date?",
                              title: "Employee Start Date",
                              nextFocusNode: employmentEndDateFocusNode,
                            ),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.document_scanner,
                              title: "Employment Term",
                            ),
                            EmploymentTermWidget(
                              focusNode: employmentEndDateFocusNode,
                              nextFocusNode: employeeSalaryFocusNode,
                              controller: employmentEndDateController,
                            ),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.monetization_on,
                              title: "Compensation",
                            ),
                            20.h.height,
                            _InputField(
                              prefixIcon: GestureDetector(
                                onTap: () {
                                  showCurrencyPicker(
                                    context: context,
                                    showFlag: true,
                                    showCurrencyName: true,
                                    onSelect: (Currency currency) {
                                      setState(() {
                                        selectedCurrency = currency;
                                      });
                                    },
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    10.width,
                                    Text(
                                      selectedCurrency.symbol,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                              node: employeeSalaryFocusNode,
                              controller: employeeSalaryController,
                              keyboardType: TextInputType.text,
                              hintText: "70,000 ",
                              helperText: "What is the employee's salary?",
                              title: "Employee Salary",
                              nextFocusNode: paymentFrequencyFocusNode,
                            ),
                            20.h.height,
                            PaymentFrequencyFormField(
                              nextFocusNode: employeeResponsibilitiesFocusNode,
                              focusNode: paymentFrequencyFocusNode,
                              controller: paymentFrequencyController,
                            ),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.handshake,
                              title: "Terms of Employment",
                            ),
                            20.h.height,
                            _InputField(
                              node: employeeResponsibilitiesFocusNode,
                              controller: employeeResponsibilitiesController,
                              hintText:
                                  "Software development, code review, and participation in team meetings",
                              keyboardType: TextInputType.text,
                              helperText:
                                  "Describe the duties and responsibilities of the employee's role.",
                              title: "Employee Responsibilities",
                              nextFocusNode: weeklyHoursFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: weeklyHoursFocusNode,
                              controller: weeklyHoursController,
                              keyboardType: TextInputType.text,
                              hintText: "from 9:00 AM to 5:00 PM",
                              helperText:
                                  "Provide the working hours of the employee, make sure to add AM/PM for clarity",
                              title: "Work hours",
                              nextFocusNode: travelRequiredFocusNode,
                            ),
                            20.h.height,
                            TravelRequirementFormField(
                              focusNode: travelRequiredFocusNode,
                              nextFocusNode: null,
                              controller: travelRequiredController,
                            ),
                          ],
                        ),
                      ),
                      20.h.height,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onPressed,
                          child: Text(
                            LocaleKeys.continuE.tr(),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
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

class _InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String title;
  final FocusNode? nextFocusNode;
  final FocusNode? node;
  final String? helperText;
  // final Widget? prefix;
  final Widget? prefixIcon;
  final String? hintText;
  final TextInputType? keyboardType;

  const _InputField({
    Key? key,
    required this.title,
    this.prefixIcon,
    required this.controller,
    this.node,
    this.hintText,
    this.helperText,
    this.keyboardType,
    this.nextFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(title, style: context.theme.textTheme.titleSmall!),
        ),
        5.h.height,
        SizedBox(
          width: double.infinity,
          child: TextFormField(
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return LocaleKeys.required.tr();
              }
              return null;
            },
            keyboardType: keyboardType ?? TextInputType.text,
            controller: controller,
            focusNode: node,
            onEditingComplete: nextFocusNode != null
                ? () {
                    FocusScope.of(context).requestFocus(nextFocusNode);
                  }
                : null,
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              hintText: hintText,
              errorMaxLines: 2,
              helperText: helperText,
            ),
          ),
        ),
      ],
    );
  }
}

class SegmentHeader extends StatelessWidget {
  final Widget? extraWidget;
  final IconData icon;
  final String title;
  const SegmentHeader(
      {Key? key, this.extraWidget, required this.icon, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon),
              SizedBox(
                width: 5.w,
              ),
              Text(title,
                  style: context.theme.textTheme.titleSmall!
                      .copyWith(fontWeight: FontWeight.bold))
            ],
          ),
          extraWidget ?? const SizedBox()
        ],
      ),
    );
  }
}

class EmploymentTermWidget extends StatefulWidget {
  const EmploymentTermWidget({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.nextFocusNode,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;

  @override
  _EmploymentTermWidgetState createState() => _EmploymentTermWidgetState();
}

class _EmploymentTermWidgetState extends State<EmploymentTermWidget> {
  String _selectedTermType = 'Permanent';

  final FocusNode endDateFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    final String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text("Is the employment term fixed or permanent ?",
              style: Theme.of(context).textTheme.titleSmall!),
        ),
        5.h.height,
        DropdownButtonFormField<String>(
          focusNode: widget.focusNode,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          value: _selectedTermType,
          onChanged: (String? newValue) {
            setState(() {
              _selectedTermType = newValue!;
            });

            FocusScope.of(context).requestFocus(_selectedTermType == 'Fixed'
                ? endDateFocusNode
                : widget.nextFocusNode);
          },
          items: ['Permanent', 'Fixed'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        if (_selectedTermType == 'Fixed') ...[
          20.height,
          _InputField(
            node: endDateFocusNode,
            hintText: formattedDate,
            nextFocusNode: widget.focusNode,
            controller: widget.controller,
            title: "End Date",
            helperText: "please provide the end date.",
          )
        ]
      ],
    );
  }
}

class PaymentFrequencyFormField extends StatefulWidget {
  const PaymentFrequencyFormField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.nextFocusNode,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;

  @override
  _PaymentFrequencyFormFieldState createState() =>
      _PaymentFrequencyFormFieldState();
}

class _PaymentFrequencyFormFieldState extends State<PaymentFrequencyFormField> {
  String? _selectedFrequency;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text("Payment Frequency",
              style: context.theme.textTheme.titleSmall!),
        ),
        5.h.height,
        DropdownButtonFormField<String>(
          focusNode: widget.focusNode,
          value: _selectedFrequency,
          isDense: true,
          decoration: const InputDecoration(
            helperText: " How frequently will the employee be paid ?",
            border: OutlineInputBorder(),
          ),
          onChanged: (String? newValue) {
            setState(() {
              _selectedFrequency = newValue!;
            });
            widget.controller.text = newValue ?? "";
            FocusScope.of(context).requestFocus(widget.nextFocusNode);
          },
          items: ['Weekly', 'Biweekly', 'Monthly'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a payment frequency';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class TravelRequirementFormField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;

  const TravelRequirementFormField(
      {Key? key,
      required this.controller,
      required this.focusNode,
      required this.nextFocusNode})
      : super(key: key);

  @override
  _TravelRequirementFormFieldState createState() =>
      _TravelRequirementFormFieldState();
}

class _TravelRequirementFormFieldState
    extends State<TravelRequirementFormField> {
  String? _selectedRequirement;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text("Travel Required",
              style: context.theme.textTheme.titleSmall!),
        ),
        5.h.height,
        DropdownButtonFormField<String>(
            focusNode: widget.focusNode,
            value: _selectedRequirement,
            isDense: true,
            onChanged: (String? newValue) {
              setState(() {
                _selectedRequirement = newValue!;
              });
              widget.controller.text = newValue ?? "";
              context.unFocus();
            },
            items: ['No', 'Yes'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a travel requirement';
              }
              return null;
            }),
      ],
    );
  }
}
