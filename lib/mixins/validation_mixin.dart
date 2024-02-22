import 'package:flutter/services.dart';

mixin ValidationMixin {
  /// Regular expression for validating email addresses.
  static final RegExp _emailRegExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");

  /// A [TextInputFormatter] to allow only numbers in text input.
  static final numbersOnlyFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));

  /// Validates whether a file path is empty or equal to "No file chosen".
  /// Returns an error message if validation fails.
  String? fileValidation(String? value) {
    if (value == null) {
      return "required";
    }
    if (value == "No file chosen") {
      return "please choose a CVS file to continue";
    }
    return null;
  }

  /// Validates whether a given string is a valid email address.
  /// Returns an error message if validation fails.
  String? isEmailValid(String? value) {
    if (value == null) {
      return 'required';
    }
    if (!_emailRegExp.hasMatch(value)) {
      return 'invalid email address';
    }
    return null;
  }

  /// Validates whether a string is empty.
  /// Returns an error message if the string is empty.
  String? emptyValidation(String? value) {
    if (value == null || value.isEmpty) {
      return "required";
    }
    return null;
  }

  /// Validates whether an integer value is not null and greater than zero.
  /// Returns an error message if the validation fails.
  String? emptyValidationInt(int? value) {
    if (value == null || value == 0) {
      return "required";
    }
    return null;
  }

  /// Validates whether a password meets specific criteria:
  /// - At least 8 characters long.
  /// - Contains at least one letter.
  /// - Contains at least one number.
  /// Returns an error message if the password doesn't meet the criteria.
  String? validatePassword(String? value) {
    if (value == null) {
      return 'required';
    }
    if (value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validates whether a confirmation password matches the original password.
  /// Returns an error message if they do not match.
  String? validateConfirmPassword(String? value, String password) {
    if (value == null) {
      return 'Passwords do not match';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
