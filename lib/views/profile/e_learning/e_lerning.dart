import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';

import 'e_learning_video_screen.dart';

class ELearning extends StatelessWidget {
  const ELearning({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context,
          title: LocaleKeys.eLearning.tr(),
          showBackArrow: true,
          subTitle: LocaleKeys.profile.tr(),
          showNewsAndPromo: false,
          showNotifications: false),
      body: Scrollbar(
        child: ListView(
          children: [
            FutureBuilder<List<dynamic>>(
              future: context.read<UserRepository>().getELearningVideos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Error(info: snapshot.error.toString());
                  }
                  if (snapshot.hasData) {
                    return ELearningContent(
                      videosList: snapshot.data!,
                    );
                  }
                }
                return const LoadingState();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ELearningContent extends StatelessWidget {
  const ELearningContent({Key? key, required this.videosList})
      : super(key: key);
  final List<dynamic> videosList;
  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          ContainerHeader(
            title: LocaleKeys.welcomeToKroonKioskELearning.tr(),
            subTitle: LocaleKeys.theELearningMaterial.tr(),
          ),
          Column(
            children: List.generate(videosList.length, (index) {
              return ELearningWidget(
                imageURL: videosList[index]["vd_thumbnail"] ?? "",
                callback: () {
                  context.pushView(
                    ELearningVideoScreen(
                      videoURL: videosList[index]["vd_link"],
                      videoThumbnail: videosList[index]["vd_thumbnail"] ?? "",
                      videoTitle:
                          videosList[index]["title"].toString().titleCase,
                      videos: videosList,
                    ),
                  );
                },
                title: videosList[index]["title"].toString().titleCase,
                dateDuration: videosList[index]["duration"],
              );
            }),
          ),
        ],
      ),
    );
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
                    child: AutoSizeText(
                        LocaleKeys.welcomeToKroonKioskELearning.tr(),
                        style: context.theme.textTheme.titleMedium),
                  ),
                ),
              ],
            ),
          ),
          LoadingWidget(
              isLinear: true, backgroundColor: context.theme.primaryColorLight)
        ]));
  }
}
