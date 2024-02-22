import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future showinformationDialog(BuildContext context,
    {required String title, required String information}) {
  return showDialog(
      context: context,
      builder: (context) {
        return SizedBox(
            child: AlertDialog(
          scrollable: true,
          contentPadding:
              const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 25),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.r))),
          titlePadding: EdgeInsets.zero,
          title: Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  context.popView();
                },
                icon: const Icon(Icons.close)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.bold)),
              ),
              5.h.height,
              SizedBox(
                width: double.infinity,
                child: Text(
                  information,
                  style: context.theme.textTheme.bodyMedium,
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ));
      });
}
