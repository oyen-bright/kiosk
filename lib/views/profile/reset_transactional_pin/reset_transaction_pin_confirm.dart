import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ResetTransactionPinConfirm extends StatefulWidget {
  final String currentPin;

  const ResetTransactionPinConfirm({
    Key? key,
    required this.currentPin,
  }) : super(key: key);

  @override
  _ResetTransactionPinConfirmState createState() =>
      _ResetTransactionPinConfirmState();
}

class _ResetTransactionPinConfirmState
    extends State<ResetTransactionPinConfirm> {
  StreamController<ErrorAnimationType>? _errorController;

  String _inputText = "";

  @override
  void initState() {
    _errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  void resetTransacionPin() async {
    try {
      if (_inputText.length != 6) {
        _errorController!
            .add(ErrorAnimationType.shake); // Triggering error shake animation
      } else if (_inputText != widget.currentPin) {
        _errorController!.add(ErrorAnimationType.shake);
        context.snackBar(LocaleKeys.transactionPinDoesNotMatch.tr());
      } else {
        context
            .read<LoadingCubit>()
            .loading(message: "Creating Transaction Pin");
        final response = await context
            .read<UserRepository>()
            .createTransactionPin(transactionPIn: _inputText);
        context.read<LoadingCubit>().loaded();
        await successfulDialog(context, res: response.toString());
        context.popView(count: 2);
      }
    } catch (e) {
      context.read<LoadingCubit>().loaded();
      anErrorOccurredDialog(context, error: e.toString());
    }
  }

  @override
  void dispose() {
    _errorController!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoadingCubit, LoadingState>(
      listener: (context, state) {},
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Stack(
            children: [
              Scaffold(
                appBar: customAppBar(context,
                    title: LocaleKeys.transactionalPinDisabled.tr(),
                    showBackArrow: true,
                    showNewsAndPromo: false,
                    showNotifications: false,
                    showSubtitle: false),
                body: ListView(
                  shrinkWrap: true,
                  children: [
                    CustomContainer(
                      margin: EdgeInsets.symmetric(
                          horizontal: 22.w, vertical: 10.h),
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        children: [
                          ContainerHeader(
                              title: LocaleKeys.confirmTransactionPin.tr(),
                              subTitle: LocaleKeys
                                  .confirmeYourNewTransactionPinThisPinWillBeRequiredAnytimeYouWantToMakeAnTransactionOnKiosk
                                  .tr()),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 0.w),
                              child: BoxTextField(
                                  shape: PinCodeFieldShape.box,
                                  errorAnimationController: _errorController,
                                  onChanged: (value) {
                                    _inputText = value;
                                  },
                                  length: 6,
                                  beforeTextPaste: (text) {
                                    if (int.tryParse(text.toString()) != null) {
                                      _inputText = text!;
                                    }

                                    return true;
                                  })),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 22.w, vertical: 15.h),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: resetTransacionPin,
                        child: Text(
                          LocaleKeys.continuE.tr(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                  visible: isLoading, child: LoadingWidget(title: state.msg))
            ],
          ),
        );
      },
    );
  }
}
