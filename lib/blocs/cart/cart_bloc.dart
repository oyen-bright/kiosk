import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/blocs/register_products/register_products_bloc.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/cubits/sales/sales_report/sales_report_cubit.dart';
import 'package:kiosk/models/cart_product.dart';
import 'package:kiosk/repositories/product_repository.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';
import 'package:kiosk/utils/amount_formatter.dart';
import 'package:string_validator/string_validator.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final LoadingCubit loadingCubit;
  final SalesReportCubit salesReportCubit;
  final ProductRepository productRepository;
  final LocalStorage localStorage;
  final RegisterProductsBloc registerProductsBloc;

  CartBloc(
      {required this.registerProductsBloc,
      required this.loadingCubit,
      required this.salesReportCubit,
      required this.localStorage,
      required this.productRepository})
      : super(CartState.initial()) {
    /// Event handler for adding a product to the cart.
    ///
    /// Handles the logic of adding a product to the cart based on the event data.
    /// Updates the cart products and checkout cart based on whether the product
    /// is already in the cart or not.
    ///
    /// Parameters:
    /// - [event]: The AddToCartEvent containing the product information to be added to the cart.
    /// - [emit]: A function used to emit the updated state after cart manipulation.
    on<AddToCartEvent>((event, emit) {
      List<ProductCart> _cartProduct =
          state.cartProducts; // Current cart products
      List<Map<dynamic, dynamic>> _checkOutCart =
          state.checkOutCart; // Current checkout cart

      bool inCartAlready =
          false; // Flag to track if the product is already in the cart

      // Loop through existing cart products to check if the added product is already in the cart
      for (var element in _cartProduct) {
        if (element.id == event.productCart.id) {
          if (element.product["product_variation"] != null) {
            if (element.product["product_variation"]["variations_category"] ==
                    event.productCart.product["product_variation"]
                        ["variations_category"] &&
                element.product["product_variation"]["variation_value"] ==
                    event.productCart.product["product_variation"]
                        ["variation_value"]) {
              // If the variation matches, update the quantity and price
              element.quantity += event.productCart.quantity;
              inCartAlready = true;
              element.product["price"] = (double.parse(element.product["price"]
                      .toString()
                      .replaceAll(",", ""))) +
                  (double.parse(event.productCart.product["price"]
                      .toString()
                      .replaceAll(",", "")));
            }
          } else {
            // If no variation, update the quantity and price
            element.quantity += event.productCart.quantity;
            inCartAlready = true;
            element.product["price"] = (double.parse(
                    element.product["price"].toString().replaceAll(",", ""))) +
                (double.parse(event.productCart.product["price"]
                    .toString()
                    .replaceAll(",", "")));
          }
        }
      }

      // If the product is not already in the cart, add it to both cart and checkout cart
      if (!inCartAlready) {
        final _newCartProduct = [..._cartProduct, event.productCart];
        final _newCheckOutCart = [..._checkOutCart, event.cartCheckOut];

        // Emit the updated state with the new cart information
        emit(state.copyWith(
            quantityCount: _calculateQuantity(_newCartProduct),
            cartProducts: _newCartProduct,
            checkOutCart: _newCheckOutCart,
            cartCounter: _newCartProduct.length,
            totalAmount:
                amountFormatter(_calculateTotalAmount(_newCartProduct))));
      } else {
        // If the product is already in the cart, update the checkout cart quantities
        for (var element in _checkOutCart) {
          if (element["product"] == event.productCart.id) {
            if (element["product_variation"][0]["variations_category"] !=
                null) {
              if (element["product_variation"][0]["variations_category"] ==
                      event.productCart.product["product_variation"]
                          ["variations_category"] &&
                  element["product_variation"][0]["variation_value"] ==
                      event.productCart.product["product_variation"]
                          ["variation_value"]) {
                // Update checkout cart quantity if the variation matches
                element["quantity"] += event.cartCheckOut["quantity"];
              }
            } else {
              // Update checkout cart quantity without variation
              element["quantity"] += event.cartCheckOut["quantity"];
            }
          }
        }

        // Emit the updated state with the modified cart information
        emit(state.copyWith(
            quantityCount: _calculateQuantity(_cartProduct),
            cartProducts: _cartProduct,
            checkOutCart: _checkOutCart,
            cartCounter: _cartProduct.length,
            totalAmount: amountFormatter(_calculateTotalAmount(_cartProduct))));
      }
    });

    /// Event handler to clear the cart and reset to initial state.
    ///
    /// Clears all products from the cart and sets the cart state to its initial state.
    /// Emits the initial state to clear the cart.
    on<ClearCartEvent>((_, emit) {
      emit(CartState.initial()); // Emit the initial state to clear the cart
    });

    /// Event handler to increase the count of a product in the cart.
    ///
    /// Handles the logic of increasing the count of a specific product in the cart
    /// based on the event data. Updates the checkout cart and emits the updated
    /// cart state after the increase in product count.
    ///
    /// Parameters:
    /// - [event]: The IncreaseCountCartEvent containing the product information for
    ///   which the count needs to be increased.
    /// - [emit]: A function used to emit the updated cart state after count increase.
    on<IncreaseCountCartEvent>(
      (event, emit) {
        List<ProductCart> _cartProduct =
            state.cartProducts; // Current cart products
        List<Map<dynamic, dynamic>> _checkOutCart =
            state.checkOutCart; // Current checkout cart
        ProductCart _currentProduct =
            event.productCart; // Product for which count is increased

        // Loop through existing cart products to find the product to increase count
        for (var product in _cartProduct) {
          if (product.id == event.productCart.id) {
            if (_currentProduct.product["product_variation"] != null) {
              if (_currentProduct.product["product_variation"]
                          ["variations_category"] ==
                      product.product["product_variation"]
                          ["variations_category"] &&
                  _currentProduct.product["product_variation"]
                          ["variation_value"] ==
                      product.product["product_variation"]["variation_value"]) {
                final _currentCartProduct = product.product;

                // Check if conditions allow increasing the count for the product
                if (!(_currentCartProduct['image'] == "MN" ||
                    _currentCartProduct["chargebyWeight"] == true)) {
                  // Increase the count of the product in the checkout cart
                  _increaseCartProductCount(
                      product, _checkOutCart, _currentProduct.id);

                  // Emit the updated state with increased count
                  emit(state.copyWith(
                      quantityCount: _calculateQuantity(_cartProduct),
                      cartProducts: _cartProduct,
                      totalAmount: amountFormatter(
                          _calculateTotalAmount(_cartProduct))));
                }
              }
            } else {
              final _currentCartProduct = product.product;

              // Check if conditions allow increasing the count for the product
              if (!(_currentCartProduct['image'] == "MN" ||
                  _currentCartProduct["chargebyWeight"] == true)) {
                // Increase the count of the product in the checkout cart
                _increaseCartProductCount(
                    product, _checkOutCart, _currentProduct.id);

                // Emit the updated state with increased count
                emit(state.copyWith(
                    quantityCount: _calculateQuantity(_cartProduct),
                    cartProducts: _cartProduct,
                    totalAmount:
                        amountFormatter(_calculateTotalAmount(_cartProduct))));
              }
            }
          }
        }
      },
    );

    /// Event handler to decrease the count of a product in the cart.
    ///
    /// Handles the logic of decreasing the count of a specific product in the cart
    /// based on the event data. Updates the checkout cart and emits the updated
    /// cart state after the decrease in product count.
    ///
    /// Parameters:
    /// - [event]: The DecreaseCountCartEvent containing the product information for
    ///   which the count needs to be decreased.
    /// - [emit]: A function used to emit the updated cart state after count decrease.
    on<DecreaseCountCartEvent>((event, emit) {
      List<ProductCart> _cartProduct =
          state.cartProducts; // Current cart products
      List<Map<dynamic, dynamic>> _checkOutCart =
          state.checkOutCart; // Current checkout cart
      ProductCart _currentProduct =
          event.productCart; // Product for which count is decreased

      // Loop through existing cart products to find the product to decrease count
      for (var product in _cartProduct) {
        if (product.id == event.productCart.id) {
          if (_currentProduct.product["product_variation"] != null) {
            if (_currentProduct.product["product_variation"]
                        ["variations_category"] ==
                    product.product["product_variation"]
                        ["variations_category"] &&
                _currentProduct.product["product_variation"]
                        ["variation_value"] ==
                    product.product["product_variation"]["variation_value"]) {
              final _currentCartProduct = product.product;

              // Check if conditions allow decreasing the count for the product
              if (!(_currentCartProduct['image'] == "MN" ||
                  _currentCartProduct["chargebyWeight"] == true)) {
                // Decrease the count of the product in the checkout cart
                _decreaseCartProductCount(
                    product, _checkOutCart, _currentProduct.id);

                // Emit the updated state with decreased count
                emit(state.copyWith(
                    quantityCount: _calculateQuantity(_cartProduct),
                    cartProducts: _cartProduct,
                    totalAmount:
                        amountFormatter(_calculateTotalAmount(_cartProduct))));
              }
            }
          } else {
            final _currentCartProduct = product.product;

            // Check if conditions allow decreasing the count for the product
            if (!(_currentCartProduct['image'] == "MN" ||
                _currentCartProduct["chargebyWeight"] == true)) {
              // Decrease the count of the product in the checkout cart
              _decreaseCartProductCount(
                  product, _checkOutCart, _currentProduct.id);

              // Emit the updated state with decreased count
              emit(state.copyWith(
                  quantityCount: _calculateQuantity(_cartProduct),
                  cartProducts: _cartProduct,
                  totalAmount:
                      amountFormatter(_calculateTotalAmount(_cartProduct))));
            }
          }
        }
      }
    });

    /// Event handler to remove a cart item from the cart.
    ///
    /// Handles the logic of removing a specific cart item from the cart and checkout
    /// cart based on the event data. Updates the cart state and emits the updated
    /// state after the removal of the cart item.
    ///
    /// Parameters:
    /// - [event]: The RemoveCartItemEvent containing the product information for
    ///   the cart item to be removed.
    /// - [emit]: A function used to emit the updated cart state after item removal.
    on<RemoveCartItemEvent>((event, emit) {
      List<ProductCart> _cartProduct = []; // New cart products after removal
      List<Map<dynamic, dynamic>> _checkOutCart =
          []; // New checkout cart after removal

      // Filter the cart products to exclude the one to be removed
      _cartProduct = state.cartProducts.where((element) {
        if (element.id == event.productId) {
          final elementVariation = element.product["product_variation"];
          final productVariation = event.productVariation;

          if (productVariation != null) {
            if (elementVariation["variation_value"] ==
                    productVariation["variation_value"] &&
                elementVariation["variations_category"] ==
                    productVariation["variations_category"]) {
              return false; // Exclude the cart item to be removed
            }
          } else {
            return false; // Exclude the cart item to be removed
          }
        }

        return true;
      }).toList();

      // Filter the checkout cart to exclude the cart item to be removed
      _checkOutCart = state.checkOutCart.where((element) {
        if (element["product"] == event.productId) {
          final elementVariation = element["product_variation"][0];
          final productVariation = event.productVariation;

          if (productVariation != null) {
            if (elementVariation["variation_value"] ==
                    productVariation["variation_value"] &&
                elementVariation["variations_category"] ==
                    productVariation["variations_category"]) {
              return false; // Exclude the cart item from checkout cart
            }
          } else {
            return false; // Exclude the cart item from checkout cart
          }
        }
        return true;
      }).toList();

      // Emit the updated cart state after removing the cart item
      emit(state.copyWith(
          quantityCount: _calculateQuantity(_cartProduct),
          cartCounter: _cartProduct.length,
          cartProducts: _cartProduct,
          checkOutCart: _checkOutCart,
          totalAmount: amountFormatter(_calculateTotalAmount(_cartProduct))));
    });

    /// Event handler to manually add a sale to the cart.
    ///
    /// Handles the logic of adding a manual sale to the cart based on the event data.
    /// Updates the cart products with the manual sale or modifies the price of an
    /// existing manual sale in the cart. Emits the updated cart state after adding
    /// or modifying the manual sale.
    ///
    /// Parameters:
    /// - [event]: The AddManualSaleEvent containing the information about the manual sale.
    /// - [emit]: A function used to emit the updated cart state after manual sale addition/modification.
    on<AddManualSaleEvent>((event, emit) {
      if (event.price.isNotEmpty) {
        final price = event.price;
        bool inCartAlready =
            false; // Flag to track if manual sale is already in cart
        List<ProductCart> _cartProduct =
            state.cartProducts; // Current cart products
        List<ProductCart> _newCartProduct =
            state.cartProducts; // New cart products after modification

        // Iterate through cart products to find and modify the manual sale if already in cart
        for (var productCart in _cartProduct) {
          if (productCart.id == "kioskManualSale") {
            inCartAlready = true;

            // Modify the price of the existing manual sale
            productCart.product["price"] = (toDouble(productCart
                        .product["price"]
                        .toString()
                        .replaceAll(",", "")) +
                    toDouble(price))
                .toString();
          }
        }

        // If manual sale is not already in cart, create a new productCart for it
        if (!inCartAlready) {
          final productCart = ProductCart(
              id: "kioskManualSale",
              cart: "cart",
              quantity: 1,
              user: "user",
              product: {
                "stock": 1,
                "productPrice": price,
                "price": price,
                "product_sku": "Manual Sale",
                "product_name": "Manual Sale",
                "image": "MN"
              });
          _newCartProduct = [..._cartProduct, productCart];
        }

        // Emit the updated cart state after manual sale addition/modification
        emit(state.copyWith(
            quantityCount: _calculateQuantity(
                inCartAlready ? _cartProduct : _newCartProduct),
            cartProducts: inCartAlready ? _cartProduct : _newCartProduct,
            totalAmount: amountFormatter(_calculateTotalAmount(
                inCartAlready ? _cartProduct : _newCartProduct))));
      }
      return; // Return after processing the event
    });

    /// Event handler for the checkout process.
    ///
    /// Handles the logic of checking out products from the cart. Performs the checkout
    /// by communicating with the product repository, updating the cart state, and
    /// triggering additional actions such as loading products, updating sales reports,
    /// and clearing the cart.
    ///
    /// Parameters:
    /// - [event]: The CheckOutEvent containing the information needed for the checkout process.
    /// - [emit]: A function used to emit updated cart and loading states during the checkout.
    on<CheckOutEvent>((event, emit) async {
      try {
        loadingCubit
            .loading(); // Indicate that the checkout process has started

        // Perform the checkout process and retrieve the order ID
        String orderId = await productRepository.checkOutProducts(
            myCartCheckOUt: state.checkOutCart,
            checkOut: generateCheckOut(event));

        loadingCubit.loaded(
            message: orderId); // Indicate successful checkout with order ID

        RegisterProductsState _state = registerProductsBloc.state;

        if (_state is RegisterProductsLoaded) {
          // Convert product data to JSON format for storage
          final List<dynamic> jsonProduct =
              (_state.products.map((data) => data.toJson()).toList());

          final data = localStorage.readUserProducts();

          Map fetchedData = json.decode(data!);
          fetchedData['results'] = jsonProduct;

          // Update user products data in local storage
          await localStorage.writeUserProducts(json.encode(fetchedData));
        }

        registerProductsBloc
            .add(LoadProductEvent()); // Load updated product data

        salesReportCubit.getSaleReport(); // Update the sales report

        add(ClearCartEvent()); // Clear the cart after successful checkout
      } catch (e) {
        loadingCubit.error(
            message: e.toString()); // Indicate error during checkout
      }
    });
  }

  /// Generates the checkout details in the form of a map.
  ///
  /// Creates a map containing checkout details such as transaction references,
  /// payment method, amount paid, cash collected, manual sale details, and
  /// whether a manual sale is included in the checkout.
  ///
  /// Parameters:
  /// - [event]: The CheckOutEvent containing the payment and checkout information.
  ///
  /// Returns:
  /// A Map containing the checkout details for the transaction.
  Map<String, dynamic> generateCheckOut(CheckOutEvent event) {
    // Check if manualSale is part of the cart product
    String manualSaleAmount = "0.00";
    String paymentMethod = event.checkOUtMethod;
    bool isManualSale = false;

    final totalAmount = _calculateTotalAmount(state.cartProducts);

    for (var cartProduct in state.cartProducts) {
      if (cartProduct.id == "kioskManualSale") {
        isManualSale = true;

        final price =
            cartProduct.product["price"].toString().replaceAll(",", "");
        manualSaleAmount = double.tryParse(price)?.toStringAsFixed(2) ?? price;
      }
    }

    if (paymentMethod == "kroon_token") {
      return {
        "kroon_transaction_ref": event.paymentRef,
        "payment_method": paymentMethod,
        "amount_paid": totalAmount.toStringAsFixed(2),
        "cash_collected": event.cashReceived ?? "0.00",
        "customers_change": event.customersChange ?? "0.00",
        "manual_sale": manualSaleAmount,
        "is_manual_sale": isManualSale,
      };
    }
    return {
      "payment_method": paymentMethod,
      "amount_paid": totalAmount.toStringAsFixed(2),
      "cash_collected": event.cashReceived ?? "0.00",
      "customers_change": event.customersChange ?? "0.00",
      "manual_sale": manualSaleAmount,
      "is_manual_sale": isManualSale,
    };
  }

  /// Calculates the total amount for the given cart products.
  ///
  /// Iterates through the list of cart products and calculates the total amount
  /// by summing up the prices of all products.
  ///
  /// Parameters:
  /// - [_cartProduct]: List of ProductCart objects representing the cart products.
  ///
  /// Returns:
  /// The total amount of the cart products.
  double _calculateTotalAmount(List<ProductCart> _cartProduct) {
    double totalAmount = 0.0;
    for (var product in _cartProduct) {
      totalAmount +=
          double.parse(product.product["price"].toString().replaceAll(",", ""));
    }
    return totalAmount;
  }

  /// Calculates the total quantity count for the given cart products.
  ///
  /// Iterates through the list of cart products and calculates the total quantity
  /// count by summing up the quantities of all products. If a product's quantity
  /// is 0, it is counted as 1.
  ///
  /// Parameters:
  /// - [_cartProduct]: List of ProductCart objects representing the cart products.
  ///
  /// Returns:
  /// The total quantity count of the cart products.
  int _calculateQuantity(List<ProductCart> _cartProduct) {
    int quantityCount = 0;
    for (var element in _cartProduct) {
      quantityCount += element.quantity == 0 ? 1 : element.quantity;
    }
    return quantityCount;
  }

  void _increaseCartProductCount(ProductCart data,
      List<Map<dynamic, dynamic>> _checkOutCart, String productId) {
    RegisterProductsState _state = registerProductsBloc.state;
    int currentQuantity = 0;
    double productPrice = 0.0;

    _increase() {
      List<Map<dynamic, dynamic>> _checkOutCart = state.checkOutCart;

      if (currentQuantity > 0) {
        data.quantity += 1;

        productPrice = double.parse(
            data.product["productPrice"].toString().replaceAll(",", ""));
        data.product["price"] =
            toDouble(data.product["price"].toString().replaceAll(",", "")) +
                productPrice;

        for (var element in _checkOutCart) {
          if (element["product"] == productId) {
            if (element["product_variation"][0]["variations_category"] !=
                null) {
              if (element["product_variation"][0]["variations_category"] ==
                      data.product["product_variation"]
                          ["variations_category"] &&
                  element["product_variation"][0]["variation_value"] ==
                      data.product["product_variation"]["variation_value"]) {
                element["quantity"] += 1;
              }
            } else {
              element["quantity"] += 1;
            }
          }
        }
      }
    }

    if (_state is RegisterProductsLoaded) {
      final registerProduct = _state.products
          .where((element) => element.id == productId)
          .toList()[0];

      if (data.product["product_variation"] == null) {
        currentQuantity = int.parse(registerProduct.stock);

        _increase();
      } else {
        final cartProductVarCat =
            data.product["product_variation"]["variations_category"];
        final cartProductVarVal =
            data.product["product_variation"]["variation_value"];

        final variation = registerProduct.productsVariation
            .where((element) =>
                element["variations_category"] == cartProductVarCat &&
                element["variation_value"] == cartProductVarVal)
            .toList()[0];

        currentQuantity = int.parse(variation["quantity"].toString());
        _increase();
      }
    }
  }

  void _decreaseCartProductCount(ProductCart data,
      List<Map<dynamic, dynamic>> _checkOutCart, String productId) {
    double productPrice = 0.0;

    List<Map<dynamic, dynamic>> _checkOutCart = state.checkOutCart;

    if (data.quantity >= 2) {
      data.quantity -= 1;
      productPrice = double.parse(
          data.product["productPrice"].toString().replaceAll(",", ""));
      data.product["price"] =
          toDouble(data.product["price"].toString().replaceAll(",", "")) -
              productPrice;

      for (var element in _checkOutCart) {
        if (element["product"] == productId) {
          if (element["product_variation"][0]["variations_category"] != null) {
            if (element["product_variation"][0]["variations_category"] ==
                    data.product["product_variation"]["variations_category"] &&
                element["product_variation"][0]["variation_value"] ==
                    data.product["product_variation"]["variation_value"]) {
              element["quantity"] -= 1;
            }
          } else {
            element["quantity"] -= 1;
          }
        }
      }
    }
  }
}
