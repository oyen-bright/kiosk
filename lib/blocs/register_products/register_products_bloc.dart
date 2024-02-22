import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kiosk/cubits/product/products_cubit.dart';
import 'package:kiosk/models/product.dart';
import 'package:string_validator/string_validator.dart';

part 'register_products_event.dart';
part 'register_products_state.dart';

class RegisterProductsBloc
    extends Bloc<RegisterProductsEvent, RegisterProductsState> {
  final box = GetStorage();

  final ProductsCubit productsCubit;

  late final StreamSubscription productsCubitStream;

  RegisterProductsBloc({required this.productsCubit})
      : super(RegisterProductsInitial()) {
    productsCubitStream =
        productsCubit.stream.listen((ProductsState state) async {
      switch (state.status) {
        case ProductsStateStatus.error:
          add(ErrorProductsEvent(errorMessage: state.errorMessage));
          break;
        case ProductsStateStatus.initial:
          add(IntialProductEvent());

          break;
        case ProductsStateStatus.loaded:
          await box.write("Products", json.encode(state.products!));
          add(LoadedProductsEvent(state.products!));

          break;
        case ProductsStateStatus.loading:
          add(LoadingProductEvent());
          break;
        default:
      }
    });

    on<RefreshProductsEvent>((event, emit) async {
      emit(RegisterProductsLoading());

      if (event.checkOutCart.isEmpty) {
        final products = (json.decode(await box.read("Products")) as List)
            .map((e) => Products.fromJson(e))
            .toList();

        emit(RegisterProductsLoaded(products: products));
      } else {
        List<Map<dynamic, dynamic>> _cartProduct = event.checkOutCart;
        List<Products> _products =
            (json.decode(await box.read("Products")) as List)
                .map((e) => Products.fromJson(e))
                .toList();

        for (var cartProdcut in _cartProduct) {
          final cartProductVariation = cartProdcut["product_variation"][0];

          for (var product in _products) {
            if (product.id == cartProdcut["product"]) {
              if (isInt(cartProdcut["quantity"].toString())) {
                //Means product is not charged by weight
                product.stock =
                    (toInt(product.stock) - cartProdcut["quantity"]).toString();

                if (cartProductVariation["variations_category"] != null) {
                  for (var variation in product.productsVariation) {
                    if (variation["variations_category"] ==
                            cartProductVariation["variations_category"] &&
                        variation["variation_value"] ==
                            cartProductVariation["variation_value"]) {
                      variation["quantity"] =
                          (toInt(variation["quantity"].toString()) -
                                  cartProdcut["quantity"])
                              .toString();
                    }
                  }
                }
              } else {
                //Means product is charged by weight
                product.weightQuantity =
                    (toDouble(product.weightQuantity) - cartProdcut["quantity"])
                        .toStringAsFixed(1);

                if (cartProductVariation["variations_category"] != null) {
                  for (var variation in product.productsVariation) {
                    if (variation["variations_category"] ==
                            cartProductVariation["variations_category"] &&
                        cartProductVariation["variation_value"] ==
                            variation["variation_value"]) {
                      variation["weight_quantity"] =
                          (toDouble(variation["weight_quantity"].toString()) -
                                  cartProdcut["quantity"])
                              .toStringAsFixed(1);
                    }
                  }
                }
              }
            }
          }
        }
        emit(RegisterProductsLoaded(
          products: _products,
        ));
      }
    });

    on<LoadedProductsEvent>((event, emit) {
      emit(RegisterProductsLoaded(products: event.products));
    });

    on<ErrorProductsEvent>((event, emit) {
      emit(RegisterProductsError(errorMessage: event.errorMessage));
    });

    on<LoadingProductEvent>((_, emit) {
      emit(RegisterProductsLoading());
    });
    on<IntialProductEvent>((_, emit) {
      emit(RegisterProductsInitial());
    });

    on<LoadProductEvent>((_, emit) {
      productsCubit.getUsersProducts();
    });
  }

  @override
  Future<void> close() {
    productsCubitStream.cancel();
    return super.close();
  }
}
