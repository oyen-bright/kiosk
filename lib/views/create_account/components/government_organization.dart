// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/create_account/components/input_field.dart';
import 'package:kiosk/widgets/pickers/yes_no_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class GovernmentOrganization extends StatefulWidget {
  const GovernmentOrganization({
    Key? key,
    required this.controller,
    required this.affiliatedController,
    required this.organization,
    required this.affiliatedControllerNasme,
    required this.countryStateTextController,
  }) : super(key: key);

  final TextEditingController controller;
  final TextEditingController affiliatedController;
  final TextEditingController countryStateTextController;

  final TextEditingController affiliatedControllerNasme;
  final List<String> organization;

  @override
  State<GovernmentOrganization> createState() => _GovernmentOrganizationState();
}

class _GovernmentOrganizationState extends State<GovernmentOrganization> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InputField(
        controller: widget.affiliatedController,
        // title: "Are you affiliated with an SME Agency/Group?",
        title: LocaleKeys.areYouAffiliatedWithAnSMEAgencyGroup.tr(),
        hintText: LocaleKeys.areYouAffiliatedWithAnSMEAgencyGroup.tr(),
        keyboardType: TextInputType.none,
        nextFocusNode: null,
        readOnly: true,
        onTap: () async {
          context.unFocus();
          final response = await yesNoPicker(context);
          if (response != null) {
            widget.controller.clear();
            widget.affiliatedController.text = response ? "Yes" : "No";
            widget.affiliatedControllerNasme.clear();
            widget.controller.clear();
            setState(() {});
          }
        },
      ),
      if (widget.affiliatedController.text.isNotEmpty &&
          widget.countryStateTextController.text == "Lagos State" &&
          widget.affiliatedController.text == "Yes") ...[
        20.h.height,
        InputField(
          controller: widget.affiliatedControllerNasme,
          title: LocaleKeys.areYouAffiliatedWithNasmeLagos.tr(),
          hintText: LocaleKeys.areYouAffiliatedWithNasmeLagos.tr(),
          keyboardType: TextInputType.none,
          nextFocusNode: null,
          readOnly: true,
          onTap: () async {
            context.unFocus();
            final response = await yesNoPicker(context);
            if (response != null) {
              widget.controller.clear();
              widget.affiliatedControllerNasme.text = response ? "Yes" : "No";
              setState(() {});
            }
          },
        ),
      ],
      if ((widget.affiliatedControllerNasme.text.isNotEmpty &&
                  widget.affiliatedControllerNasme.text != "Yes" ||
              widget.countryStateTextController.text != "Lagos State") &&
          widget.affiliatedController.text == "Yes") ...[
        20.h.height,
        InputField(
          hintText: LocaleKeys.sMEAgencyGroup.tr(),
          title: LocaleKeys.sMEAgencyGroup.tr(),
          // hintText: "SME Agency/Group",
          controller: widget.controller,
          // title: "SME Agency/Group",
          keyboardType: TextInputType.none,
          nextFocusNode: null,
          readOnly: true,
          onTap: () async {
            context.unFocus();
            final response =
                await organizationPicker(context, widget.organization);

            if (response != null) {
              widget.controller.text = response;
            }
          },
        ),
      ],
    ]);
  }
}

Future<String?> organizationPicker(
    BuildContext context, List<String> organizations) async {
  if (Platform.isAndroid) {
    return await showMaterialModalBottomSheet(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => SafeArea(child: _body(context, organizations)));
  } else {
    return await showCupertinoModalBottomSheet(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => _body(context, organizations));
  }
}

Material _body(BuildContext context, List<String> organizations) {
  return Material(
      child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        color: context.theme.canvasColor.darken(1),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(LocaleKeys.sMEAgencyGroup.tr()),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(LocaleKeys.cancel.tr(),
                    style: context.theme.textTheme.titleMedium!
                        .copyWith(color: context.theme.colorScheme.primary))),
          ],
        ),
      ),
      Expanded(
          child: ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (_, index) => const Divider(
          thickness: 1,
        ),
        itemCount: organizations.length,
        itemBuilder: (context, index) {
          return ListTile(
            visualDensity: VisualDensity.comfortable,
            title: Text(organizations[index]),
            onTap: () {
              context.popView(value: organizations[index]);
            },
          );
        },
      )),
    ],
  ));
}
