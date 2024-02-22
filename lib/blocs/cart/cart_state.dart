// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'cart_bloc.dart';

class CartState extends Equatable {
  final int cartCounter;
  final int quantityCount;
  final String totalAmount;
  final List<Map<dynamic, dynamic>> checkOutCart;

  final List<ProductCart> cartProducts;
  const CartState({
    required this.checkOutCart,
    this.cartCounter = 0,
    this.quantityCount = 0,
    required this.totalAmount,
    required this.cartProducts,
  });

  @override
  List<Object> get props =>
      [totalAmount, cartProducts, checkOutCart, cartCounter, quantityCount];

  @override
  bool get stringify => true;

  factory CartState.initial() {
    return CartState(
        cartCounter: 0,
        totalAmount: amountFormatter(0),
        cartProducts: const [],
        checkOutCart: const []);
  }

  CartState copyWith({
    int? cartCounter,
    int? quantityCount,
    String? totalAmount,
    List<Map<dynamic, dynamic>>? checkOutCart,
    List<ProductCart>? cartProducts,
  }) {
    return CartState(
      cartCounter: cartCounter ?? this.cartCounter,
      quantityCount: quantityCount ?? this.quantityCount,
      totalAmount: totalAmount ?? this.totalAmount,
      checkOutCart: checkOutCart ?? this.checkOutCart,
      cartProducts: cartProducts ?? this.cartProducts,
    );
  }
}
