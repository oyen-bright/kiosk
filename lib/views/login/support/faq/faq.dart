import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';

class FAQ extends StatefulWidget {
  const FAQ({Key? key}) : super(key: key);

  @override
  State<FAQ> createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  List<Widget> users = [];
  List<Widget> questionsw = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
                expandedHeight: 100.0.h,
                floating: false,
                pinned: true,
                backgroundColor: context.theme.canvasColor,
                foregroundColor: context.theme.colorScheme.primary,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    LocaleKeys.frequentlyAskedQuestions.tr(),
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.titleMedium,
                  ),
                )),
          ];
        },
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: FutureBuilder<List>(
              future: context.read<UserRepository>().getFAQ(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    List<String> questions = [];
                    List<String> answers = [];
                    for (var element in snapshot.data!) {
                      questions.add(element["question"]);
                      questionsw.add(Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                  color: Colors.grey.shade300,
                                  padding: const EdgeInsets.all(15),
                                  child: Text(element["question"])),
                            ],
                          )));
                    }
                    for (var element in snapshot.data!) {
                      answers.add(element["answer"]);
                      users.add(Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                  color: Colors.grey.shade300,
                                  padding: const EdgeInsets.all(15),
                                  child: Text(element["answer"])),
                            ],
                          )));
                    }
                    return _FAQs(questions: questions, answers: answers);
                  }
                }
                return Container();
              }),
        ),
      ),
    );
  }
}

class _FAQs extends StatelessWidget {
  const _FAQs({
    Key? key,
    required this.questions,
    required this.answers,
  }) : super(key: key);

  final List<String> questions;
  final List<String> answers;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 3.h),
            child: ExpansionTile(
                childrenPadding: EdgeInsets.only(left: 5.w),
                title: Text(
                  questions[index],
                ),
                children: <Widget>[
                  index == 0
                      ? ListTile(
                          title: Text(
                            answers[index],
                          ),
                        )
                      : ExpansionTile(
                          childrenPadding: EdgeInsets.only(left: 5.w),
                          title: Text(
                            answers[index],
                          ),
                          children: <Widget>[
                            ExpansionTile(
                              childrenPadding: EdgeInsets.only(left: 5.w),
                              title: Text(
                                questions[0],
                              ),
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    answers[0],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                ]),
          );
        },
      ),
    );
  }
}
