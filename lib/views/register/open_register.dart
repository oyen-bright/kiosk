import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/blocs/cart/cart_bloc.dart';
import 'package:kiosk/blocs/register_products/register_products_bloc.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/get_currency.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

import 'search_page.dart';

//Todo; remove drag and drop grid view

class OpenRegisterNew extends StatefulWidget {
  final bool fromCartScreen;

  const OpenRegisterNew({Key? key, this.fromCartScreen = false})
      : super(key: key);

  @override
  State<OpenRegisterNew> createState() => _OpenRegisterNewState();
}

class _OpenRegisterNewState extends State<OpenRegisterNew> {
  late final ScrollController _scrollController;
  late final RefreshController _refreshController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _refreshController = RefreshController();

    final productCubit = context.read<ProductsCubit>();

    if (productCubit.state.products == null) {
      productCubit.getUsersProducts();
    }

    // context
    //     .read<AnalyticsService>()
    //     .logOpenCashRegister({"time": DateTime.now().toLocal().toString()});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int variableSet = 0;

    return BlocConsumer<RegisterProductsBloc, RegisterProductsState>(
      listener: (context, state) async {
        if (state is RegisterProductsError) {
          await anErrorOccurredDialog(context, error: state.errorMessage);
          context.read<RegisterProductsBloc>().add(LoadProductEvent());
        }

        if (state is RegisterProductsInitial) {
          context.read<RegisterProductsBloc>().add(LoadProductEvent());
        }
      },
      builder: (context, state) {
        if (state is RegisterProductsLoading) {
          return Container(
              color: context.theme.scaffoldBackgroundColor,
              child: const LoadingWidget());
        }

        if (state is RegisterProductsInitial) {
          return Container(
              color: context.theme.scaffoldBackgroundColor,
              child: const LoadingWidget());
        }

        if (state is RegisterProductsError) {
          return Container(
              color: context.theme.scaffoldBackgroundColor,
              child: const LoadingWidget());
        }

        if (state is RegisterProductsLoaded) {
          return Scaffold(
            appBar: customAppBar(context,
                showSubtitle: false,
                title: LocaleKeys.register.tr(),
                actions: [
                  IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        context.pushView(const SearchRegister());
                      },
                      icon: Icon(
                        Icons.search,
                        color: context.theme.colorScheme.primary,
                      )),
                ],
                showBackArrow: true),
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: BalanceDisplayLarge(
                    currency: getCurrency(context),
                    value: context.watch<CartBloc>().state.totalAmount,
                    title: LocaleKeys.customerToPay.tr(),
                  ),
                ),
                Expanded(
                  child: _buildRegisterProduct(
                      variableSet, state, _scrollController),
                ),
                10.h.height
              ],
            ),
          );
        }
        return Container();
      },
    );
  }

  Container _buildRegisterProduct(
    int variableSet,
    RegisterProductsLoaded state,
    ScrollController _scrollController,
  ) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Center(
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: (() async {
            await context
                .read<ProductsCubit>()
                .getUsersProducts(isRefresh: true);
            context.read<CartBloc>().add((ClearCartEvent()));
            _refreshController.refreshCompleted();
          }),
          child: GridView.builder(
              physics: const ScrollPhysics(),
              itemCount: context.read<ProductsCubit>().state.totalCount >
                      state.products.length
                  ? state.products.length + 1
                  : state.products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 3 / 3.9.h,
              ),
              itemBuilder: (context, index) {
                final productState = context.read<ProductsCubit>().state;

                if (productState.totalCount > state.products.length &&
                    index == state.products.length) {
                  return Center(
                    child: Builder(builder: (context) {
                      bool isLoading = false;
                      return StatefulBuilder(builder: (context, setState) {
                        if (isLoading) {
                          return const CircularProgressIndicator();
                        }
                        return TextButton(
                            onPressed: () async {
                              setState(
                                () => isLoading = true,
                              );
                              await context
                                  .read<ProductsCubit>()
                                  .nextPage(state.products.length);
                              setState(
                                () => isLoading = false,
                              );
                            },
                            child: const Text("Load More"));
                      });
                    }),
                  );
                }
                bool isOutOfStock = false;

                final data = state.products[index];

                if (data.chargeByWeight) {
                  double.parse(data.weightQuantity) <= 0.0
                      ? isOutOfStock = true
                      : isOutOfStock = false;
                } else {
                  int.parse(data.stock) <= 0
                      ? isOutOfStock = true
                      : isOutOfStock = false;
                }

                final itemKey = UniqueKey();

                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                  child: RegisterItem(
                    key: itemKey,
                    isOutOfStock: isOutOfStock,
                    callback: () async {
                      context.read<AddtocartCubit>().insertProduct(data);

                      await viewProductDialog(
                        context,
                        data,
                      );

                      if (widget.fromCartScreen &&
                          context
                                  .read<UserSettingsCubit>()
                                  .state
                                  .showIntroTour["cart"] ==
                              true) {
                        context.popView();
                      }
                    },
                    data: data,
                  ),
                );
              }),
        ),
      ),
    );
  }
}
