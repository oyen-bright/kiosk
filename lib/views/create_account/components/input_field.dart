import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String title;
  final FocusNode? node;
  final FocusNode? nextFocusNode;
  final String? hintText;
  final void Function()? onTap;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final bool readOnly;

  const InputField(
      {Key? key,
      required this.title,
      required this.controller,
      this.textCapitalization,
      this.node,
      this.hintText,
      this.onTap,
      this.readOnly = false,
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
            textCapitalization: textCapitalization ?? TextCapitalization.none,
            onTap: onTap,
            readOnly: readOnly,
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
                hintText: hintText,
                errorMaxLines: 2,
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
