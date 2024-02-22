import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/offline/offline_cubit.dart';
import 'package:kiosk/cubits/stock/stock_report_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/theme/orange_theme.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/inventory/inventory_edit_item.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

//TODO:addd pull down to refresh

class AllProduct extends StatelessWidget {
  const AllProduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final offlineMode = context.watch<OfflineCubit>().isOffline();

    return Scaffold(
        appBar: customAppBar(context,
            title: LocaleKeys.allProduct.tr(),
            showNewsAndPromo: false,
            showSubtitle: false,
            showNotifications: false,
            actions: [
              IconButton(
                onPressed: () {
                  context.pushView(const _SearchPage());
                },
                icon: Icon(
                  Icons.search,
                  color: context.theme.colorScheme.primary,
                ),
                padding: EdgeInsets.zero,
              )
            ],
            showBackArrow: true),
        body: ListView(
          children: [
            Scrollbar(
                child: CustomContainer(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
              padding: EdgeInsets.all(16.r),
              child: BlocBuilder<StockReportCubit, StockReportState>(
                builder: (context, state) {
                  if (state.allProduct != null) {
                    final allProduct = state.allProduct;
                    return Column(
                      children: [
                        ContainerHeader(
                            title: LocaleKeys.allProduct.tr(),
                            subTitle: LocaleKeys
                                .aCompleteListOfEveryItemYouHaveAvailableForSaleInYourInventoryTapToEditProductAndManageInventoryLevelsToEnsureThatYouAlwaysHaveTheProductsYourCustomersWant
                                .tr()),
                        for (var product in allProduct!)
                          StockReportAllProduct(
                            data: product,
                            callback: () {
                              offlineMode
                                  ? offlineDialog(context)
                                  : context.pushView(EditItemInInventory(
                                      product: product,
                                    ));
                            },
                          )
                      ],
                    );
                  }

                  return Column(children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: AutoSizeText(LocaleKeys.allProduct.tr()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const LoadingWidget(
                      isLinear: true,
                    )
                  ]);
                },
              ),
            )),
            40.h.height
          ],
        ));
  }
}

class _SearchPage extends StatefulWidget {
  const _SearchPage({
    Key? key,
  }) : super(key: key);

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final bool? _isSearching = true;
  List<Products> searchresult = [];
  List<Products> allProduct = [];

  @override
  void initState() {
    allProduct = context.read<StockReportCubit>().state.allProduct!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final offlineMode = context.watch<OfflineCubit>().isOffline();

    return Scaffold(
        backgroundColor: kioskGrayBGColor(context),
        appBar: AppBar(
          backgroundColor: context.theme.canvasColor,
          titleSpacing: -4,
          title: Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: TextFormField(
              controller: _controller,
              autofocus: true,
              onChanged: searchOperation,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(top: 10),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.clear,
                  ),
                  onPressed: () {
                    _controller.clear();
                    searchresult.clear();
                    setState(() {});
                  },
                ),
                hintText: LocaleKeys.searchByProductName.tr() + '..',
              ),
            ),
          ),
          leading: const AppBarBackButton(),
          elevation: 0,
        ),
        body: ListView.builder(
          shrinkWrap: true,
          itemCount: searchresult.length,
          itemBuilder: (BuildContext context, int index) {
            Products data = searchresult[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: StockReportAllProduct(
                data: data,
                callback: () async {
                  offlineMode
                      ? offlineDialog(context)
                      : await context.pushView(
                          EditItemInInventory(
                            product: data,
                          ),
                          animate: true);
                  setState(() {});
                },
              ),
            );
          },
        ));
  }

  void searchOperation(String searchText) {
    searchresult.clear();
    if (_isSearching != null) {
      for (int i = 0; i < allProduct.length; i++) {
        String data = allProduct[i].productName;
        if (data.toLowerCase().contains(searchText.toLowerCase())) {
          searchresult.add(allProduct[i]);
          setState(() {});
        }
      }
    }
  }
}
