import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';

class ConfirmWorkersDetails extends StatelessWidget {
  const ConfirmWorkersDetails({Key? key, required this.data}) : super(key: key);
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    Future<void> _onContinue(BuildContext context, String email) async {
      try {
        context.read<LoadingCubit>().loading(message: "Adding Worker");
        final response =
            await context.read<UserRepository>().addWorker(email: email);
        context.read<LoadingCubit>().loaded();
        context.read<WorkerCubit>().getWorkers();
        await successfulDialog(context, res: response.titleCase);
        context.popView(count: 2);
      } catch (e) {
        context.read<LoadingCubit>().loaded();
        anErrorOccurredDialog(context, error: e.toString().titleCase);
      }
    }

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
                    final details = [
                      {"data": data["name"], "title": "Name"},
                      {"data": data["email"], "title": "Email"},
                      {
                        "data": data["contact_number"],
                        "title": "Contact Number"
                      },
                      {"data": data["gender"], "title": "Gender"}
                    ];

                    return ListView(children: [
                      CustomContainer(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(
                              horizontal: 22.w, vertical: 10.h),
                          padding: EdgeInsets.all(16.r),
                          child: Column(children: [
                            ContainerHeader(
                                title: LocaleKeys.confrimWorkerSDetails.tr(),
                                subTitle: LocaleKeys
                                    .pleaseTakeAMomentToConfirmTheirDetailsIncludingTheirNameEmailAddressAndContactNumberToEnsureAccuracyAndCompleteness
                                    .tr()),
                            for (var i in details)
                              _DetialsWidget(
                                data: Map.from(i),
                              )
                          ])),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _onContinue(context, data["email"]),
                          child: Text(
                            LocaleKeys.continuE.tr(),
                          ),
                        ),
                      )
                    ]);
                  },
                )),
            Visibility(
              child: LoadingWidget(title: state.msg),
              visible: isLoading,
            ),
          ]),
        );
      },
    );
  }
}

class _DetialsWidget extends StatelessWidget {
  const _DetialsWidget({
    Key? key,
    required this.data,
  }) : super(key: key);
  final Map<String, String> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          width: double.infinity,
          child: AutoSizeText(
            data["data"].toString().titleCase,
            maxLines: 1,
            textAlign: TextAlign.left,
            style: context.theme.textTheme.bodyMedium!.copyWith(
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const Divider(),
        Container(
          margin: EdgeInsets.only(bottom: 20.h),
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          width: double.infinity,
          alignment: Alignment.topLeft,
          child: Text(
            data["title"].toString(),
            textAlign: TextAlign.left,
            style: context.theme.textTheme.bodySmall!
                .copyWith(color: Colors.black38),
          ),
        ),
      ],
    );
  }
}
