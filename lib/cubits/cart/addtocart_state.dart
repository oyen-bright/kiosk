// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'addtocart_cubit.dart';

// ignore: must_be_immutable
class AddtocartState extends Equatable {
  bool isOutOfStock;
  AddToCart? addToCart;
  Products? product;
  dynamic totalStock;
  String? variationStock;
  String customerToPay;
  int selectedVariationIndex;
  dynamic quantity;
  int selectedCategoryindex;
  AddtocartState({
    this.addToCart,
    this.isOutOfStock = false,
    this.product,
    this.quantity = 0,
    this.totalStock,
    this.variationStock,
    this.selectedCategoryindex = 0,
    this.customerToPay = '0.00',
    this.selectedVariationIndex = 0,
  });

  @override
  List<Object?> get props => [
        isOutOfStock,
        addToCart,
        product,
        selectedCategoryindex,
        selectedVariationIndex,
        quantity,
        totalStock,
        variationStock,
        customerToPay
      ];

  @override
  bool get stringify => true;

  AddtocartState copyWith({
    bool? isOutOfStock,
    AddToCart? addToCart,
    Products? product,
    dynamic totalStock,
    String? variationStock,
    String? customerToPay,
    int? selectedVariationIndex,
    dynamic quantity,
    int? selectedCategoryindex,
  }) {
    return AddtocartState(
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      addToCart: addToCart ?? this.addToCart,
      product: product ?? this.product,
      totalStock: totalStock ?? this.totalStock,
      variationStock: variationStock ?? this.variationStock,
      customerToPay: customerToPay ?? this.customerToPay,
      selectedVariationIndex:
          selectedVariationIndex ?? this.selectedVariationIndex,
      quantity: quantity ?? this.quantity,
      selectedCategoryindex:
          selectedCategoryindex ?? this.selectedCategoryindex,
    );
  }
}

class AddToCart {
  String productId;
  String productImage;
  String productPrice;
  String prodcutStock;
  String productName;

  bool chargebyWeight;
  String weightUnit;
  List<String>? variationCategory;
  List<String>? variationType;
  String customerToPay;
  List<dynamic>? productVariaion;
  Map<String, dynamic> displayData;

  String quantity;
  AddToCart({
    required this.chargebyWeight,
    required this.weightUnit,
    required this.productName,
    required this.displayData,
    required this.productId,
    required this.productImage,
    required this.productPrice,
    required this.prodcutStock,
    this.variationCategory,
    this.variationType,
    required this.customerToPay,
    required this.productVariaion,
    required this.quantity,
  });

  factory AddToCart.fromProduct(Products product) {
    String? _productStock;
    if (product.chargeByWeight) {
      _productStock = product.weightQuantity.toString();
    } else {
      _productStock = product.stock.toString();
    }

    return AddToCart(
        productId: product.id,
        chargebyWeight: product.chargeByWeight,
        weightUnit: product.weightUnit,
        productName: product.productName,
        productImage: product.image,
        productPrice: amountFormatter(double.parse(product.price)),
        prodcutStock: _productStock,
        customerToPay: amountFormatter(0),
        productVariaion: product.productsVariation,
        displayData: {},
        quantity: 0.toString());
  }
}
