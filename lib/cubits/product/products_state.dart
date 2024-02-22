// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'products_cubit.dart';

enum ProductsStateStatus { initial, loading, loaded, error }

class ProductsState extends Equatable {
  final ProductsStateStatus status;
  final String errorMessage;

  final int currentPage;
  final int pageSize;
  final int totalCount;

  final String? nextPage;
  final String? previousPage;

  final List<Products>? products;
  const ProductsState({
    this.products,
    this.currentPage = 1,
    this.totalCount = 0,
    this.pageSize = 2,
    // this.pageSize = 10,
    this.errorMessage = "",
    this.nextPage,
    this.previousPage,
    required this.status,
  });

  @override
  List<Object?> get props => [
        status,
        products,
        errorMessage,
        currentPage,
        pageSize,
        totalCount,
        nextPage,
        previousPage
      ];

  factory ProductsState.initial() {
    return const ProductsState(status: ProductsStateStatus.initial);
  }

  @override
  bool get stringify => true;

  ProductsState copyWith({
    ProductsStateStatus? status,
    String? errorMessage,
    int? currentPage,
    int? pageSize,
    int? totalCount,
    String? nextPage,
    String? previousPage,
    List<Products>? products,
  }) {
    return ProductsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      nextPage: nextPage ?? this.nextPage,
      previousPage: previousPage ?? this.previousPage,
      products: products ?? this.products,
    );
  }
}
