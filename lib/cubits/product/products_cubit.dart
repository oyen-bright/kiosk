import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/repositories/product_repository.dart';

part 'products_state.dart';

/// A Cubit responsible for managing product-related state and actions.
class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository productRepository;

  ProductsCubit({
    required this.productRepository,
  }) : super(ProductsState.initial()) {
    getUsersProducts();
  }

  final queryParameters = {
    'page_size': "50",
  };

  /// Fetches the user's products from the repository.
  ///
  /// [isRefresh] indicates whether this is a refresh operation.
  Future<void> getUsersProducts({bool isRefresh = false}) async {
    // If not a refresh, update the state to indicate loading.
    isRefresh
        ? null
        : emit(state.copyWith(status: ProductsStateStatus.loading));
    try {
      final _products =
          await productRepository.getProducts(queryParameters: queryParameters);
      emit(state.copyWith(
        status: ProductsStateStatus.loaded,
        products: (_products['products'] as List<dynamic>).cast<Products>(),
        nextPage: _products['next_page'],
        previousPage: _products['prev_page'],
        totalCount: _products['total_count'] as int,
      ));
    } catch (e) {
      // Handle any errors and update the state accordingly.
      emit(state.copyWith(
          status: ProductsStateStatus.error, errorMessage: e.toString()));
    }
  }

  /// Fetches the next page of products.
  ///
  /// [total] is the total number of products currently loaded.
  Future<List<Products>> nextPage(int total) async {
    try {
      if (state.nextPage != null) {
        final productsResponse = await productRepository.getProducts(
          nextPage: state.nextPage,
        );

        emit(state.copyWith(
          status: ProductsStateStatus.loaded,
          products: [
            ...state.products!,
            ...(productsResponse['products'] as List<dynamic>).cast<Products>()
          ],
          nextPage: productsResponse['next_page'],
          previousPage: productsResponse['prev_page'],
          totalCount: productsResponse['total_count'] as int,
        ));
        return (productsResponse['products'] as List<dynamic>).cast<Products>();
      }
      return [];
    } catch (e) {
      // Handle any errors and update the state accordingly.
      emit(state.copyWith(
          status: ProductsStateStatus.error, errorMessage: e.toString()));

      rethrow;
    }
  }

  /// Clears the product-related state.
  void clear() {
    emit(ProductsState.initial());
  }
}
