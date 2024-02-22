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

class ChangeTransactionPinConfirm extends StatefulWidget {
  final String oldPin;
  final String currentPin;
  const ChangeTransactionPinConfirm(
      {Key? key, required this.currentPin, required this.oldPin})
      : super(key: key);

  @override
  _ChangeTransactionPinConfirmState createState() =>
      _ChangeTransactionPinConfirmState();
}

class _ChangeTransactionPinConfirmState
    extends State<ChangeTransactionPinConfirm> {
  late final TextEditingController textEditingController;
  StreamController<ErrorAnimationType>? errorController;

  String _inputText = "";

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    textEditingController = TextEditingController();
    super.initState();
  }

  void changeTransacionPin() async {
    try {
      if (_inputText.length != 6) {
        errorController!
            .add(ErrorAnimationType.shake); // Triggering error shake animation
      } else if (_inputText != widget.currentPin) {
        errorController!.add(ErrorAnimationType.shake);
        textEditingController.clear();
        context.snackBar(LocaleKeys.transactionPinDoNotMatch.tr());
      } else {
        context
            .read<LoadingCubit>()
            .loading(message: "Changing transaction pin");
        final response = await context
            .read<UserRepository>()
            .changeTransactionPin(
                oldTransactionPIn: widget.oldPin,
                newTransactionPin: _inputText);
        context.read<LoadingCubit>().loaded();
        await successfulDialog(context, res: response.toString());
        context.popView(count: 3);
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
              appBar: customAppBar(context,
                  title: LocaleKeys.changeTransactionPin.tr(),
                  showBackArrow: true,
                  showNewsAndPromo: false,
                  showNotifications: false,
                  showSubtitle: false),
              body: ListView(
                shrinkWrap: true,
                children: [
                  CustomContainer(
                    margin:
                        EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      children: [
                        ContainerHeader(
                          subTitle:
                              LocaleKeys.confirmYourNewTransactionPin.tr(),
                          title: LocaleKeys.changeTransactionPin.tr(),
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 0.w),
                            child: BoxTextField(
                                shape: PinCodeFieldShape.box,
                                errorAnimationController: errorController,
                                onCompleted: (v) {
                                  _inputText = v;
                                },
                                onChanged: (value) {
                                  _inputText = value;
                                },
                                length: 6,
                                beforeTextPaste: (text) {
                                  if (int.tryParse(text.toString()) != null) {
                                    _inputText = text ?? _inputText;
                                  }
                                  return true;
                                })),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin:
                        EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
                    child: ElevatedButton(
                      onPressed: changeTransacionPin,
                      child: Text(
                        LocaleKeys.continuE.tr(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
                visible: isLoading,
                child: LoadingWidget(
                  title: state.msg,
                ))
          ]),
        );
      },
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    errorController!.close();
    super.dispose();
  }
}
