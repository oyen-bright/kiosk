import 'package:flutter_test/flutter_test.dart';
import 'package:your_package_name/validation_mixin.dart';

void main() {
  group('ValidationMixin', () {
    late ValidationMixin validationMixin;

    setUp(() {
      validationMixin = ValidationMixin();
    });

    test(
        'fileValidation returns null if value is not empty or "No file chosen"',
        () {
      final result = validationMixin.fileValidation('test.csv');
      expect(result, isNull);
    });

    test('fileValidation returns "required" if value is null', () {
      final result = validationMixin.fileValidation(null);
      expect(result, equals('required'));
    });

    test(
        'fileValidation returns "please choose a CVS file to continue" if value is "No file chosen"',
        () {
      final result = validationMixin.fileValidation('No file chosen');
      expect(result, equals('please choose a CVS file to continue'));
    });

    test('isEmailValid returns null if value is a valid email address', () {
      final result = validationMixin.isEmailValid('test@example.com');
      expect(result, isNull);
    });

    test('isEmailValid returns "required" if value is null', () {
      final result = validationMixin.isEmailValid(null);
      expect(result, equals('required'));
    });

    test(
        'isEmailValid returns "invalid email address" if value is not a valid email address',
        () {
      final result = validationMixin.isEmailValid('invalid_email');
      expect(result, equals('invalid email address'));
    });
  });
}
