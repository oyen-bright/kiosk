// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'register_products_bloc.dart';

abstract class RegisterProductsState extends Equatable {
  const RegisterProductsState();

  @override
  List<Object> get props => [];
}

class RegisterProductsLoaded extends RegisterProductsState {
  final List<Products> products;
  const RegisterProductsLoaded({
    required this.products,
  });
  @override
  List<Object> get props => [products];

  RegisterProductsLoaded copyWith({
    List<Products>? products,
  }) {
    return RegisterProductsLoaded(
      products: products ?? this.products,
    );
  }
}

class RegisterProductsInitial extends RegisterProductsState {}

class RegisterProductsLoading extends RegisterProductsState {}

class RegisterProductsError extends RegisterProductsState {
  final String errorMessage;
  const RegisterProductsError({
    required this.errorMessage,
  });

  @override
  List<Object> get props => [errorMessage];

  RegisterProductsError copyWith({
    String? errorMessage,
  }) {
    return RegisterProductsError(
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
