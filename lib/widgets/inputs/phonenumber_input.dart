import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneNumberInput extends StatelessWidget {
  const PhoneNumberInput(
      {Key? key,
      required this.countries,
      this.onFieldSubmitted,
      this.focusNode,
      this.onInputChanged,
      this.initialPhoneNumber})
      : super(key: key);
  final List<String>? countries;
  final void Function(PhoneNumber)? onInputChanged;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  final PhoneNumber? initialPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return InternationalPhoneNumberInput(
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      countrySelectorScrollControlled: false,
      onInputChanged: onInputChanged,
      initialValue: initialPhoneNumber,
      spaceBetweenSelectorAndTextField: 0.5.w,
      selectorConfig: const SelectorConfig(
        leadingPadding: 0,
        selectorType: PhoneInputSelectorType.DIALOG,
      ),
      textStyle: Theme.of(context).textTheme.bodyLarge,
      ignoreBlank: false,
      countries: countries,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      formatInput: true,
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      inputBorder: const UnderlineInputBorder(),
      onSaved: (PhoneNumber number) {},
    );
  }
}
