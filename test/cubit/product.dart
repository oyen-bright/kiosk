import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/cubits/products/products_cubit.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/models/products_state.dart';
import 'package:kiosk/repositories/product_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  group('ProductsCubit', () {
    late ProductsCubit productsCubit;
    late MockProductRepository mockProductRepository;

    setUp(() {
      mockProductRepository = MockProductRepository();
      productsCubit = ProductsCubit(productRepository: mockProductRepository);
    });

    tearDown(() {
      productsCubit.close();
    });

    test('initial state is ProductsState.initial()', () {
      expect(productsCubit.state, equals(ProductsState.initial()));
    });

    blocTest<ProductsCubit, ProductsState>(
      'emits correct states when fetching products succeeds',
      build: () {
        when(() => mockProductRepository.getProducts(
                queryParameters: any(named: 'queryParameters')))
            .thenAnswer((_) async => {
                  'products': [
                    Products(id: '1', name: 'Product 1'),
                    Products(id: '2', name: 'Product 2'),
                  ],
                  'next_page': null,
                  'prev_page': null,
                  'total_count': 2,
                });
        return productsCubit;
      },
      act: (cubit) => cubit.getUsersProducts(),
      expect: () => [
        ProductsState.initial(status: ProductsStateStatus.loading),
        ProductsState.loaded(
          status: ProductsStateStatus.loaded,
          products: [
            Products(id: '1', name: 'Product 1'),
            Products(id: '2', name: 'Product 2'),
          ],
          nextPage: null,
          previousPage: null,
          totalCount: 2,
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'emits correct states when fetching products fails',
      build: () {
        when(() => mockProductRepository.getProducts(
                queryParameters: any(named: 'queryParameters')))
            .thenThrow(Exception('Error fetching products'));
        return productsCubit;
      },
      act: (cubit) => cubit.getUsersProducts(),
      expect: () => [
        ProductsState.initial(status: ProductsStateStatus.loading),
        ProductsState.error(
          status: ProductsStateStatus.error,
          errorMessage: 'Exception: Error fetching products',
        ),
      ],
    );
  });
}
