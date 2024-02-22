import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiosk/translations/locale_keys.g.dart';

void countryPicker(BuildContext context,
    {required void Function(Country) onSelect, List<String>? countryFilter}) {
  showCountryPicker(
    context: context,
    countryFilter: countryFilter,
    showPhoneCode: false,
    onSelect: onSelect,
    countryListTheme: CountryListThemeData(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      flagSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
      inputDecoration: InputDecoration(
          hintStyle: Theme.of(context).textTheme.bodyMedium,
          hintText: LocaleKeys.startTypingToSearch.tr(),
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none),
    ),
  );
}
