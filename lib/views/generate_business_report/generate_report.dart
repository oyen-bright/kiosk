import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

//Todo: change design

class GenerateBusinessReport extends StatefulWidget {
  const GenerateBusinessReport({
    Key? key,
  }) : super(key: key);

  @override
  State<GenerateBusinessReport> createState() => _GenerateBusinessReportState();
}

class _GenerateBusinessReportState extends State<GenerateBusinessReport> {
  final _formkey = GlobalKey<FormState>();
  late final TextEditingController _employeeTextController;
  late final TextEditingController _yearOfOperationTextController;

  final _employeNode = FocusNode();
  final _yearOfOperationNode = FocusNode();
  final _expensesValue = FocusNode();

  Categories? _selectedCategory;
  final List<Categories> _categories = [];
  final List<Expense> _expenses = [];

  String? _selectedValue;

  final List<Map<String, dynamic>> _options = [
    {'text': '1 year', 'value': 12},
    {'text': '2 years', 'value': 24},
    {'text': '3 years', 'value': 36},
  ];

  @override
  void initState() {
    _employeeTextController = TextEditingController();
    _yearOfOperationTextController = TextEditingController();
    getCategories();
    super.initState();
  }

  @override
  void dispose() {
    _employeeTextController.dispose();
    _yearOfOperationTextController.dispose();
    super.dispose();
  }

  Future getCategories() async {
    try {
      final response =
          await context.read<ProductRepository>().getAllCategories();

      setState(() {
        for (var element in response) {
          _categories.add(Categories.fromJson(element));
        }
      });
    } catch (e) {
      await anErrorOccurredDialog(context, error: e.toString());
      context.popView();
    }
  }

  onPressed() async {
    context.unFocus();
    if (_formkey.currentState!.validate()) {
      try {
        context.read<LoadingCubit>().loading(message: "Updating information");
        final response = await context.read<UserRepository>().businessPlan(
            businessCategory: _selectedCategory!.id.toString(),
            numberOfEmployee: _employeeTextController.text,
            expenses: _expenses,
            yearOfOperation: _yearOfOperationTextController.text,
            periodOfReport: _selectedValue.toString());

        context.read<LoadingCubit>().loaded();
        await successfulDialog(context, res: response.toString());
        context.popView();
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
                            ScreenHeader(
                                padding: 0,
                                subTitle: LocaleKeys
                                    .pleaseprovideinformationaboutyourbusinessanddailytradetogenerateabusinessreportforyourbusiness
                                    .tr(),
                                title: LocaleKeys.generateBusinessReport.tr()),
                            20.h.height,
                            SizedBox(
                              width: double.infinity,
                              child: Text(LocaleKeys.businessCategory.tr(),
                                  style: context.theme.textTheme.titleSmall!),
                            ),
                            5.h.height,
                            DropdownButtonFormField<Categories>(
                              value: _selectedCategory,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                                FocusScope.of(context)
                                    .requestFocus(_yearOfOperationNode);
                              },
                              validator: (value) {
                                if (value == null) {
                                  return LocaleKeys.required.tr();
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem<Categories>(
                                  value: category,
                                  child: Text(category.category),
                                );
                              }).toList(),
                            ),
                            20.h.height,
                            _InputField(
                                node: _yearOfOperationNode,
                                controller: _yearOfOperationTextController,
                                keyboardType: TextInputType.none,
                                title:
                                    LocaleKeys.yearOfOperation.tr().titleCase,
                                nextFocusNode: _employeNode,
                                readOnly: true,
                                onTap: () async {
                                  context.unFocus();
                                  final response = await datePicker(context);
                                  if (response != null) {
                                    _yearOfOperationTextController.text =
                                        response.toString().substring(0, 10);
                                  }
                                }),
                            20.h.height,
                            _InputField(
                              node: _employeNode,
                              controller: _employeeTextController,
                              keyboardType: TextInputType.number,
                              title: LocaleKeys.numbersOfEmployee.tr(),
                              validator: (value) {
                                if (value == null) {
                                  return LocaleKeys.required.tr();
                                }
                                if (int.tryParse(value) == null) {
                                  return LocaleKeys.pleaseenteravalidnumber
                                      .tr();
                                }
                                return null;
                              },
                              nextFocusNode: null,
                              helperText: LocaleKeys
                                  .theTotalNumberOfEmployeesThatAreCurrentlyWorkingWith
                                  .tr(),
                              readOnly: false,
                            ),
                            20.h.height,
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  if (_expenses.isEmpty)
                                    SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          LocaleKeys
                                              .toaddexpensestoyourbusinessreportclickontheAddExpensesbuttonandfollowtheprompts
                                              .tr(),
                                          style: context
                                              .theme.textTheme.titleSmall,
                                        )),
                                  if (_expenses.isNotEmpty)
                                    for (var expense in _expenses)
                                      Column(
                                        children: [
                                          _InputField(
                                            helperText: LocaleKeys.monthly.tr(),
                                            node: null,
                                            validator: (v) {
                                              final data = v
                                                  .toString()
                                                  .replaceAll(",", "");
                                              if (double.tryParse(data) ==
                                                  null) {
                                                return LocaleKeys
                                                    .pleaseenteravalidnumber
                                                    .tr();
                                              }
                                              return null;
                                            },
                                            controller: expense.valueController,
                                            keyboardType: TextInputType.number,
                                            title: expense.name,
                                            nextFocusNode: null,
                                            readOnly: false,
                                          ),
                                          20.h.height,
                                        ],
                                      ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                        onPressed: () async {
                                          final response =
                                              await showAddExpenseDialog(
                                                  context);
                                          if (response != null) {
                                            setState(() {
                                              _expenses.add(response);
                                            });
                                          }
                                        },
                                        child:
                                            Text(LocaleKeys.addExpenses.tr())),
                                  )
                                ],
                              ),
                            ),
                            20.h.height,
                            SizedBox(
                              width: double.infinity,
                              child: Text(LocaleKeys.periodOfReport.tr(),
                                  style: context.theme.textTheme.titleSmall!),
                            ),
                            5.h.height,
                            DropdownButtonFormField<String>(
                              value: _selectedValue,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedValue = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return LocaleKeys.required.tr();
                                }
                                return null;
                              },
                              items: _options
                                  .map<DropdownMenuItem<String>>(
                                    (option) => DropdownMenuItem<String>(
                                      value: option['value'].toString(),
                                      child: Text(option['text']),
                                    ),
                                  )
                                  .toList(),
                              decoration: InputDecoration(
                                helperText: LocaleKeys
                                    .selectTheHowMnayMonthsReportYouWantToGenerateForYourBusiness
                                    .tr(),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      20.h.height,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (() => onPressed()),
                          child: Text(
                            LocaleKeys.continuE.tr(),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
            Visibility(
              child: LoadingWidget(
                  title: !isLoading ? "" : "Creating Business Report"),
              visible: isLoading || _categories.isEmpty,
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
  final void Function()? onTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;

  const _InputField(
      {Key? key,
      required this.title,
      required this.controller,
      this.onTap,
      this.readOnly = false,
      this.node,
      this.validator,
      this.helperText,
      this.keyboardType,
      this.nextFocusNode})
      : super(key: key);

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
            controller: controller,
            focusNode: node,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(nextFocusNode);
            },
            decoration: InputDecoration(
                errorMaxLines: 2,
                helperText: helperText,
                labelText: "",
                suffixIcon: onTap != null
                    ? IconButton(
                        icon: const Icon(Icons.arrow_drop_down),
                        onPressed: onTap,
                      )
                    : null),
          ),
        ),
      ],
    );
  }
}

class CustomWidget extends StatelessWidget {
  final String title;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final TextEditingController controller;
  const CustomWidget(
      {Key? key,
      this.focusNode,
      this.nextFocusNode,
      required this.controller,
      required this.title})
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
        TextFormField(
          onEditingComplete: nextFocusNode != null
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
          textAlignVertical: TextAlignVertical.center,
          controller: controller,
        ),
      ],
    );
  }
}
