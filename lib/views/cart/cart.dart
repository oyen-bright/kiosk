import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kiosk/blocs/cart/cart_bloc.dart';
import 'package:kiosk/constants/constant_color.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/views/payment/payment_method.dart' as py;
import 'package:kiosk/views/sales/sales_refund.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';
import 'package:string_validator/string_validator.dart';

import '../register/open_register.dart';

class Cart extends StatefulWidget {
  const Cart({
    Key? key,
  }) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  late final ScrollController _scrollControllerbody;
  late final ScrollController _scrollControllerfotter;

  @override
  void initState() {
    super.initState();
    _scrollControllerfotter = ScrollController();
    _scrollControllerbody = ScrollController();

    _scrollControllerbody.addListener(() {
      if (_scrollControllerbody.offset > 0) {
        _scrollControllerfotter.jumpTo(-_scrollControllerbody.offset);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollControllerfotter.dispose();
    _scrollControllerbody.dispose();
  }

  Future<void> openAddManualSaleDialog(BuildContext context) async {
    final input = await addManualSales(context);
    if (input != null) {
      context.read<CartBloc>().add(AddManualSaleEvent(price: input));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context,
          showSubtitle: false,
          showBackArrow: false,
          sliverAppbar: false,
          title: LocaleKeys.cart.tr()),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.cartProducts.isEmpty) {
            return _buildEmptyCart(context: context);
          }
          return _buildCart(state, context);
        },
      ),
    );
  }

  Widget _buildEmptyCart({required BuildContext context}) {
    return ListView(
      children: [
        CustomContainer(
            height: 0.7.sh,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    20.h.height,
                    LogoButton(
                        title: LocaleKeys.oPENCASHREGISTER.tr(),
                        imageAddress:
                            "assets/images/cash-register-svgrepo-com.png",
                        callback: () async {
                          context.pushView(const OpenRegisterNew(
                            fromCartScreen: true,
                          ));
                        },
                        textColor: Colors.black,
                        backgroundColor: openRegister),
                    20.h.height,
                    LogoButton(
                        title: LocaleKeys.addManualSale.tr(),
                        imageAddress: "assets/images/XMLID_231_.png",
                        callback: () => openAddManualSaleDialog(context),
                        textColor: Colors.black,
                        backgroundColor: manualSaleBG),
                    20.h.height,
                    LogoButton(
                        title: LocaleKeys.refundSale.tr(),
                        imageAddress: "assets/images/refundsale.png",
                        callback: () => context.pushView(SalesRefund(
                              title: LocaleKeys.refundSale.tr(),
                            )),
                        textColor: Colors.black,
                        backgroundColor: refundBG),
                    20.h.height
                  ],
                ))
              ],
            )),
        40.h.height
      ],
    );
  }

  Widget _buildCart(CartState state, BuildContext context) {
    final List<GlobalKey> _showCaseKeysCart =
        List.generate(3, (index) => GlobalKey());

    return ShowCaseWidget(
        enableAutoScroll: true,
        onStart: (_, x) {
          context
              .read<ShowBottomNavCubit>()
              .toggleShowBottomNav(showNav: false, fromm: "Cart");
        },
        onFinish: () {
          context.read<UserSettingsCubit>().changeShowIntro("cart");
          context
              .read<ShowBottomNavCubit>()
              .toggleShowBottomNav(showNav: true, fromm: "Cart");
        },
        builder: Builder(builder: ((context) {
          if (context.read<UserSettingsCubit>().state.showIntroTour["cart"] ==
              true) {
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => ShowCaseWidget.of(context).startShowCase([
                  _showCaseKeysCart[0],
                  _showCaseKeysCart[1],
                  _showCaseKeysCart[2],
                ]),
              );
            }
          }
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    controller: _scrollControllerbody,
                    child: CustomContainer(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(
                            horizontal: 22.w, vertical: 10.h),
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          children: [
                            _clearCartButton(context),
                            5.h.height,
                            _cartItems(state, context, _showCaseKeysCart)
                          ],
                        )),
                  )),
                  50.h.height
                ],
              ),
              _cartFotter(_showCaseKeysCart, context, state),
            ],
          );
        })));
  }

  Widget _clearCartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () async {
              context.read<CartBloc>().add((ClearCartEvent()));
            },
            child: AutoSizeText(LocaleKeys.clear.tr(),
                style: context.theme.textTheme.titleSmall!
                    .copyWith(fontWeight: FontWeight.bold, color: Colors.red)),
          )
        ],
      ),
    );
  }

  Widget _cartItems(CartState state, BuildContext context,
      List<GlobalKey<State<StatefulWidget>>> _showCaseKeysCart) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(state.cartProducts.length, (index) {
        final data = state.cartProducts[index];

        final name = data.product["product_name"];
        final image = data.product['image'];
        final chargeByWeight = data.product["chargebyWeight"];
        final quantity = data.quantity;
        final variation = data.product["product_variation"];

        final displayData = {
          "name": name,
          "count": (image == "MN" || chargeByWeight)
              ? image == "MN"
                  ? "X 1"
                  : data.product["Weight_quantity"].toString() +
                      " " +
                      data.product["Weight_unit"]
              : quantity.toString(),
          "variation": (variation == null
              ? data.product["product_sku"] ?? ""
              : variation["variation_value"] ?? ""),
          "cartItemSale": !(image == "MN" || chargeByWeight),
          "productPrice": amountFormatter(double.parse(data.product[
                  image == "MN" || chargeByWeight ? "price" : "productPrice"]
              .toString()
              .replaceAll(",", "")))
        };

        final cartProduct = state.cartProducts[index];
        Widget getCartProductImageUrl(ProductCart cartProduct) {
          if (cartProduct.product['image'] == "MN") {
            return Center(
              child: Text(
                "MS",
                style: TextStyle(color: kioskBlue),
              ),
            );
          } else if (cartProduct.product["image"].isEmpty) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.asset(
                "assets/images/empty.jpg",
                fit: BoxFit.cover,
              ),
            );
          } else {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: CachedNetworkImage(
                imageUrl: cartProduct.product['image'],
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SpinKitFoldingCube(color: kioskBlue),
                  ),
                ),
                errorWidget: (context, url, error) => const SizedBox(),
              ),
            );
          }
        }

        final itemSale = ItemSale(
          slideActionOnpressed: (_) async {
            try {
              state.cartProducts.removeAt(index);
              context.read<CartBloc>().add(RemoveCartItemEvent(
                  productId: cartProduct.id,
                  productVariation: cartProduct.product["product_variation"]));
            } catch (_) {}
          },
          name: displayData["name"],
          count: displayData["count"],
          variation: displayData["variation"],
          cartItemSale: displayData["cartItemSale"],
          price: displayData["productPrice"],
          imageUrl: getCartProductImageUrl(cartProduct),
          currency: getCurrency(context),
          decrease: () =>
              context.read<CartBloc>().add(DecreaseCountCartEvent(cartProduct)),
          increase: () =>
              context.read<CartBloc>().add(IncreaseCountCartEvent(cartProduct)),
        );

        if (index == 0) {
          return Showcase(
            key: _showCaseKeysCart[0],
            child: itemSale,
            title: LocaleKeys.item.tr(),
            targetBorderRadius: BorderRadius.circular(16.r),
            description: LocaleKeys
                .showthenameoftheiteminthecartpriceandquantityyoucanincreaseordecreasethequantitywiththeplusandminusicons
                .tr(),
          );
        }
        return itemSale;
      }),
    );
  }

  Widget _cartFotter(List<GlobalKey<State<StatefulWidget>>> _showCaseKeysCart,
      BuildContext context, CartState state) {
    return SingleChildScrollView(
      controller: _scrollControllerfotter,
      child: Column(
        children: [
          _cartActions(_showCaseKeysCart, state),
          _cartItemsDetails(context, state)
        ],
      ),
    );
  }

  CustomContainer _cartItemsDetails(BuildContext context, CartState state) {
    return CustomContainer(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 0.h),
      padding: EdgeInsets.all(16.r),
      color: context.theme.primaryColorLight,
      height: 90.h,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: AutoSizeText(
                LocaleKeys.totalAmount.tr(),
                style: context.theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )),
              Expanded(
                  child: AutoSizeText(
                getCurrency(context) + " " + state.totalAmount.toString(),
                style: context.theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ))
            ],
          ),
          5.h.height,
          Row(
            children: [
              Expanded(
                  child: AutoSizeText(
                LocaleKeys.totalItems.tr(),
                style: context.theme.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )),
              Expanded(
                  child: AutoSizeText(
                state.quantityCount.toString(),
                style: context.theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.right,
              ))
            ],
          ),
        ],
      ),
    );
  }

  Widget _cartActions(List<GlobalKey<State<StatefulWidget>>> _showCaseKeysCart,
      CartState state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      margin: EdgeInsets.only(bottom: 10.h),
      width: 1.sw,
      height: 50.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Showcase(
              key: _showCaseKeysCart[1],
              title: LocaleKeys.addManualSale.tr(),
              targetBorderRadius: BorderRadius.circular(16.r),
              description:
                  LocaleKeys.clickToAddManualSaleWithTheItemsInTheCart.tr(),
              child: LogoButton(
                  imageHeight: 35.w,
                  title: LocaleKeys.addManualSale.tr(),
                  imageAddress: "assets/images/XMLID_231_.png",
                  callback: () => openAddManualSaleDialog(context),
                  textColor: Colors.black,
                  backgroundColor: manualSaleBG),
            ),
          ),
          10.w.width,
          Expanded(
            child: Showcase(
              key: _showCaseKeysCart[2],
              title: LocaleKeys.completeSale.tr(),
              targetBorderRadius: BorderRadius.circular(16.r),
              description: LocaleKeys
                  .clickToProceedAndCompleteThisSaleWithAllTheItemInTheCart
                  .tr(),
              child: LogoButton(
                  imageHeight: 35.w,
                  title: LocaleKeys.completeSale.tr(),
                  imageAddress: "assets/images/cash-register-svgrepo-com.png",
                  callback: () {
                    if (toDouble(state.totalAmount.replaceAll(",", "")) > 0) {
                      pushNewScreen(context,
                          screen: const py.PaymentMethod(), withNavBar: false);
                    }
                  },
                  textColor: Colors.black,
                  backgroundColor: completeSaleBG),
            ),
          ),
          // 10.w.width,
          // SizedBox(
          //   width: 0.4.sw,
          //   child: LogoButton(
          //       title: LocaleKeys.refundSale.tr(),
          //       imageAddress: "assets/images/refundsale.png",
          //       callback: () => context.pushView(SalesRefund(
          //             title: LocaleKeys.refundSale.tr(),
          //           )),
          //       textColor: Colors.black,
          //       backgroundColor: refundBG),
          // ),
        ],
      ),
    );
  }
}
