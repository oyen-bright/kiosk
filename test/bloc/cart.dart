import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/blocs/cart/cart_bloc.dart';

void main() {
  group('CartBloc', () {
    late CartBloc cartBloc;

    setUp(() {
      cartBloc = CartBloc(
        loadingCubit: LoadingCubit(),
        salesReportCubit: SalesReportCubit(),
        productRepository: ProductRepository(),
        localStorage: LocalStorage(),
        registerProductsBloc: RegisterProductsBloc(),
      );
    });

    test('Initial state is CartState.initial()', () {
      expect(cartBloc.state, equals(CartState.initial()));
    });

    test('Adding a product to the cart updates the state correctly', () {
      final productCart = ProductCart(
        id: '1',
        cart: 'cart',
        quantity: 1,
        user: 'user',
        product: {
          'id': '1',
          'name': 'Product 1',
          'price': '10.00',
        },
      );
      final addToCartEvent = AddToCartEvent(
        productCart: productCart,
        cartCheckOut: {'product': '1', 'quantity': 1},
      );

      cartBloc.add(addToCartEvent);

      expect(
        cartBloc.state.cartProducts,
        contains(productCart),
      );
      expect(
        cartBloc.state.checkOutCart,
        contains({'product': '1', 'quantity': 1}),
      );
      expect(
        cartBloc.state.totalAmount,
        equals('10.00'),
      );
    });

    test('Clearing the cart resets the state to initial', () {
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

      expect(cartBloc.state.cartProducts, isNotEmpty);
      expect(cartBloc.state.checkOutCart, isNotEmpty);

      cartBloc.add(ClearCartEvent());

      expect(cartBloc.state, equals(CartState.initial()));
    });

    test('Increasing the count of a product updates the state correctly', () {
      final productCart = ProductCart(
        id: '1',
        cart: 'cart',
        quantity: 1,
        user: 'user',
        product: {
          'id': '1',
          'name': 'Product 1',
          'price': '10.00',
        },
      );
      final increaseCountEvent = IncreaseCountCartEvent(productCart);

      cartBloc.add(AddToCartEvent(
        productCart: productCart,
        cartCheckOut: {'product': '1', 'quantity': 1},
      ));
      cartBloc.add(increaseCountEvent);

      expect(
        cartBloc.state.cartProducts.first.quantity,
        equals(2),
      );
      expect(
        cartBloc.state.totalAmount,
        equals('20.00'),
      );
    });

    test('Decreasing the count of a product updates the state correctly', () {
      final productCart = ProductCart(
        id: '1',
        cart: 'cart',
        quantity: 2,
        user: 'user',
        product: {
          'id': '1',
          'name': 'Product 1',
          'price': '10.00',
        },
      );
      final decreaseCountEvent = DecreaseCountCartEvent(productCart);

      cartBloc.add(AddToCartEvent(
        productCart: productCart,
        cartCheckOut: {'product': '1', 'quantity': 2},
      ));
      cartBloc.add(decreaseCountEvent);

      expect(
        cartBloc.state.cartProducts.first.quantity,
        equals(1),
      );
      expect(
        cartBloc.state.totalAmount,
        equals('10.00'),
      );
    });

    test('Removing a cart item updates the state correctly', () {
      final productCart = ProductCart(
        id: '1',
        cart: 'cart',
        quantity: 1,
        user: 'user',
        product: {
          'id': '1',
          'name': 'Product 1',
          'price': '10.00',
        },
      );
      const removeCartItemEvent = RemoveCartItemEvent(
        productId: '1',
        productVariation: null,
      );

      cartBloc.add(AddToCartEvent(
        productCart: productCart,
        cartCheckOut: {'product': '1', 'quantity': 1},
      ));
      cartBloc.add(removeCartItemEvent);

      expect(cartBloc.state.cartProducts, isEmpty);
      expect(cartBloc.state.checkOutCart, isEmpty);
      expect(cartBloc.state.totalAmount, equals('0.00'));
    });

    test('Adding a manual sale updates the state correctly', () {
      const addManualSaleEvent = AddManualSaleEvent(price: '15.00');

      cartBloc.add(addManualSaleEvent);

      expect(
        cartBloc.state.cartProducts.first.id,
        equals('kioskManualSale'),
      );
      expect(
        cartBloc.state.totalAmount,
        equals('15.00'),
      );
    });

    test('Generating checkout details returns correct map', () {
      const checkOutEvent = CheckOutEvent(
        checkOUtMethod: 'cash',
        paymentRef: '123456',
        cashReceived: '20.00',
        customersChange: '5.00',
      );

      final checkoutDetails = cartBloc.generateCheckOut(checkOutEvent);

      expect(
        checkoutDetails,
        equals({
          'payment_method': 'cash',
          'amount_paid': '0.00', // Total amount is not calculated in this test
          'cash_collected': '20.00',
          'customers_change': '5.00',
          'manual_sale': '0.00',
          'is_manual_sale': false,
        }),
      );
    });
  });
}
