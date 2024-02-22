import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/models/categories.dart';
import 'package:kiosk/repositories/product_repository.dart';

part 'productcategories_state.dart';

/// A Cubit (State Management) class to handle product categories.
class ProductCategoriesCubit extends Cubit<ProductCategoriesState> {
  final ProductRepository productRepository;

  ProductCategoriesCubit({
    required this.productRepository,
  }) : super(const ProductCategoriesState()) {
    // Load product categories when the Cubit is created.
    loadCategories();
  }

  /// Load product categories from the repository.
  void loadCategories() async {
    try {
      // Notify the UI that categories are loading.
      emit(state.copyWith(status: CatStatus.loading));

      // Fetch categories from the repository.
      final categories = await productRepository.getUsersCategories();

      // Notify the UI that categories have been loaded successfully.
      emit(state.copyWith(status: CatStatus.loaded, categories: categories));
    } catch (e) {
      // Notify the UI that an error occurred while loading categories.
      emit(state.copyWith(status: CatStatus.error, msg: e.toString()));
    }
  }
}
