import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/navigation_extention.dart';
import 'package:kiosk/extensions/title_case_extention.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/get_currency.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<Expense?> showAddExpenseDialog(BuildContext context) async {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _expenseValueFocusNode = FocusNode();
  final _valueController = TextEditingController();

  return await showDialog(
    context: context,
    builder: (BuildContext contextA) {
      return AlertDialog(
        title: Text(LocaleKeys.addExpense.tr()),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                onEditingComplete: () => FocusScope.of(contextA)
                    .requestFocus(_expenseValueFocusNode),
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: LocaleKeys.expenseName.tr(),
                    hintText: LocaleKeys.salaries.tr()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.required.tr();
                  }
                  return null;
                },
              ),
              10.h.height,
              TextFormField(
                focusNode: _expenseValueFocusNode,
                controller: _valueController,
                decoration: InputDecoration(
                  helperText: LocaleKeys.monthly.tr(),
                  labelText: LocaleKeys.expenseValue.tr(),
                  prefixText: getCurrency(context) + " ",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  CurrencyTextInputFormatter(
                      locale: 'en', decimalDigits: 2, symbol: ""),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.pleaseenteravalidnumber.tr();
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              contextA.popView();
            },
            child: Text(LocaleKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                contextA.popView(
                  value: Expense(
                    name: _nameController.text.titleCase,
                    valueController:
                        TextEditingController(text: _valueController.text),
                  ),
                );

                _nameController.clear();
                _valueController.clear();
              }
            },
            child: Text(LocaleKeys.add.tr()),
          ),
        ],
      );
    },
  );
}
