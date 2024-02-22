// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:kiosk/cubits/cart/addtocart_cubit.dart';

class ProductCart {
  String id;
  Map product;

  int quantity;
  String user;
  String? cart;

  ProductCart(
      {required this.id,
      required this.cart,
      required this.quantity,
      required this.user,
      required this.product});

  factory ProductCart.fromJson(Map<String, dynamic> json) {
    try {
      return ProductCart(
        id: json["id"],
        product: json['product'] ?? {},
        cart: json['cart'],
        quantity: json['quantity'],
        user: json['user'].toString(),
      );
    } catch (e) {
      return ProductCart(
        id: "i",
        product: {},
        cart: "cart",
        quantity: 1,
        user: "user",
      );
    }
  }

  factory ProductCart.fromAddToCart(
      AddtocartState addtocartState, Map<String, dynamic>? variationdata) {
    final state = addtocartState;
    final product = {
      "chargebyWeight": state.addToCart!.chargebyWeight,
      "stock": state.addToCart!.chargebyWeight
          ? state.product!.weightQuantity
          : state.product!.stock,
      "productPrice": state.addToCart!.productPrice,
      "price": state.customerToPay,
      "product_sku": state.product!.productSku,
      "product_name": state.addToCart!.productName,
      "image": state.addToCart!.productImage,
      "product_variation": variationdata,
      "Weight_unit": state.product!.weightUnit,
      "Weight_quantity": state.addToCart!.chargebyWeight ? state.quantity : null
    };

    return ProductCart(
        id: state.addToCart!.productId,
        cart: "Cart",
        quantity: int.tryParse(state.quantity.toString()) ?? 0,
        user: "user",
        product: product);
  }

  @override
  String toString() {
    return 'ProductCart(id: $id, product: $product, quantity: $quantity, user: $user, cart: $cart)';
  }
}
