import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';
import 'package:url_launcher/url_launcher.dart';

class FrequentlyAskedQuestions extends StatelessWidget {
  const FrequentlyAskedQuestions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // context.read<AnalyticsService>().logCheckFAQ();

    return Scaffold(
      floatingActionButton: const FAB(),
      appBar: customAppBar(context,
          title: LocaleKeys.frequentlyAskedQuestions.tr(),
          showBackArrow: true,
          subTitle: LocaleKeys.profile.tr(),
          showNewsAndPromo: false,
          showNotifications: false),
      body: Scrollbar(
        child: ListView(
          children: [
            FutureBuilder<List>(
                future: context.read<UserRepository>().getFAQ(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Error(info: snapshot.error.toString());
                    }
                    if (snapshot.hasData) {
                      final faqList = snapshot.data!;
                      final questions = faqList
                          .map((faq) => faq["question"].toString().titleCase)
                          .toList();
                      final answers = faqList
                          .map((faq) => faq["answer"].toString().titleCase)
                          .toList();
                      return FaqContents(
                          questions: questions, answers: answers);
                    }
                  }
                  return const LoadingState();
                }),
            40.h.height
          ],
        ),
      ),
    );
  }
}

class FaqContents extends StatelessWidget {
  const FaqContents({
    Key? key,
    required this.questions,
    required this.answers,
  }) : super(key: key);

  final List<String> questions;
  final List<String> answers;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            ContainerHeader(
                title: LocaleKeys.fAQ.tr(),
                subTitle: LocaleKeys
                    .cantFindTheInformationYouReLookingForPleaseFeelFreeToContactUsDirectlyAndOurCustomerSupportTeamWillBeHappyToAssistYou
                    .tr()),
            Column(
              children: List.generate(questions.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: QuestionExpantion(
                      questions: questions, index: index, answers: answers),
                );
              }),
            )
          ],
        ));
  }
}

class FAB extends StatelessWidget {
  const FAB({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        try {
          if (!await launchUrl(
              Uri.parse("mailto:support@mykroonapp.com?subject="
                  "&body=''"))) {
          } else {
            await launchUrl(
                Uri.parse("mailto:support@mykroonapp.com?subject="
                    "&body=''"),
                mode: LaunchMode.externalApplication);
          }
        } catch (_) {}
      },
      icon: const Icon(Icons.call),
      label: Text(LocaleKeys.contactSupport.tr()),
    );
  }
}

class QuestionExpantion extends StatelessWidget {
  const QuestionExpantion({
    Key? key,
    required this.questions,
    required this.answers,
    required this.index,
  }) : super(key: key);

  final List<String> questions;
  final List<String> answers;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        childrenPadding: EdgeInsets.only(left: 5.w),
        title: Text(
          questions[index].titleCase,
        ),
        children: <Widget>[
          ListTile(
            title: Text(
              answers[index].titleCase,
            ),
          )
        ]);
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
        padding: EdgeInsets.all(16.r),
        child: Column(children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                    child: SizedBox(
                  width: double.infinity,
                  child: AutoSizeText(LocaleKeys.frequentlyAskedQuestions.tr(),
                      style: context.theme.textTheme.titleMedium),
                )),
              ],
            ),
          ),
          LoadingWidget(
              isLinear: true, backgroundColor: context.theme.primaryColorLight)
        ]));
  }
}
