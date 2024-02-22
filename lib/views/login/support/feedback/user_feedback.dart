import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';
import 'package:validators/validators.dart';

class UserFeedBack extends StatefulWidget {
  const UserFeedBack({Key? key}) : super(key: key);

  @override
  State<UserFeedBack> createState() => _UserFeedBackState();
}

class _UserFeedBackState extends State<UserFeedBack> {
  late final TextEditingController userEmail;
  late final TextEditingController feedBackSubject;
  late final TextEditingController feedBackMessage;

  final subjectFocusNode = FocusNode();
  final messageFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    feedBackMessage = TextEditingController();
    feedBackSubject = TextEditingController();
    userEmail = TextEditingController();
  }

  @override
  void dispose() {
    feedBackMessage.dispose();
    feedBackSubject.dispose();
    userEmail.dispose();
    super.dispose();
  }

  void onPressed() async {
    context.unFocus();
    if (_formKey.currentState!.validate()) {
      try {
        context.read<LoadingCubit>().loading();
        final response = await context.read<UserRepository>().sendFeedback(
            email: userEmail.text,
            subject: feedBackSubject.text,
            message: feedBackMessage.text);
        context.read<LoadingCubit>().loaded();
        userEmail.clear();
        feedBackMessage.clear();
        feedBackSubject.clear();
        await successfulDialog(context, res: response);
        context.popView();
      } catch (e) {
        context.read<LoadingCubit>().loaded();
        anErrorOccurredDialog(context, error: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingCubit, LoadingState>(builder: (context, state) {
      final isLoading = state.status == Status.loading;

      return WillPopScope(
        onWillPop: () async => !isLoading,
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: context.theme.canvasColor,
              appBar: AppBar(
                foregroundColor: context.theme.colorScheme.primary,
                backgroundColor: context.theme.canvasColor,
                centerTitle: false,
                elevation: 0,
              ),
              body: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ScreenHeader(
                        subTitle: LocaleKeys.pleaseEnterComplete.tr(),
                        title: LocaleKeys.feedback.tr()),
                    20.h.height,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.w),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return LocaleKeys.required.tr();
                          } else if (!(isEmail(value))) {
                            return LocaleKeys.invalidEmail.tr();
                          }
                          return null;
                        },
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(subjectFocusNode);
                        },
                        textAlignVertical: TextAlignVertical.center,
                        controller: userEmail,
                        decoration:
                            InputDecoration(hintText: LocaleKeys.email.tr()),
                      ),
                    ),
                    15.h.height,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.w),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return LocaleKeys.required.tr();
                          }
                          return null;
                        },
                        focusNode: subjectFocusNode,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(messageFocusNode);
                        },
                        textAlignVertical: TextAlignVertical.center,
                        controller: feedBackSubject,
                        decoration:
                            InputDecoration(hintText: LocaleKeys.subject.tr()),
                      ),
                    ),
                    15.h.height,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.w),
                      child: TextFormField(
                        focusNode: messageFocusNode,
                        onEditingComplete: onPressed,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return LocaleKeys.required.tr();
                          }
                          return null;
                        },
                        textAlignVertical: TextAlignVertical.center,
                        controller: feedBackMessage,
                        maxLines: 5,
                        decoration:
                            InputDecoration(hintText: LocaleKeys.message.tr()),
                      ),
                    ),
                    15.h.height,
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 25.w),
                      child: ElevatedButton(
                        onPressed: onPressed,
                        child: Text(
                          LocaleKeys.submit.tr().toUpperCase(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              child: const LoadingWidget(),
              visible: isLoading,
            ),
          ],
        ),
      );
    });
  }
}
