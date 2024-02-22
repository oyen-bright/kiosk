import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/.constants.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<String?> addManualSales(BuildContext context) async {
  String input = "";
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0.r)),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.symmetric(horizontal: 5.w),
      title: Container(
        width: double.infinity,
        alignment: Alignment.centerRight,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.popView(value: null),
          icon: const Icon(Icons.close),
        ),
      ),
      content: SizedBox(
        width: 200,
        child: StatefulBuilder(builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _customerToPay(context, input),
              40.h.height,
              keyBoard((text) {
                setState(() {
                  input = handleKeyPressed(text, input);
                });
              }),
              _actionButtons(context, input),
            ],
          );
        }),
      ),
    ),
  );
  return result;
}

String handleKeyPressed(String text, String input) {
  if (text.isEmpty) {
    if (input.isNotEmpty) {
      return input.substring(0, input.length - 1);
    }
  } else {
    if (text == ".") {
      if (!input.contains(text)) {
        if (input.length < 10) {
          return input + text;
        }
      }
    } else if (input.length < 10) {
      return input + text;
    }
  }
  return input;
}

Column _customerToPay(BuildContext context, String input) {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          width: double.infinity,
          height: 40.h,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(getCurrency(context),
                style: Theme.of(context).textTheme.titleLarge!),
            Expanded(
              child: AutoSizeText(
                input,
                textAlign: TextAlign.right,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ]),
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        width: double.infinity,
        child: Text(
          LocaleKeys.customerToPay.tr(),
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    ],
  );
}

Widget _actionButtons(BuildContext context, String input) {
  return Container(
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton(
              onPressed: () {
                context.popView(value: input);
              },
              child: AutoSizeText(
                LocaleKeys.decline.tr(),
                maxLines: 1,
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
        ),
        20.w.width,
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.popView(value: input);
            },
            child: AutoSizeText(
              LocaleKeys.charge.tr(),
              maxLines: 1,
            ),
          ),
        ),
      ],
    ),
    height: 35.h,
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    margin: EdgeInsets.only(bottom: 30.h),
    decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.r),
          topRight: Radius.circular(10.r),
        )),
  );
}

Widget keyBoard(void Function(String) onPressed) {
  return Column(
    children: [
      Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Button(
                    buttonNumber: "1",
                    onpressed: () {
                      onPressed("1");
                    },
                  ),
                  Button(
                    buttonNumber: "2",
                    onpressed: () {
                      onPressed("2");
                    },
                  ),
                  Button(
                    buttonNumber: "3",
                    onpressed: () {
                      onPressed("3");
                    },
                  ),
                ]),
            10.h.height,
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Button(
                    buttonNumber: "4",
                    onpressed: () {
                      onPressed("4");
                    },
                  ),
                  Button(
                    buttonNumber: "5",
                    onpressed: () {
                      onPressed("5");
                    },
                  ),
                  Button(
                    buttonNumber: "6",
                    onpressed: () {
                      onPressed("6");
                    },
                  ),
                ]),
            10.h.height,
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Button(
                    buttonNumber: "7",
                    onpressed: () {
                      onPressed("7");
                    },
                  ),
                  Button(
                    buttonNumber: "8",
                    onpressed: () {
                      onPressed("8");
                    },
                  ),
                  Button(
                    buttonNumber: "9",
                    onpressed: () {
                      onPressed("9");
                    },
                  ),
                ]),
            10.h.height,
          ])),
      Container(
        margin: EdgeInsets.only(bottom: 5.0.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Button(
                buttonNumber: ".",
                onpressed: () {
                  onPressed(".");
                },
              ),
              Button(
                buttonNumber: "0",
                onpressed: () {
                  onPressed("0");
                },
              ),
              Button(
                buttonNumber: "<",
                onpressed: () {
                  onPressed("");
                },
              ),
            ]),
      ),
      20.h.height
    ],
  );
}

class Button extends StatelessWidget {
  final String buttonNumber;
  final void Function()? onpressed;
  const Button({Key? key, required this.buttonNumber, required this.onpressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onpressed,
      style: ElevatedButton.styleFrom(
        alignment: Alignment.center,
        foregroundColor: kioskBlue,
        backgroundColor: kioskYellow,
        surfaceTintColor: Colors.grey.shade100,
      ),
      child: Text(
        buttonNumber,
        maxLines: 1,
        style: const TextStyle().copyWith(fontSize: 25),
      ),
    );
  }
}
