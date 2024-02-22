import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/create_account/create_business_info/register_business_infomation.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class TransactionPinConfirm extends StatefulWidget {
  final String currentPin;
  final String firstName;
  final String email;
  final String password;
  final Map<String, dynamic> sessionToken;
  const TransactionPinConfirm(
      {Key? key,
      required this.password,
      required this.firstName,
      required this.currentPin,
      required this.sessionToken,
      required this.email})
      : super(key: key);

  @override
  State<TransactionPinConfirm> createState() => _TransactionPinConfirmState();
}

class _TransactionPinConfirmState extends State<TransactionPinConfirm> {
  late final StreamController<ErrorAnimationType> errorController;

  String pin = "";

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
  }

  @override
  void dispose() {
    errorController.close();
    super.dispose();
  }

  void createTransactionPIn() async {
    try {
      if (pin.length != 6) {
        errorController.add(ErrorAnimationType.shake);
      } else if (pin != widget.currentPin) {
        errorController.add(ErrorAnimationType.shake);

        context.snackBar(LocaleKeys.transactionPinDoNotMatch.tr());
      } else {
        context.read<LoadingCubit>().loading();
        final response =
            await context.read<UserRepository>().createTransactionPinWithLogin(
                  userName: widget.email,
                  password: widget.password,
                  transactionPIn: pin,
                );
        context.read<LoadingCubit>().loaded();
        await successfulDialog(context,
            res: response.toString(),
            title: LocaleKeys.transactionPinCreated.tr());
        context.pushView(
            RegisterBusinessInformation(
              userPassword: widget.password,
              userEmail: widget.email,
            ),
            clearStack: true);
      }
    } catch (e) {
      context.read<LoadingCubit>().loaded();
      anErrorOccurredDialog(context, error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingCubit, LoadingState>(
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Stack(children: [
            Scaffold(
              backgroundColor: context.theme.canvasColor,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: context.theme.canvasColor,
                elevation: 0,
                title: const AppbarLogo(),
                centerTitle: true,
              ),
              body: ListView(
                children: [
                  20.h.height,
                  ScreenHeader(
                    title: LocaleKeys.hello.tr() +
                        " " +
                        widget.firstName +
                        ",\n" +
                        LocaleKeys.confirmTransactionPin.tr(),
                    subTitle: LocaleKeys
                        .confirmYourTransactionPinThisPinWillBeRequiredAnytimeYouWantToView
                        .tr(),
                  ),
                  20.h.height,
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: BoxTextField(
                        shape: PinCodeFieldShape.box,
                        length: 6,
                        errorAnimationController: errorController,
                        onCompleted: (v) {},
                        onChanged: (value) {
                          pin = value;
                        },
                        beforeTextPaste: (text) {
                          if (int.tryParse(text.toString()) != null) {
                            pin = text!;
                          }
                          return true;
                        },
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.w),
                      child: ElevatedButton(
                          onPressed: createTransactionPIn,
                          child: Text(
                            LocaleKeys.continuE.tr(),
                          ))),
                ],
              ),
            ),
            Visibility(
                child: const LoadingWidget(
                  title: "Creating PIN",
                ),
                visible: isLoading),
          ]),
        );
      },
    );
  }
}
