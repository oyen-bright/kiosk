import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/cubits/product/products_cubit.dart';
import 'package:kiosk/blocs/register_products/register_products_bloc.dart';
import 'package:kiosk/models/product.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsCubit extends Mock implements ProductsCubit {}

void main() {
  group('RegisterProductsBloc', () {
    late RegisterProductsBloc registerProductsBloc;
    late ProductsCubit mockProductsCubit;

    setUp(() {
      mockProductsCubit = MockProductsCubit();
      registerProductsBloc =
          RegisterProductsBloc(productsCubit: mockProductsCubit);
    });

    tearDown(() {
      registerProductsBloc.close();
    });

    test('initial state is RegisterProductsInitial', () {
      expect(registerProductsBloc.state, equals(RegisterProductsInitial()));
    });

    blocTest<RegisterProductsBloc, RegisterProductsState>(
      'emits [RegisterProductsLoading, RegisterProductsLoaded] when RefreshProductsEvent is added',
      build: () => registerProductsBloc,
      act: (bloc) {
        when(() => mockProductsCubit.stream)
            .thenAnswer((_) => Stream.fromIterable([
                  ProductsState(ProductsStateStatus.loaded, products: [
                    Product(id: '1', name: 'Product 1', price: '10.00')
                  ]),
                ]));
        bloc.add(const RefreshProductsEvent([]));
      },
      expect: () => [
        RegisterProductsLoading(),
        RegisterProductsLoaded(
            products: [Product(id: '1', name: 'Product 1', price: '10.00')]),
      ],
    );

    blocTest<RegisterProductsBloc, RegisterProductsState>(
      'emits [RegisterProductsLoading, RegisterProductsLoaded] when LoadedProductsEvent is added',
      build: () => registerProductsBloc,
      act: (bloc) {
        bloc.add(LoadedProductsEvent(
            products: [Product(id: '1', name: 'Product 1', price: '10.00')]));
      },
      expect: () => [
        RegisterProductsLoading(),
        RegisterProductsLoaded(
            products: [Product(id: '1', name: 'Product 1', price: '10.00')]),
      ],
    );

    // Add more tests to cover other scenarios as needed
  });
}
