import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneNumberController extends ValueNotifier<PhoneNumber> {
  PhoneNumberController(PhoneNumber? initialValue)
      : super(initialValue ?? PhoneNumber());
}
