// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'register_products_bloc.dart';

abstract class RegisterProductsEvent extends Equatable {
  const RegisterProductsEvent();

  @override
  List<Object> get props => [];
}

class LoadedProductsEvent extends RegisterProductsEvent {
  final List<Products> products;

  const LoadedProductsEvent(this.products);
  @override
  List<Object> get props => [products];
}

class ErrorProductsEvent extends RegisterProductsEvent {
  final String errorMessage;
  const ErrorProductsEvent({
    required this.errorMessage,
  });

  @override
  List<Object> get props => [errorMessage];
}

class RefreshProductsEvent extends RegisterProductsEvent {
  final List<Map<dynamic, dynamic>> checkOutCart;

  const RefreshProductsEvent(this.checkOutCart);
  @override
  List<Object> get props => [checkOutCart];
}

class IntialProductEvent extends RegisterProductsEvent {}

class LoadingProductEvent extends RegisterProductsEvent {}

class LoadProductEvent extends RegisterProductsEvent {}
