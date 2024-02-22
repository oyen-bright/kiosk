import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/worker.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

import 'charts.dart';

class WorkerDetials extends StatelessWidget {
  const WorkerDetials({Key? key, required this.worker}) : super(key: key);
  final Worker worker;

  @override
  Widget build(BuildContext context) {
    final RefreshController _refreshController = RefreshController();
    final ScrollController _scrollController = ScrollController();
    return BlocBuilder<LoadingCubit, LoadingState>(
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        void onPressed() async {
          try {
            context.read<LoadingCubit>().loading();
            final respons = await context
                .read<UserRepository>()
                .removeWorker(email: worker.email);
            context.read<WorkerCubit>().getWorkers();
            successfulDialog(context, res: respons);

            context.read<LoadingCubit>().loaded();
            context.popView();
          } catch (e) {
            context.read<LoadingCubit>().loaded();

            anErrorOccurredDialog(context, error: e.toString());
          }
        }

        return WillPopScope(
            onWillPop: () async => !isLoading,
            child: Stack(alignment: Alignment.topCenter, children: [
              Scaffold(
                  appBar: customAppBar(
                    context,
                    title: LocaleKeys.myWorkers.tr(),
                    subTitle: worker.name,
                    showBackArrow: true,
                    showNewsAndPromo: false,
                    showNotifications: false,
                  ),
                  body: SmartRefresher(
                      controller: _refreshController,
                      child: ListView(controller: _scrollController, children: [
                        _WorkerDetails(worker: worker),
                        Chart(
                          email: worker.email,
                        ),
                        20.h.height,
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 10.h),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () => onPressed(),
                            child: Text(
                              LocaleKeys.removeWorker.tr().toUpperCase(),
                            ),
                          ),
                        ),
                        25.h.height,
                      ]))),
              Visibility(
                child: const LoadingWidget(),
                visible: isLoading,
              ),
            ]));
      },
    );
  }
}

class Chart extends StatelessWidget {
  const Chart({
    Key? key,
    required this.email,
  }) : super(key: key);
  final String email;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<dynamic>>>(
        future: context.read<UserRepository>().getWorkerDetails(email: email),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              final data = snapshot.data!;

              final months = (data['workers_weekly_days'] as List)
                  .map((item) => item as String)
                  .toList();

              final report = data["worker_report"];

              return SizedBox(
                width: double.infinity,
                height: 350.h,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: CustomContainer(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 45.w, right: 20.w),
                      padding: EdgeInsets.all(16.r),
                      height: 400.h,
                      child: SalesLineChart(
                        months: months,
                        sales: report!,
                      )),
                ),
              );
            }
          }

          return CustomContainer(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 45.w, vertical: 10.h),
              padding: EdgeInsets.all(16.r),
              child: const LoadingWidget(
                isLinear: true,
              ));
        });
  }
}

class _WorkerDetails extends StatelessWidget {
  const _WorkerDetails({
    Key? key,
    required this.worker,
  }) : super(key: key);

  final Worker worker;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 45.w, vertical: 10.h),
        padding: EdgeInsets.all(16.r),
        child: Column(children: [
          Hero(
            tag: 'worker_${worker.email}',
            child: CircleAvatar(
              radius: 50.r,
              backgroundColor: context.theme.primaryColorLight.withOpacity(0.7),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(worker.abbrevation,
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.headlineLarge!),
              ),
            ),
          ),
          ContainerHeader(
            title: worker.name,
            subTitle: worker.email,
            centerText: true,
          ),
          _InfoWidget(
            title: LocaleKeys.joinDate.tr(),
            info: worker.joinDate.substring(0, 10),
          ),
          _InfoWidget(
            title: LocaleKeys.contact.tr(),
            info: worker.contactNumber,
          ),
          _InfoWidget(
            title: LocaleKeys.email.tr(),
            info: worker.email,
          ),
          _InfoWidget(
            title: LocaleKeys.gender.tr(),
            info: worker.gender,
          ),
          _InfoWidget(
            title: LocaleKeys.country.tr(),
            info: worker.countryOfResidence.name,
          ),
        ]));
  }
}

class _InfoWidget extends StatelessWidget {
  final String title;
  final String info;

  const _InfoWidget({Key? key, required this.title, required this.info})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 0.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title + " : ",
              style: context.theme.textTheme.bodySmall,
            ),
          ),
          Flexible(
            flex: 2,
            child: AutoSizeText(
              info,
              maxLines: 1,
              style: context.theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
