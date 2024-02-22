import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/constant_color.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:signature/signature.dart';

Future<Uint8List?> showSignaturePad(
  BuildContext context,
) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return SizedBox(
            child: AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.r))),
          titlePadding: const EdgeInsets.only(left: 20, top: 5),
          title: Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Text(
                  "Please Provide Your Signature",
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                )),
                IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      context.popView();
                    },
                    icon: const Icon(Icons.close)),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [_body()],
          ),
        ));
      });
}

class _body extends StatefulWidget {
  const _body();

  @override
  State<_body> createState() => __bodyState();
}

class __bodyState extends State<_body> {
  late final SignatureController controller;

  @override
  void initState() {
    super.initState();

    controller = SignatureController(
      penStrokeWidth: 4,
      penColor: kioskBlue,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<Uint8List?> exportSignature() async {
    final exportController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      points: controller.points,
    );

    final signature = await exportController.toPngBytes();
    exportController.dispose();

    return signature;
  }

  Widget buildCheck(BuildContext context) => IconButton(
        iconSize: 36,
        icon: const Icon(Icons.check, color: Colors.green),
        onPressed: () async {
          if (controller.isNotEmpty) {
            final signature = await exportSignature();

            context.popView(value: signature);
            controller.clear();
          }
        },
      );

  Widget buildClear() => IconButton(
        iconSize: 36,
        icon: const Icon(Icons.clear, color: Colors.red),
        onPressed: () => controller.clear(),
      );

  Widget buildButtons(BuildContext context) => Container(
        color: kioskYellow,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            buildCheck(context),
            buildClear(),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Signature(
          width: 400,
          height: 300,
          controller: controller,
          backgroundColor: context.theme.scaffoldBackgroundColor,
        ),
        buildButtons(context),
      ],
    );
  }
}
