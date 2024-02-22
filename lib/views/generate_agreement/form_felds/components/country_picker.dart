import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/mixins/validation_mixin.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class CountrySelectionFormField extends StatefulWidget {
  const CountrySelectionFormField(
      {Key? key,
      required this.controller,
      required this.focusNode,
      this.nextFocusNode,
      required this.title,
      required this.helperText})
      : super(key: key);
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final String title;
  final String helperText;

  @override
  _CountrySelectionFormFieldState createState() =>
      _CountrySelectionFormFieldState();
}

class _CountrySelectionFormFieldState extends State<CountrySelectionFormField>
    with ValidationMixin {
  Country? _selectedCountry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(widget.title, style: context.theme.textTheme.titleSmall!),
        ),
        5.h.height,
        TextFormField(
          focusNode: widget.focusNode,
          validator: emptyValidation,
          readOnly: true,
          onTap: () {
            showCountryPicker(
              context: context,
              onSelect: (Country country) {
                widget.controller.text = country.name;

                setState(() {
                  _selectedCountry = country;
                });
                FocusScope.of(context).requestFocus(widget.nextFocusNode);
              },
              showPhoneCode: false,
            );
          },
          decoration: InputDecoration(helperText: widget.helperText),
          controller: widget.controller,
        ),
      ],
    );
  }
}
