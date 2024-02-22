import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kiosk/cubits/subscription/subscription_cubit.dart';
import 'package:kiosk/cubits/subscription_huawei/subscription_huawei_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/settings.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/generate_agreement/form_felds/generat_loan_agremment.dart';
import 'package:kiosk/views/generate_agreement/form_felds/generate_sale_service_agreement.dart';
import 'package:kiosk/views/generate_agreement/form_felds/generate_share_holder_agreement.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'form_felds/generate_employee_agreement.dart';
import 'generate_pdf.dart';
import 'pdf_screen.dart';

class ViewAgreements extends StatefulWidget {
  const ViewAgreements({Key? key}) : super(key: key);

  @override
  State<ViewAgreements> createState() => _ViewAgreementsState();
}

class _ViewAgreementsState extends State<ViewAgreements> {
  String disclaimerText = '''
You can view your generated agreement below or generate new agreements for your business by selecting “GENERATE NEW AGREEMENT”.

DISCLAIMER:
The agreements generated on this platform are provided for general information purposes only and are designed to assist small businesses in protecting their interests during daily trade operations. They do not constitute legal advice or create an attorney-client relationship.

These agreements may not suit every business's specific circumstances, and it is strongly recommended that you seek independent legal advice to ensure appropriate and comprehensive legal protection tailored to your business's specific needs and context.

By using these agreements, you agree to this disclaimer and our terms of use. Always consult with a legal professional before making legal decisions.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(
          context,
          title: LocaleKeys.agreements.tr(),
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
                        title: LocaleKeys.myGeneratedAgreements.tr(),
                        subTitle: disclaimerText),
                    FutureBuilder(
                      future:
                          context.read<UserRepository>().generatedAgreements(),
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
                            final agreements = [
                              {
                                "title": LocaleKeys.shareholderAgreements.tr(),
                                "data": snapshot.data['share_agreements'] ?? [],
                                'type': AgreementType.shareHolder
                              },
                              {
                                "title": LocaleKeys.employeeAgreements.tr(),
                                "data":
                                    snapshot.data['employee_agreement'] ?? [],
                                'type': AgreementType.employee
                              },
                              {
                                "title":
                                    LocaleKeys.goodsAndServicesAgreements.tr(),
                                "data": snapshot.data['good_n_service'] ?? [],
                                'type': AgreementType.saleServiceGoods
                              },
                              {
                                "title": LocaleKeys.loanAgreements.tr(),
                                "data": snapshot.data['loans_agreements'] ?? [],
                                'type': AgreementType.loan
                              },
                            ];

                            return Column(
                              children: agreements
                                  .where((agreement) =>
                                      (agreement['data'] as List).isNotEmpty)
                                  .map((agreement) =>
                                      _WorkerListTile(data: agreement))
                                  .toList(),
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
                    final isProUser = AppSettings.isHuaweiDevice
                        ? context.read<SubscriptionHuaweiCubit>().isProUser()
                        : context.read<SubscriptionCubit>().isProUser();

                    final canAccess = AppSettings.isHuaweiDevice
                        ? context.read<SubscriptionHuaweiCubit>().checkAccess()
                        : context.read<SubscriptionCubit>().checkAccess();

                    final response =
                        await chooseAgreementTypeBottomSheet(context);

                    final msg = LocaleKeys.featureOnlyForProUsers.tr();
                    if (response != null) {
                      switch (response) {
                        case AgreementType.employee:
                          if (!canAccess) {
                            return anErrorOccurredDialog(context,
                                title: LocaleKeys.upgradeYourPlan.tr(),
                                error: msg);
                          } else {
                            await pushNewScreen(context,
                                screen: const GenerateEmployeeAgreement(),
                                withNavBar: false);
                            setState(() {});
                          }
                          break;
                        case AgreementType.shareHolder:
                          if (!isProUser) {
                            return anErrorOccurredDialog(context,
                                title: LocaleKeys.upgradeYourPlan.tr(),
                                error: msg);
                          } else {
                            await pushNewScreen(context,
                                screen: const GenerateShareHolderAgreement(),
                                withNavBar: false);

                            setState(() {});
                          }
                          break;
                        case AgreementType.saleServiceGoods:
                          if (!isProUser) {
                            return anErrorOccurredDialog(context,
                                title: LocaleKeys.upgradeYourPlan.tr(),
                                error: msg);
                          } else {
                            await pushNewScreen(context,
                                screen: const GenerateSaleServiceAgreement(),
                                withNavBar: false);
                            setState(() {});
                          }
                          break;
                        case AgreementType.loan:
                          if (!isProUser) {
                            return anErrorOccurredDialog(context,
                                title: LocaleKeys.upgradeYourPlan.tr(),
                                error: msg);
                          } else {
                            await pushNewScreen(context,
                                screen: const GenerateLoanAgreement(),
                                withNavBar: false);
                            setState(() {});
                          }
                          break;
                      }
                    }
                  },
                  child: Text(
                    LocaleKeys.generateNewAgreement.tr().toUpperCase(),
                  ),
                ),
              )
            ]),
          ],
        ));
  }
}

class _WorkerListTile extends StatefulWidget {
  final Map data;

  const _WorkerListTile({required this.data});

  @override
  _WorkerListTileState createState() => _WorkerListTileState();
}

class _WorkerListTileState extends State<_WorkerListTile> {
  List<Map<String, dynamic>> agreements = [];

  @override
  void initState() {
    agreements = List.from(widget.data['data']);
    super.initState();
  }

  void removeAgreement(int index) {
    setState(() {
      agreements.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.data['title']),
        for (var agreement in agreements)
          Card(
            elevation: 0,
            child: Slidable(
              key: ValueKey(agreements.indexOf(agreement)),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  Builder(builder: (contextB) {
                    return SlidableAction(
                      onPressed: (context1) async {
                        try {
                          await context.read<UserRepository>().deleteAgreement(
                                id: agreement["id"],
                                type: widget.data['type'],
                              );

                          removeAgreement(agreements.indexOf(agreement));
                        } catch (e) {
                          context.snackBar(e.toString());
                        }
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: LocaleKeys.delete.tr(),
                    );
                  })
                ],
              ),
              child: ListTile(
                isThreeLine: false,
                contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                leading: CircleAvatar(
                  backgroundColor:
                      context.theme.primaryColorLight.withOpacity(0.7),
                  child: Text(
                    "PDF",
                    style: context.theme.textTheme.titleMedium,
                  ),
                ),
                title:
                    Text(agreement["created_date"].toString().substring(0, 10)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agreement["id"],
                      maxLines: 1,
                      style: context.theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  pushNewScreen(
                    context,
                    screen: PdfViewScreen(
                      id: agreement["id"],
                      data: agreement,
                      type: widget.data['type'],
                    ),
                    withNavBar: false,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
