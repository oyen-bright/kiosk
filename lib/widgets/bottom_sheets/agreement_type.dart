import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/generate_agreement/generate_pdf.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<AgreementType?> chooseAgreementTypeBottomSheet(
  final BuildContext context,
) async {
  return await showCupertinoModalBottomSheet(
      barrierColor: Colors.black87,
      backgroundColor: context.theme.colorScheme.onPrimary,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(bottom: 10.h),
          child: SafeArea(
            child: Material(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // _buildAppBar(context),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(LocaleKeys.employeeAgreement.tr()),
                    onTap: () {
                      Navigator.pop(context, AgreementType.employee);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: Text(LocaleKeys.loanAgreement.tr()),
                    onTap: () {
                      Navigator.pop(context, AgreementType.loan);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: Text(LocaleKeys.goodsAndServicesAgreement.tr()),
                    onTap: () {
                      Navigator.pop(context, AgreementType.saleServiceGoods);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(LocaleKeys.shareholderAgreement.tr()),
                    onTap: () {
                      Navigator.pop(context, AgreementType.shareHolder);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
