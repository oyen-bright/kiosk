import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/blocs/cart/cart_bloc.dart';
import 'package:kiosk/blocs/register_products/register_products_bloc.dart';

part 'cart_register_product_event.dart';
part 'cart_register_product_state.dart';

//TODO: consider cartbloc listen to register product

class CartRegisterProductBloc
    extends Bloc<CartRegisterProductEvent, CartRegisterProductState> {
  final CartBloc cartBloc;
  final RegisterProductsBloc registerProductsBloc;

  late final StreamSubscription cartBlocSubscription;
  // late final StreamSubscription registerProductsBlocSubscription;
  CartRegisterProductBloc(
      {required this.cartBloc, required this.registerProductsBloc})
      : super(CartRegisterProductInitial()) {
    cartBlocSubscription = cartBloc.stream.listen((CartState event) {
      registerProductsBloc.add(RefreshProductsEvent(event.checkOutCart));
    });
  }
  @override
  Future<void> close() {
    cartBlocSubscription.cancel();
    // registerProductsBlocSubscription.cancel();
    return super.close();
  }
}
