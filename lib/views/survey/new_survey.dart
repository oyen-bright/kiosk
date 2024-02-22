import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:survey_kit/survey_kit.dart';

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({
    required this.questions,
    Key? key,
  }) : super(key: key);

  final List<Map> questions;

  @override
  Widget build(BuildContext context) {
    final jsonQuestion = {
      "id": "KioskSurvey",
      "type": "navigable",
      "steps": [
        {
          "stepIdentifier": {"id": "First"},
          "type": "intro",
          "title": "Welcome to kroon Kiosk Survey",
          "text": "Get ready for a bunch of super random questions!",
          "buttonText": "Let's go!"
        },
        ...questions
            .map((e) => {
                  "stepIdentifier": {"id": e['id']},
                  "type": "question",
                  "title": e['survey_question'].toString().titleCase,
                  "isOptional": false,
                  "answerFormat": {
                    "type": "text",
                    "defaultValue": "",
                    "hint": "Please enter your answer"
                  }
                })
            .toList(),
        {
          "stepIdentifier": {"id": "Last"},
          "type": "completion",
          "text": "Thanks for taking the survey.",
          "title": "Done!",
          "buttonText": "Submit survey"
        }
      ]
    };

    return Scaffold(
        body: SafeArea(
      child: CustomContainer(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: GestureDetector(
          onTap: () => context.unFocus(),
          child: SurveyKit(
            onResult: (SurveyResult result) async {
              context.unFocus();
              if (result.finishReason == FinishReason.COMPLETED) {
                final jsonMap = result.toJson();

                final results = jsonMap['results'];
                final extractedData = [];

                for (final result in results) {
                  final id = result['id']['id'];

                  if (id != 'First' && id != 'Last') {
                    final valueIdentifier =
                        result['results'][0]['valueIdentifier'];
                    final map = {
                      'survey_questions_id': id,
                      'survey_answer': valueIdentifier
                    };
                    extractedData.add(map);
                  }
                }

                try {
                  final response = await context
                      .read<UserRepository>()
                      .submitSurvey(result: List.from(extractedData));
                  context.snackBar(response);
                } catch (e) {
                  await anErrorOccurredDialog(context, error: e.toString());
                }

                log(extractedData.toString());
              }

              context.popView();

              //Evaluate results
            },
            themeData: context.theme.copyWith(
              colorScheme: context.theme.colorScheme
                  .copyWith(background: Colors.transparent),
              appBarTheme: AppBarTheme(
                  backgroundColor: Colors.transparent,
                  foregroundColor: context.theme.colorScheme.primary),
              primaryColor: context.theme.colorScheme.primary,
              textTheme: TextTheme(
                  headlineSmall: const TextStyle(
                    color: Colors.grey,
                  ),
                  titleMedium: TextStyle(
                      color: context.theme.brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                      fontSize: 20),
                  bodyMedium: const TextStyle(color: Colors.grey, fontSize: 20),
                  displayMedium: const TextStyle().copyWith(
                      fontSize: 30,
                      color: context.theme.brightness == Brightness.light
                          ? Colors.black
                          : Colors.white)),
            ),
            task: Task.fromJson(jsonQuestion),
          ),
        ),
      ),
    ));
  }
}
