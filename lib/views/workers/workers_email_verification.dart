import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/email_validation.dart';
import 'package:kiosk/views/workers/workers_confirm_details.dart';
import 'package:kiosk/views/workers/workers_otp_verification.dart';
import 'package:kiosk/widgets/.widgets.dart';

class WorkersEmailVerification extends StatefulWidget {
  const WorkersEmailVerification({Key? key}) : super(key: key);

  @override
  State<WorkersEmailVerification> createState() =>
      _WorkersEmailVerificationState();
}

class _WorkersEmailVerificationState extends State<WorkersEmailVerification> {
  late final TextEditingController _textEditingController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> onContinue() async {
    if (_formKey.currentState!.validate()) {
      try {
        final email = _textEditingController.text;
        context.unFocus();
        context.read<LoadingCubit>().loading(message: "Verifying email");
        final response = await context
            .read<UserRepository>()
            .verityWorkersEmail(email: email);
        if (response != null) {
          context.pushView(ConfirmWorkersDetails(data: response));
        } else {
          context.pushView(WorkersOTPVerification(
            email: email,
          ));
        }
        context.read<LoadingCubit>().loaded();
      } catch (e) {
        context.read<LoadingCubit>().loaded();
        anErrorOccurredDialog(context, error: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingCubit, LoadingState>(
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Stack(alignment: Alignment.topCenter, children: [
            Scaffold(
                appBar: customAppBar(context,
                    title: LocaleKeys.myWorkers.tr(),
                    showBackArrow: true,
                    showNewsAndPromo: false,
                    showNotifications: false,
                    showSubtitle: false),
                body: BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                    return ListView(children: [
                      Form(
                        key: _formKey,
                        child: CustomContainer(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                                horizontal: 22.w, vertical: 10.h),
                            padding: EdgeInsets.all(16.r),
                            child: Column(children: [
                              ContainerHeader(
                                title: LocaleKeys.workerEmailVerification.tr(),
                                subTitle: LocaleKeys
                                    .whenAddingANewWorkerYouWillNeedToInputTheirEmailAddressForVerificationIfTheWorkerIsAlreadyOnOurPlatformYouCanSimplyConfirmTheirDetailsAndProceedHoweverIfTheWorkerIsNewToOurPlatformWeWillSendAnOtpToTheirEmailForVerificationBeforeTheyCanBeAddedAsANewWorker
                                    .tr(),
                              ),
                              SizedBox(
                                  width: double.infinity,
                                  child: Text(LocaleKeys.email.tr(),
                                      style:
                                          context.theme.textTheme.bodySmall!)),
                              TextFormField(
                                controller: _textEditingController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return LocaleKeys.required.tr();
                                  }
                                  if (!isValidEmail(value.trim())) {
                                    return LocaleKeys.invalidEmail.tr();
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                    helperText: "Your workers email"),
                              ),
                            ])),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onContinue,
                          child: Text(
                            LocaleKeys.continuE.tr().toUpperCase(),
                          ),
                        ),
                      )
                    ]);
                  },
                )),
            Visibility(
              child: const LoadingWidget(),
              visible: isLoading,
            )
          ]),
        );
      },
    );
  }
}
