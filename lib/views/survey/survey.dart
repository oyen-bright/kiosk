import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/navigation_extention.dart';
import 'package:kiosk/extensions/theme_extention.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/widgets/appbar/custom_appbar.dart';
import 'package:kiosk/widgets/custom_widgets/container.dart';
import 'package:kiosk/widgets/error/error.dart';
import 'package:kiosk/widgets/headers/container_header.dart';
import 'package:kiosk/widgets/loader/loading_widget.dart';

import '../../translations/locale_keys.g.dart';
import 'new_survey.dart';

class Survey extends StatefulWidget {
  const Survey({
    Key? key,
  }) : super(key: key);

  @override
  State<Survey> createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        title: LocaleKeys.survey.tr(),
        subTitle: LocaleKeys.profile.tr(),
        showBackArrow: true,
        showNewsAndPromo: false,
        showNotifications: false,
        showSubtitle: true,
      ),
      body: ListView(
        children: [
          CustomContainer(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                ContainerHeader(
                    title: LocaleKeys.survey.tr(),
                    subTitle: LocaleKeys.takeAMomentToCompleteOurSurvey.tr()),
                FutureBuilder(
                  future: context.read<UserRepository>().getAvailableSurveys(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Error(
                          info: snapshot.error.toString(),
                          onPressed: () {
                            setState(() {});
                          },
                          buttonTitle: LocaleKeys.continuE.tr(),
                        );
                      }

                      if (snapshot.hasData) {
                        if (snapshot.data.isNotEmpty) {
                          return ListTile(
                            isThreeLine: false,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10.w),
                            title: Text(LocaleKeys.quickSurvey.tr()),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocaleKeys.tapToProceedToSurveyQuestions.tr(),
                                  maxLines: 1,
                                  style: context.theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              await context.pushView(SurveyScreen(
                                questions: List.from(snapshot.data),
                              ));
                              setState(() {});
                            },
                          );
                        }
                        return Text(LocaleKeys.noSurveyCurrentlyAvailable.tr());
                      }
                    }

                    return const LoadingWidget(
                      isLinear: true,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
