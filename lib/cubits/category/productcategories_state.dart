// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'productcategories_cubit.dart';

enum CatStatus {
  initial,
  loading,
  loaded,
  error,
}

class ProductCategoriesState extends Equatable {
  final List<Categories>? categories;
  final CatStatus status;
  final String msg;
  const ProductCategoriesState(
      {this.categories, this.status = CatStatus.initial, this.msg = ""});

  @override
  List<Object?> get props => [categories, status, msg];

  ProductCategoriesState copyWith({
    List<Categories>? categories,
    CatStatus? status,
    String? msg,
  }) {
    return ProductCategoriesState(
      categories: categories ?? this.categories,
      status: status ?? this.status,
      msg: msg ?? this.msg,
    );
  }
}
