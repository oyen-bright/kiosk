import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/blocs/cart/cart_bloc.dart';
import 'package:kiosk/blocs/cart_register_product/cart_register_product_bloc.dart';
import 'package:kiosk/blocs/register_products/register_products_bloc.dart';

void main() {
  group('CartRegisterProductBloc', () {
    late CartBloc cartBloc;
    late RegisterProductsBloc registerProductsBloc;
    late CartRegisterProductBloc cartRegisterProductBloc;

    setUp(() {
      cartBloc = CartBloc(
        loadingCubit: LoadingCubit(),
        salesReportCubit: SalesReportCubit(),
        productRepository: ProductRepository(),
        localStorage: LocalStorage(),
        registerProductsBloc: RegisterProductsBloc(),
      );

      registerProductsBloc = RegisterProductsBloc();
      cartRegisterProductBloc = CartRegisterProductBloc(
        cartBloc: cartBloc,
        registerProductsBloc: registerProductsBloc,
      );
    });

    tearDown(() {
      cartBloc.close();
      registerProductsBloc.close();
      cartRegisterProductBloc.close();
    });

    test('initial state is CartRegisterProductInitial', () {
      expect(
          cartRegisterProductBloc.state, equals(CartRegisterProductInitial()));
    });

    blocTest<CartRegisterProductBloc, CartRegisterProductState>(
      'emits [CartRegisterProductInitial] when closed',
      build: () => cartRegisterProductBloc,
      close: () => cartRegisterProductBloc.close(),
      expect: () => [CartRegisterProductInitial()],
    );

    blocTest<CartRegisterProductBloc, CartRegisterProductState>(
      'listens to CartBloc stream and dispatches RefreshProductsEvent to RegisterProductsBloc',
      build: () => cartRegisterProductBloc,
      act: (bloc) => bloc.add(CartRegisterProductEvent()),
      expect: () => [],
      verify: (_) {
        // Simulate emitting a new state from CartBloc
        cartBloc.add(AddToCartEvent(
          productCart: ProductCart(
            id: '1',
            cart: 'cart',
            quantity: 1,
            user: 'user',
            product: {
              'id': '1',
              'name': 'Product 1',
              'price': '10.00',
            },
          ),
          cartCheckOut: {'product': '1', 'quantity': 1},
        ));
        // Expect that RefreshProductsEvent is dispatched to RegisterProductsBloc
        expect(
          registerProductsBloc,
          emits(isA<RefreshProductsEvent>()),
        );
      },
    );
  });
}
