import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/email_validation.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class AddMobileMoneyPayment extends StatefulWidget {
  const AddMobileMoneyPayment({Key? key}) : super(key: key);

  @override
  State<AddMobileMoneyPayment> createState() => _AddMobileMoneyPaymentState();
}

class _AddMobileMoneyPaymentState extends State<AddMobileMoneyPayment> {
  final _formKey = GlobalKey<FormState>();
  final List<String> operators = [
    "Paga Mobile",
    "MTN’s Momo",
    "First Banks Firstmonie",
    "Kudi Mobile",
    "UBA Moni Agent",
    "Polaris Sure Pad"
  ];
  String? _dropNetworkProvider;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 10.w),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _dropNetworkProvider,
              onChanged: (value) {
                setState(() {
                  _dropNetworkProvider = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return "Please select an operator";
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: LocaleKeys.yourNetworkProvider.tr(),
                border: const OutlineInputBorder(),
              ),
              items: operators
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
            ),
            20.h.height,
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: LocaleKeys.email.tr(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (isValidEmail(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            20.h.height,
            TextFormField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: LocaleKeys.phoneNumber.tr(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }

                return null;
              },
            ),
            20.h.height,
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      _formKey.currentState!.save();
                      context.read<PaymentMethodCubit>().addPaymentMethod(
                          const PaymentMethod(
                              name: "Mobile Money",
                              description: "Pay with mobile money",
                              isEnabled: true));
                      context.popView(count: 2);
                    },
                    child: Text(LocaleKeys.continuE.tr())))
          ],
        ),
      ),
    );
  }
}
