import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/constant_color.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/get_currency.dart';
import 'package:kiosk/views/item/add_item_category.dart';
import 'package:kiosk/views/register/open_register.dart';
import 'package:kiosk/views/sales/sales_details.dart';
import 'package:kiosk/views/sales/sales_report.dart';
import 'package:kiosk/views/sales/sales_seemore.dart';
import 'package:kiosk/views/stocks/stock_report.dart';
import 'package:kiosk/views/workers/workers_intro.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:kiosk/widgets/dashboard/kisok_dashboard.dart';
import 'package:kiosk/widgets/dashboard/kroon_dashboard.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

import '../business/business_report_intro.dart';
import '../invoice/generat_invoice.dart';

class KioskHome extends StatefulWidget {
  const KioskHome({Key? key}) : super(key: key);

  @override
  State<KioskHome> createState() => _KioskHomeState();
}

class _KioskHomeState extends State<KioskHome> {
  late final RefreshController _refreshController;
  late final ScrollController _scrollController;

  final List<GlobalKey> _showCaseKeysHome =
      List.generate(13, (index) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset <= -50.0) {
        _refreshController.requestRefresh();
      }
    });

    bool shouldShowIntroTour(BuildContext context) {
      return context.read<UserSettingsCubit>().state.showIntroTour["home"] ==
          true;
    }

    void showHomeIntroTour(BuildContext context) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCaseWidget.of(context).startShowCase([
          _showCaseKeysHome[0],
          _showCaseKeysHome[1],
          _showCaseKeysHome[2],
          _showCaseKeysHome[3],
          _showCaseKeysHome[4],
          _showCaseKeysHome[5],
          _showCaseKeysHome[6],
          _showCaseKeysHome[7],
          _showCaseKeysHome[8],
          _showCaseKeysHome[9],
          _showCaseKeysHome[10],
          _showCaseKeysHome[11],
          _showCaseKeysHome[12],
        ]),
      );
    }

    void hideHomeIntroTour(BuildContext context) {
      context.read<UserSettingsCubit>().changeShowIntro("home");
    }

    if (shouldShowIntroTour(context)) {
      context
          .read<ShowBottomNavCubit>()
          .toggleShowBottomNav(showNav: false, fromm: "Home");

      showHomeIntroTour(context);
      hideHomeIntroTour(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, showBackArrow: false),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: (() async {
          try {
            _refreshController.isRefresh;
            await context.read<UserCubit>().getUserDetails();
            _refreshController.refreshCompleted();
          } catch (_) {
            _refreshController.refreshFailed();
          }
        }),
        child: Column(
          children: [
            _Dashboards(showCaseKeysHome: _showCaseKeysHome),
            Expanded(
                child: ListView(
              physics: const BouncingScrollPhysics(),
              controller: _scrollController,
              children: [
                _buildMenuBottons(context),
                _buildCashRegisterButton(context),
                _buildRecentSales(),
                50.h.height
              ],
            ))
          ],
        ),
      ),
    );
  }

  Showcase _buildRecentSales() {
    return Showcase(
      key: _showCaseKeysHome[12],
      title: LocaleKeys.recentSales.tr(),
      targetBorderRadius: BorderRadius.circular(16.r),
      description: LocaleKeys
          .displaysyourlatestsalesinformationincludingordernumberandmethodofpaymentclickthesaletoseethesaledetails
          .tr(),
      child: CustomContainer(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: AutoSizeText(LocaleKeys.recentSales.tr()),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.pushView(const SeeMoreSales());
                      },
                      child: SizedBox(
                        child: AutoSizeText(
                          LocaleKeys.seeMore.tr(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            20.h.height,
            BlocConsumer<SalesCubit, SalesState>(
              listener: (context, state) {
                if (state.salesStatus == SalesStatus.error) {
                  context.snackBar(state.msg);
                }
              },
              builder: (context, state) {
                if (state.salesStatus == SalesStatus.loaded) {
                  final sales = state.sales;
                  return Column(
                    children: sales
                        .take(10)
                        .map(
                          (data) => Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: SalesWidget(
                              data: data,
                              onTap: () => context.pushView(
                                TransactionScreen(
                                  data: data,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                }
                return const LoadingWidget(
                  isLinear: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildCashRegisterButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushView(const OpenRegisterNew());
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
        child: Showcase(
          key: _showCaseKeysHome[11],
          title: LocaleKeys.cashRegister.tr(),
          targetBorderRadius: BorderRadius.circular(16.r),
          description: LocaleKeys
              .clickToSeeAllYourProductsInTheCashRegisterAndCarryOutSales
              .tr(),
          child: CustomContainer(
            alignment: Alignment.center,
            height: 60.h,
            color: const Color.fromRGBO(156, 232, 162, 1),
            padding: EdgeInsets.all(16.r),
            child: AutoSizeText(
              LocaleKeys.cashRegister.tr().toUpperCase(),
              style: TextStyle(
                  fontSize: 18, color: kioskBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  CustomContainer _buildMenuBottons(BuildContext context) {
    final isAWorker = context.read<UserCubit>().state.permissions!.isAWorker;
    return CustomContainer(
      margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
      padding: EdgeInsets.all(16.r),
      child: Builder(builder: (_) {
        if (isAWorker) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Showcase(
                key: _showCaseKeysHome[5],
                title: LocaleKeys.addItem.tr(),
                targetBorderRadius: BorderRadius.circular(16.r),
                description: LocaleKeys
                    .clicktoaddnewitemstoyourregisterselecttheitemcategoryandinputintheitemdetails
                    .tr(),
                child: MenuButton(
                  callback: () {
                    context.pushView(const AddItem());
                  },
                  title: LocaleKeys.addItem.tr(),
                  iconData: "assets/images/addItemIcon.png",
                ),
              ),
              Showcase(
                key: _showCaseKeysHome[9],
                title: LocaleKeys.generateReceipt.tr(),
                targetBorderRadius: BorderRadius.circular(16.r),
                description: LocaleKeys
                    .clickToGenerateAReceiptFromTheSalesCarriedOutYouCanShareOrViewThisRecent
                    .tr(),
                child: MenuButton(
                  callback: () {
                    context.pushView(const GenerateInvoice());
                  },
                  title: LocaleKeys.generateReceipt.tr(),
                  iconData: "assets/images/generateReceiptIcon.png",
                ),
              ),
            ],
          );
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Showcase(
                    key: _showCaseKeysHome[5],
                    title: LocaleKeys.addItem.tr(),
                    targetBorderRadius: BorderRadius.circular(16.r),
                    description: LocaleKeys
                        .clicktoaddnewitemstoyourregisterselecttheitemcategoryandinputintheitemdetails
                        .tr(),
                    child: MenuButton(
                      callback: () {
                        context.pushView(const AddItem());
                      },
                      title: LocaleKeys.addItem.tr(),
                      iconData: "assets/images/addItemIcon.png",
                    ),
                  ),
                  Showcase(
                    key: _showCaseKeysHome[6],
                    title: LocaleKeys.salesReport.tr(),
                    targetBorderRadius: BorderRadius.circular(16.r),
                    description: LocaleKeys
                        .clickToShowYourSalesReportIncludingSalesMadeByCashCardMobileMoneyAndKroonYouCanAlsoViewYourStockValue
                        .tr(),
                    child: MenuButton(
                      callback: () {
                        context.pushView(const SalesReport());
                      },
                      title: LocaleKeys.salesReport.tr(),
                      iconData: "assets/images/salesIcon.png",
                    ),
                  ),
                  Showcase(
                    key: _showCaseKeysHome[7],
                    title: LocaleKeys.inventoryReport.tr(),
                    targetBorderRadius: BorderRadius.circular(16.r),
                    description: LocaleKeys
                        .clickToShowYourInventoryReportWhichIncludesYourUploadedItemsNumberOfSoldItemsLowStockItemsAndOutOfStockItemsYouCanAlsoViewYourStockValueAndTheMostSoldItems
                        .tr(),
                    child: MenuButton(
                      callback: () {
                        context.pushView(const StockReport());
                      },
                      title: LocaleKeys.inventoryReport.tr(),
                      iconData: "assets/images/inventoryReportIcon.png",
                    ),
                  )
                ],
              ),
            ),
            15.h.height,
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Showcase(
                    key: _showCaseKeysHome[8],
                    title: LocaleKeys.myWorkers.tr(),
                    targetBorderRadius: BorderRadius.circular(16.r),
                    description: LocaleKeys
                        .clickToDddWorkersToYourStoreQuickAndEasilyCreateRemoveAndControlWorkersPrivileges
                        .tr(),
                    child: MenuButton(
                      callback: () async {
                        await context.pushView(const WorkersIntro());
                        context
                            .read<ShowBottomNavCubit>()
                            .toggleShowBottomNav(showNav: true, fromm: "Home");
                      },
                      title: LocaleKeys.myWorkers.tr(),
                      iconData: "assets/images/workersIcon.png",
                    ),
                  ),
                  Showcase(
                    key: _showCaseKeysHome[9],
                    title: LocaleKeys.generateReceipt.tr(),
                    targetBorderRadius: BorderRadius.circular(16.r),
                    description: LocaleKeys
                        .clickToGenerateAReceiptFromTheSalesCarriedOutYouCanShareOrViewThisRecent
                        .tr(),
                    child: MenuButton(
                      callback: () {
                        context.pushView(const GenerateInvoice());
                      },
                      title: LocaleKeys.generateReceipt.tr(),
                      iconData: "assets/images/generateReceiptIcon.png",
                    ),
                  ),
                  Showcase(
                    key: _showCaseKeysHome[10],
                    title: LocaleKeys.myBusinessReport.tr(),
                    targetBorderRadius: BorderRadius.circular(16.r),
                    // targetPadding: EdgeInsets.all(10.r),
                    description: LocaleKeys
                        .clickToCreateABusinessPlanForYourStoreQuicklyAndEasilyAnalyseYourBusinessPlanForYourStore
                        .tr(),
                    child: MenuButton(
                      callback: () async {
                        await context.pushView(const BuisnessPlan());
                        context
                            .read<ShowBottomNavCubit>()
                            .toggleShowBottomNav(showNav: true, fromm: "Home");
                      },
                      title: LocaleKeys.myBusinessReport.tr(),
                      iconData: "assets/images/myBusinessIcon.png",
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _Dashboards extends StatelessWidget {
  const _Dashboards({
    Key? key,
    required List<GlobalKey<State<StatefulWidget>>> showCaseKeysHome,
  })  : _showCaseKeysHome = showCaseKeysHome,
        super(key: key);

  final List<GlobalKey<State<StatefulWidget>>> _showCaseKeysHome;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        final currentUser = state.currentUser!;
        final userPermission = state.permissions!;
        final usersCurrency = getCurrency(context) + " ";

        final virtualCards = userPermission.isAWorker
            ? []
            : currentUser.virtualCards?.toList() ?? [];
        final showKroon =
            !userPermission.isAWorker && userPermission.acceptKroon;

        final itemCount = (showKroon ? 2 : 1) +
            (virtualCards.isEmpty ? 1 : virtualCards.length - 1);
        final initialPage = showKroon ? 1 : 0;

        return CarouselSlider.builder(
            itemCount: itemCount,
            itemBuilder: ((context, index, realIndex) {
              final salesReport =
                  context.watch<SalesReportCubit>().state.salesReport!;
              final stockReport = context.watch<StockReportCubit>().state;
              final showKroon =
                  userPermission.isAWorker || !userPermission.acceptKroon;

              if (showKroon) {
                switch (index) {
                  case 0:
                    return KisokDashBoard(
                      showCasekeys: _showCaseKeysHome,
                      salesReport: salesReport,
                      red: stockReport.outOfStockCount.toString(),
                      yellow: stockReport.lowOnStockCount.toString(),
                      orange: stockReport.inStockProduct.toString(),
                      currency: usersCurrency,
                    );
                }
                return ShowVirtualCards(
                  index: index,
                  virtualCards: virtualCards,
                );
              } else {
                switch (index) {
                  case 0:
                    return KroonDashboard(
                      balance: currentUser.kroonToken.toString(),
                      walletId: currentUser.walletId,
                    );

                  case 1:
                    return KisokDashBoard(
                      showCasekeys: _showCaseKeysHome,
                      salesReport: salesReport,
                      red: stockReport.outOfStockCount.toString(),
                      yellow: stockReport.lowOnStockCount.toString(),
                      orange: stockReport.inStockProduct.toString(),
                      currency: usersCurrency,
                    );
                }
                return ShowVirtualCards(
                  index: index,
                  virtualCards: virtualCards,
                );
              }
            }),
            options: CarouselOptions(
              initialPage: initialPage,
              enableInfiniteScroll: false,
              height: 220.h,
              autoPlayInterval: const Duration(seconds: 20),
              autoPlay: false,
              viewportFraction: 0.9,
              onPageChanged: (index, reason) {},
            ));
      },
    );
  }
}
