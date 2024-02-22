// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/theme_extention.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class BoxTextField extends StatelessWidget {
  const BoxTextField(
      {Key? key,
      this.controller,
      this.validator,
      this.errorAnimationController,
      this.textEditingController,
      this.onCompleted,
      required this.onChanged,
      this.beforeTextPaste,
      this.length = 4,
      this.obscureText = false,
      this.shape})
      : super(key: key);

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final StreamController<ErrorAnimationType>? errorAnimationController;
  final TextEditingController? textEditingController;
  final void Function(String)? onCompleted;
  final void Function(String) onChanged;
  final bool Function(String?)? beforeTextPaste;
  final bool obscureText;
  final int length;
  final PinCodeFieldShape? shape;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0.h, horizontal: 10.w),
        child: PinCodeTextField(
          enablePinAutofill: true,
          errorAnimationController: errorAnimationController,
          autoDisposeControllers: false,
          appContext: context,
          autoDismissKeyboard: true,
          useHapticFeedback: true,
          pastedTextStyle: TextStyle(
            color: Colors.green.shade600,
            fontWeight: FontWeight.bold,
          ),
          length: length,
          obscureText: obscureText,
          obscuringWidget: Image.asset(
            "assets/images/logo_app.png",
            height: 24.w,
            width: 24.w,
          ),
          blinkWhenObscuring: true,
          autovalidateMode: AutovalidateMode.disabled,
          animationType: AnimationType.fade,
          validator: validator ??
              (v) {
                if (v!.length < 4) {
                  return "Please input 4 digits";
                } else {
                  return null;
                }
              },
          pinTheme: PinTheme(
            selectedFillColor:
                context.theme.colorScheme.primary.withOpacity(0.2),
            activeColor: Colors.green,
            selectedColor: Colors.green.withOpacity(0.5),
            inactiveFillColor: Colors.white,
            inactiveColor: context.theme.colorScheme.primary,
            shape: shape ?? PinCodeFieldShape.underline,
            fieldHeight: 50.h,
            fieldWidth: 40.w,
            activeFillColor: Colors.white,
          ),
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: true,
          controller: controller,
          textStyle: context.theme.textTheme.titleMedium!
              .copyWith(fontWeight: FontWeight.bold),
          keyboardType: TextInputType.number,
          onCompleted: onCompleted,
          onChanged: onChanged,
          beforeTextPaste: beforeTextPaste,
        ));
  }
}
