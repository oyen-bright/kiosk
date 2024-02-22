import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/blocs/cart/cart_bloc.dart';
import 'package:kiosk/models/cart_product.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/utils/amount_formatter.dart';

part 'addtocart_state.dart';

class AddtocartCubit extends Cubit<AddtocartState> {
  CartBloc cartBloc;
  AddtocartCubit({required this.cartBloc}) : super(AddtocartState());

  void insertProduct(Products product) {
    final addtocart = AddToCart.fromProduct(product);
    addtocart.variationCategory = _getVariationCat(addtocart.productVariaion!);
    addtocart.variationType =
        _getVariationVal(product.productsVariation, categoryIndex: 0);

    emit(state.copyWith(
        isOutOfStock:
            _isOutOfStock(addtocart.prodcutStock, product.chargeByWeight),
        addToCart: addtocart,
        product: product,
        customerToPay: '0.00',
        totalStock: addtocart.prodcutStock,
        variationStock: _getVariationStock(addtocart.productVariaion!,
            addtocart.variationCategory!, addtocart.chargebyWeight, 0, 0),
        selectedCategoryindex: 0,
        selectedVariationIndex: 0,
        quantity: 0));
  }

  void switchCategoryIndex(int index) {
    final addtocart = state.addToCart!;

    addtocart.variationType = _getVariationVal(state.product!.productsVariation,
        categoryIndex: index);
    final getTotalStock = _getTotalStock(state.product!);

    emit(state.copyWith(
        customerToPay: '0.00',
        quantity: 0,
        addToCart: addtocart,
        totalStock: getTotalStock,
        isOutOfStock: _isOutOfStock(getTotalStock, addtocart.chargebyWeight),
        selectedCategoryindex: index,
        variationStock: _getVariationStock(
            addtocart.productVariaion!,
            state.addToCart!.variationCategory!,
            state.addToCart!.chargebyWeight,
            index,
            0),
        selectedVariationIndex: 0));
  }

  void switchVarationType(int index) {
    final addtocart = state.addToCart!;

    final getTotalStock = _getTotalStock(state.product!);

    emit(state.copyWith(
      isOutOfStock: _isOutOfStock(getTotalStock, addtocart.chargebyWeight),
      totalStock: getTotalStock,
      quantity: 0,
      customerToPay: '0.00',
      variationStock: _getVariationStock(
          state.addToCart!.productVariaion!,
          state.addToCart!.variationCategory!,
          state.addToCart!.chargebyWeight,
          state.selectedCategoryindex,
          index),
      selectedVariationIndex: index,
    ));
  }

  void quantityInput(String value) {
    final addtocart = state.addToCart!;
    final productPrice =
        double.parse(addtocart.productPrice.replaceAll(",", ""));

    final _value = double.tryParse(value);
    if (_value != null) {
      double customerToPay =
          double.parse(state.customerToPay.replaceAll(",", ""));
      String totalStock = _getTotalStock(state.product!);
      String variationStock = _getVariationStock(
          state.addToCart!.productVariaion!,
          state.addToCart!.variationCategory!,
          state.addToCart!.chargebyWeight,
          state.selectedCategoryindex,
          state.selectedVariationIndex)!;

      if (addtocart.productVariaion!.isEmpty) {
        if (_value <= double.parse(totalStock)) {
          totalStock =
              (double.parse(totalStock.toString()) - _value).toStringAsFixed(1);
          customerToPay = (_value * productPrice) / 1.0;
          emit(state.copyWith(
              addToCart: addtocart,
              isOutOfStock: _isOutOfStock(totalStock, addtocart.chargebyWeight),
              quantity: _value,
              customerToPay: amountFormatter(customerToPay),
              totalStock: totalStock));
        } else {
          emit(state.copyWith(quantity: 0));
        }
      } else {
        if (_value <= double.parse(variationStock)) {
          variationStock = (double.parse(variationStock.toString()) - _value)
              .toStringAsFixed(1);
          totalStock =
              (double.parse(totalStock.toString()) - _value).toStringAsFixed(1);
          customerToPay = (_value * productPrice) / 1.0;
          emit(state.copyWith(
              addToCart: addtocart,
              variationStock: variationStock,
              isOutOfStock: _isOutOfStock(totalStock, addtocart.chargebyWeight),
              quantity: _value,
              customerToPay: amountFormatter(customerToPay),
              totalStock: totalStock));
        } else {
          emit(state.copyWith(quantity: 0));
        }
      }
    }
  }

  void increaseQuantity() {
    final addtocart = state.addToCart!;
    final productPrice =
        double.parse(addtocart.productPrice.replaceAll(",", ""));

    dynamic totalStock = state.totalStock;
    dynamic variationStock = state.variationStock;
    double customerToPay =
        double.parse(state.customerToPay.replaceAll(",", ""));

    if (addtocart.productVariaion!.isEmpty) {
      if (state.addToCart!.chargebyWeight) {
        if (double.parse(totalStock.toString()) > 0.0) {
          totalStock =
              (double.parse(totalStock.toString()) - 0.1).toStringAsFixed(1);
          final quantity = double.parse(
              (double.parse(state.quantity.toString()) + 0.1)
                  .toStringAsFixed(1));

          customerToPay = (quantity * productPrice) / 1.0;

          emit(state.copyWith(
              addToCart: addtocart,
              isOutOfStock: _isOutOfStock(totalStock, addtocart.chargebyWeight),
              quantity: quantity,
              customerToPay: amountFormatter(customerToPay),
              totalStock: totalStock));
        }
      } else {
        if (int.parse(totalStock.toString()) > 0) {
          customerToPay += productPrice;
          totalStock = (int.parse(totalStock.toString()) - 1).toString();
          final quantity = int.parse(state.quantity.toString()) + 1;

          emit(state.copyWith(
              addToCart: addtocart,
              isOutOfStock: _isOutOfStock(totalStock, addtocart.chargebyWeight),
              quantity: quantity,
              customerToPay: amountFormatter(customerToPay),
              totalStock: totalStock));
        }
      }
    } else {
      if (state.addToCart!.chargebyWeight) {
        if (double.parse(totalStock.toString()) > 0 &&
            double.parse(variationStock) > 0) {
          totalStock =
              (double.parse(totalStock.toString()) - 0.1).toStringAsFixed(1);
          final quantity = double.parse(
              (double.parse(state.quantity.toString()) + 0.1)
                  .toStringAsFixed(1));
          variationStock =
              (double.parse(variationStock) - 0.1).toStringAsFixed(1);

          customerToPay = (quantity * productPrice) / 1.0;

          emit(state.copyWith(
              addToCart: addtocart,
              isOutOfStock: _isOutOfStock(totalStock, addtocart.chargebyWeight),
              quantity: quantity,
              variationStock: variationStock,
              customerToPay: amountFormatter(customerToPay),
              totalStock: totalStock));
        }
      } else {
        if (int.parse(totalStock.toString()) > 0 &&
            int.parse(variationStock) > 0) {
          customerToPay += productPrice;
          totalStock = (int.parse(totalStock.toString()) - 1).toString();
          final quantity = int.parse(state.quantity.toString()) + 1;

          //Reduce Variation Stock
          variationStock = (int.parse(variationStock) - 1).toString();

          emit(state.copyWith(
              addToCart: addtocart,
              isOutOfStock: _isOutOfStock(totalStock, addtocart.chargebyWeight),
              quantity: quantity,
              variationStock: variationStock,
              customerToPay: amountFormatter(customerToPay),
              totalStock: totalStock));
        }
      }
    }
  }

  void reduceQuantity() {
    final addtocart = state.addToCart!;
    final productPrice =
        double.parse(addtocart.productPrice.replaceAll(",", ""));

    dynamic totalStock = state.totalStock;
    dynamic variationStock = state.variationStock;
    double customerToPay =
        double.parse(state.customerToPay.replaceAll(",", ""));

//if product does not have variations
    if (addtocart.productVariaion!.isEmpty) {
      if (state.addToCart!.chargebyWeight) {
        if (double.parse(state.quantity.toString()) > 0.0) {
          totalStock =
              (double.parse(totalStock.toString()) + 0.1).toStringAsFixed(1);
          final quantity = double.parse(
              (double.parse(state.quantity.toString()) - 0.1)
                  .toStringAsFixed(1));

          customerToPay = (quantity * productPrice) / 1.0;

          emit(state.copyWith(
              addToCart: addtocart,
              isOutOfStock: _isOutOfStock(totalStock, addtocart.chargebyWeight),
              quantity: quantity,
              customerToPay: amountFormatter(customerToPay),
              totalStock: totalStock));
        }
      } else {
        if (int.parse(state.quantity.toString()) > 0) {
          customerToPay -= productPrice;
          totalStock = (int.parse(totalStock.toString()) + 1).toString();
          final quantity = int.parse(state.quantity.toString()) - 1;

          emit(state.copyWith(
              addToCart: addtocart,
              isOutOfStock: _isOutOfStock(totalStock, addtocart.chargebyWeight),
              quantity: quantity,
              customerToPay: amountFormatter(customerToPay),
              totalStock: totalStock));
        }
      }
    } else {
      if (state.addToCart!.chargebyWeight) {
        if (double.parse(state.quantity.toString()) > 0.0) {
          totalStock =
              (double.parse(totalStock.toString()) + 0.1).toStringAsFixed(1);
          final quantity = double.parse(
              (double.parse(state.quantity.toString()) - 0.1)
                  .toStringAsFixed(1));

          variationStock =
              (double.parse(variationStock) + 0.1).toStringAsFixed(1);

          customerToPay = (quantity * productPrice) / 1.0;

          emit(state.copyWith(
              addToCart: addtocart,
              isOutOfStock: _isOutOfStock(totalStock, addtocart.chargebyWeight),
              quantity: quantity,
              variationStock: variationStock,
              customerToPay: amountFormatter(customerToPay),
              totalStock: totalStock));
        }
      } else {
        if (int.parse(state.quantity.toString()) > 0) {
          customerToPay -= productPrice;
          totalStock = (int.parse(totalStock.toString()) + 1).toString();
          final quantity = int.parse(state.quantity.toString()) - 1;
          variationStock = (int.parse(variationStock) + 1).toString();

          emit(state.copyWith(
              addToCart: addtocart,
              isOutOfStock: _isOutOfStock(totalStock, addtocart.chargebyWeight),
              quantity: quantity,
              variationStock: variationStock,
              customerToPay: amountFormatter(customerToPay),
              totalStock: totalStock));
        }
      }
    }
  }

  void addProductToCart() {
    if ((double.tryParse(state.quantity.toString()) ?? 0.0) > 0.0 ||
        ((int.tryParse(state.quantity.toString()) ?? 0) > 0)) {
      Map<String, dynamic>? variationData;
      if (state.addToCart!.productVariaion!.isNotEmpty) {
        variationData = _getVariationdata(state.addToCart!.productVariaion!,
            categoryIndex: state.selectedCategoryindex,
            variationValueIndex: state.selectedVariationIndex);
      }

      final cartCheckOut = {
        "quantity": state.quantity,
        "product": state.addToCart!.productId,
        "product_variation": state.addToCart!.productVariaion!.isEmpty
            ? [
                {"variations_category": null, "variation_value": null}
              ]
            : [
                {
                  "variations_category": variationData!["variations_category"],
                  "variation_value": variationData["variation_value"]
                }
              ]
      };

      cartBloc.add(AddToCartEvent(
          productCart: ProductCart.fromAddToCart(state, variationData),
          cartCheckOut: cartCheckOut));
    }
  }
  //Methods

  bool _isOutOfStock(String stock, bool chargeByWeight) {
    bool _isOutOfStock;
    if (chargeByWeight) {
      _isOutOfStock = double.parse(stock) <= 0.00;
    } else {
      _isOutOfStock = int.parse(stock) <= 0;
    }
    return _isOutOfStock;
  }

  String _getTotalStock(Products product) {
    String? _productStock;
    if (product.chargeByWeight) {
      _productStock = product.weightQuantity.toString();
    } else {
      _productStock = product.stock.toString();
    }
    return _productStock;
  }

  List<String> _getVariationCat(List<dynamic> productsVariation) {
    List<String> variationCategory = [];
    if (productsVariation.isNotEmpty) {
      for (var variation in productsVariation) {
        if (!(variationCategory.contains(variation["variations_category"]))) {
          variationCategory.add(variation["variations_category"]);
        }
      }
    }
    return variationCategory;
  }

  String? _getVariationStock(
      List<dynamic> productsVariation,
      List<String> variationCategory,
      bool chargebyWeight,
      int selectedCategoryindex,
      int selectedVariationIndex) {
    if (productsVariation.isEmpty) {
      return "";
    }
    final selectedVariation = productsVariation
        .where((e) =>
            e["variations_category"] ==
            variationCategory[selectedCategoryindex])
        .toList()[selectedVariationIndex];
    if (chargebyWeight) {
      return selectedVariation["weight_quantity"].toString();
    }
    return selectedVariation["quantity"].toString();
  }

  List<String> _getVariationVal(List<dynamic> productsVariation,
      {required int categoryIndex}) {
    List<String> variationVal = [];
    if (productsVariation.isNotEmpty) {
      productsVariation
          .where((e) =>
              e["variations_category"] ==
              _getVariationCat(productsVariation)[categoryIndex])
          .toList()
          .forEach((element) {
        variationVal.add(element["variation_value"]);
      });
    }
    return variationVal;
  }

  Map<String, dynamic> _getVariationdata(List<dynamic> productsVariation,
      {required int categoryIndex, required int variationValueIndex}) {
    return productsVariation
        .where((e) =>
            e["variations_category"] ==
            _getVariationCat(productsVariation)[categoryIndex])
        .toList()[variationValueIndex];
  }
}
