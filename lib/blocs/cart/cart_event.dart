// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class IncreaseCountCartEvent extends CartEvent {
  final ProductCart productCart;

  const IncreaseCountCartEvent(this.productCart);
  @override
  List<Object> get props => [productCart];
}

class DecreaseCountCartEvent extends CartEvent {
  final ProductCart productCart;
  const DecreaseCountCartEvent(this.productCart);
  @override
  List<Object> get props => [productCart];
}

class AddToCartEvent extends CartEvent {
  final ProductCart productCart;
  final Map<String, dynamic> cartCheckOut;
  const AddToCartEvent({
    required this.productCart,
    required this.cartCheckOut,
  });
  @override
  List<Object> get props => [productCart, cartCheckOut];
}

class RemoveCartItemEvent extends CartEvent {
  final String productId;
  final Map<String, dynamic>? productVariation;
  const RemoveCartItemEvent({
    required this.productVariation,
    required this.productId,
  });
  @override
  List<Object?> get props => [productId, productVariation];
}

class AddManualSaleEvent extends CartEvent {
  final String price;
  const AddManualSaleEvent({
    required this.price,
  });

  @override
  List<Object?> get props => [price];
}

class CheckOutEvent extends CartEvent {
  final String checkOUtMethod;
  final String? cashReceived;
  final String? paymentRef;
  final String? customersChange;

  const CheckOutEvent(
      {required this.checkOUtMethod,
      this.cashReceived,
      this.customersChange,
      this.paymentRef});
  @override
  List<Object?> get props =>
      [checkOUtMethod, cashReceived, customersChange, paymentRef];
}

class ClearCartEvent extends CartEvent {}
