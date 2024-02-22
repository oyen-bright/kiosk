import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<File?> _getFromCamera(
    ImageSource fromWhere, BuildContext context) async {
  try {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: fromWhere,
      maxWidth: 900,
      imageQuality: 5,
      maxHeight: 900,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  } catch (e) {
    context.snackBar(e.toString());
    return null;
  }
}

Future<File?> imagePicker(BuildContext context) async {
  if (Platform.isIOS) {
    final file = await showBarModalBottomSheet(
        useRootNavigator: true,
        context: context,
        builder: (contexS) => Container(
              padding: EdgeInsets.only(bottom: 10.h),
              color: context.theme.canvasColor,
              child: const _Body(),
            ));
    return file;
  } else {
    final file = await showModalBottomSheet(
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: context.theme.canvasColor,
          ),
          width: double.infinity,
          child: const _Body()),
    );
    return file;
  }
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        15.h.height,
        ListTile(
            horizontalTitleGap: 1,
            onTap: () async {
              final image = await _getFromCamera(ImageSource.camera, context);
              context.popView(value: image);
            },
            leading: const Icon(Icons.camera_alt),
            title: Text(LocaleKeys.takeAPhoto.tr())),
        ListTile(
            horizontalTitleGap: 1,
            onTap: () async {
              final image = await _getFromCamera(ImageSource.gallery, context);
              context.popView(value: image);
            },
            leading: const Icon(Icons.photo_library),
            title: Text(
              LocaleKeys.pickImageFromGallery.tr(),
            )),
        15.h.height,
      ],
    );
  }
}
