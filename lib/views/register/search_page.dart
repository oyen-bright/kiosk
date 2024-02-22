import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/blocs/register_products/register_products_bloc.dart';
import 'package:kiosk/cubits/cart/addtocart_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/theme/orange_theme.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';

class SearchRegister extends StatefulWidget {
  const SearchRegister({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchRegister> createState() => _SearchRegisterState();
}

class _SearchRegisterState extends State<SearchRegister> {
  late final TextEditingController _controller;
  List<Products> searchresult = [];
  List<Products> productList = [];

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isSearching = false;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterProductsBloc, RegisterProductsState>(
      listener: (context, state) async {
        if (state is RegisterProductsError) {
          context.snackBar(state.errorMessage);
          context.read<RegisterProductsBloc>().add(LoadProductEvent());
        }

        if (state is RegisterProductsInitial) {
          context.read<RegisterProductsBloc>().add(LoadProductEvent());
        }
      },
      builder: (context, state) {
        if (state is RegisterProductsLoaded) {
          final productList = state.products;

          void searchOperation(String searchText) {
            if (_controller.text.isEmpty) {
              setState(() {
                _isSearching = false;
              });
            } else {
              setState(() {
                _isSearching = true;
              });
            }
            searchresult.clear();
            if (_isSearching != false) {
              for (int i = 0; i < productList.length; i++) {
                String data = productList[i].productName;
                if (data.toLowerCase().contains(searchText.toLowerCase())) {
                  searchresult.add(productList[i]);
                  setState(() {});
                }
              }
            }
          }

          return Scaffold(
              backgroundColor: kioskGrayBGColor(context),
              appBar: AppBar(
                  elevation: 0,
                  backgroundColor: context.theme.canvasColor,
                  leading: const AppBarBackButton(),
                  titleSpacing: -4,
                  title: Padding(
                    padding: EdgeInsets.only(right: 5.w),
                    child: TextField(
                      autofocus: true,
                      onChanged: searchOperation,
                      controller: _controller,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 10.h),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              searchresult.clear();
                            },
                          ),
                          hintText: LocaleKeys.searchByProductName.tr() + '..',
                          border: InputBorder.none),
                    ),
                  )),
              body: OrientationBuilder(builder: (context, orientation) {
                return _buildBody();
              }));
        }

        return Container();
      },
    );
  }

  Container _buildBody() {
    return Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(top: 10.h),
        child: ListView.builder(
            itemCount: searchresult.length,
            itemBuilder: (BuildContext context, int index) {
              Products data = searchresult[index];

              return GestureDetector(
                onTap: (() async {
                  // context.read<AddtocartCubit>().insertProduct(data);

                  // await viewProductDialog(
                  //   context,
                  //   data,
                  // );
                  // searchresult.clear();
                }),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: StockReportAllProduct(
                      callback: () async {
                        context.read<AddtocartCubit>().insertProduct(data);

                        await viewProductDialog(
                          context,
                          data,
                        );
                        searchresult.clear();
                        // final offlineMode =
                        //     context.read<OfflineCubit>().isOffline();

                        // if (offlineMode) {
                        //   offlineDialog(context);
                        // } else {
                        //   await Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => EditItemInInventory(
                        //                 product: data,
                        //               )));
                        //   searchresult.clear();
                        // }
                      },
                      data: data),
                ),
              );
            }));
  }
}
