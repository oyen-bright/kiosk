import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/generate_business_report/pdf_screen.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'generate_report.dart';

class ViewBusinessReports extends StatefulWidget {
  const ViewBusinessReports({Key? key}) : super(key: key);

  @override
  State<ViewBusinessReports> createState() => _ViewBusinessReportsState();
}

class _ViewBusinessReportsState extends State<ViewBusinessReports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(
          context,
          title: LocaleKeys.businessReport.tr(),
          showBackArrow: true,
          showNewsAndPromo: false,
          showNotifications: false,
          showSubtitle: false,
        ),
        body: Stack(
          children: [
            ListView(children: [
              CustomContainer(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    ContainerHeader(
                        title: LocaleKeys.myGeneratedBusinessReports.tr(),
                        subTitle: LocaleKeys
                            .youCanViewAllOfYourPreviouslyGeneratedBusinessReportsBelowSimplyClickOnEachPlanToViewThePdfVersion
                            .tr()),
                    FutureBuilder(
                      future: context
                          .read<UserRepository>()
                          .generatedBusinessPlans(),
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
                            return Column(
                              children: [
                                for (var i in snapshot.data)
                                  _WorkerListTile(data: i)
                              ],
                            );
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
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await pushNewScreen(context,
                        screen: const GenerateBusinessReport(),
                        withNavBar: false);
                    setState(() {});
                  },
                  child: Text(
                    LocaleKeys.generateNewReport.tr().toUpperCase(),
                  ),
                ),
              )
            ]),
          ],
        ));
  }
}

class _WorkerListTile extends StatelessWidget {
  final Map data;

  const _WorkerListTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        isThreeLine: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
        leading: CircleAvatar(
          backgroundColor: context.theme.primaryColorLight.withOpacity(0.7),
          child: Text(
            "PDF",
            style: context.theme.textTheme.titleMedium,
          ),
        ),
        title: Text(data["created_date"].toString().substring(0, 10)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data["id"],
              maxLines: 1,
              style: context.theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          pushNewScreen(context,
              screen: PdfViewScreen(id: data["id"]), withNavBar: false);
        },
      ),
    );
  }
}
