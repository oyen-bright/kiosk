import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/settings.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/workers/workers_detials.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'workers_email_verification.dart';

class Workers extends StatelessWidget {
  const Workers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RefreshController _refreshController = RefreshController();
    final ScrollController _scrollController = ScrollController();

    return BlocConsumer<WorkerCubit, WorkerState>(
      listener: (context, state) async {
        if (state.status == WorkerStatus.error) {
          context.snackBar(state.error.toString());
        }
      },
      builder: (context, state) {
        final isLoading = state.status == WorkerStatus.initial;

        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Scaffold(
              appBar: customAppBar(context,
                  title: LocaleKeys.myWorkers.tr(),
                  showBackArrow: true,
                  showNewsAndPromo: false,
                  showNotifications: false,
                  showSubtitle: false,
                  actions: [
                    // IconButton(
                    //     onPressed: () {
                    //       viewOnWebOptions(context, "kiosk/my-workers/");
                    //     },
                    //     icon: Icon(
                    //       Icons.more_vert,
                    //       color: context.theme.colorScheme.primary,
                    //     ))
                  ]),
              body: Stack(
                children: [
                  SmartRefresher(
                      controller: _refreshController,
                      onRefresh: () => onRefresh(context, _refreshController),
                      child: ListView(controller: _scrollController, children: [
                        CustomContainer(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                                horizontal: 22.w, vertical: 10.h),
                            padding: EdgeInsets.all(16.r),
                            child: Column(children: [
                              ContainerHeader(
                                title: LocaleKeys.myWorkerList.tr(),
                                subTitle: LocaleKeys
                                    .inTheWorkersSectionYouCanViewACompleteListOfAllTheWorkersAssociatedWithYourShopFromThereYouHaveTheAbilityToAddNewWorkersOrDeleteExistingOnesAsWellAsViewDetailedInformationAboutEachWorkerSuchAsTheirNameContactDetailsAndWorkSchedule
                                    .tr(),
                              ),
                              Builder(builder: (_) {
                                if (isLoading) {
                                  return const LoadingWidget(
                                    isLinear: true,
                                  );
                                }
                                return Column(
                                  children: [
                                    for (var i in state.workers)
                                      _WorkerListTile(worker: i)
                                  ],
                                );
                              })
                            ])),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 10.h),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context
                                  .pushView(const WorkersEmailVerification());
                            },
                            child: Text(
                              LocaleKeys.addANewWorker.tr().toUpperCase(),
                            ),
                          ),
                        )
                      ])),
                  _buildUpgradePlayOverlay(context)
                ],
              )),
        );
      },
    );
  }

  Builder _buildUpgradePlayOverlay(BuildContext context) {
    return Builder(builder: (_) {
      final canAcess = AppSettings.isHuaweiDevice
          ? context.watch<SubscriptionHuaweiCubit>().checkAccess()
          : context.watch<SubscriptionCubit>().checkAccess();

      if (!canAcess) {
        return const UpgradePlanOverlay();
      }
      return Container();
    });
  }
}

onRefresh(BuildContext context, RefreshController _refreshController) async {
  try {
    _refreshController.isRefresh;
    await context.read<WorkerCubit>().getWorkers();
    _refreshController.refreshCompleted();
  } catch (e) {
    _refreshController.refreshFailed();
  }
}

class _WorkerListTile extends StatelessWidget {
  final Worker worker;

  const _WorkerListTile({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: ListTile(
        isThreeLine: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
        leading: Hero(
          tag: 'worker_${worker.email}',
          child: CircleAvatar(
            backgroundColor: context.theme.primaryColorLight.withOpacity(0.7),
            child: Text(
              worker.abbrevation,
              style: context.theme.textTheme.titleMedium,
            ),
          ),
        ),
        title: Text(worker.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              worker.email,
              style: context.theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.pushView(WorkerDetials(worker: worker), animate: true);
        },
      ),
    );
  }
}
