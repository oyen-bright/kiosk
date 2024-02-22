.import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_package_name/product_repository.dart'; // Import your ProductRepository class

class MockUserServices extends Mock implements UserServices {}

void main() {
  group('ProductRepository', () {
    late ProductRepository productRepository;
    late MockUserServices mockUserServices;

    setUp(() {
      mockUserServices = MockUserServices();
      productRepository = ProductRepository(userServices: mockUserServices);
    });

    test('getProducts returns a Map with product data', () async {
      final mockResponse = {'products': []};
      when(mockUserServices.getUsersProducts(any, any)).thenAnswer((_) async => mockResponse);

      final response = await productRepository.getProducts();

      expect(response, isA<Map<String, dynamic>>());
      expect(response['products'], isA<List>());
    });

    test('checkOutProducts returns an order ID', () async {
      when(mockUserServices.addProductsToCart(any)).thenAnswer((_) async {});
      when(mockUserServices.checkOutProducts(any, any)).thenAnswer((_) async => 'test_order_id');

      final orderId = await productRepository.checkOutProducts(
        myCartCheckOUt: [],
        checkOut: {},
      );

      expect(orderId, 'test_order_id');
    });

    test('getUsersCategories returns a list of Categories', () async {
      final mockCategories = [Categories(), Categories()];
      when(mockUserServices.getUsersProductsCategories()).thenAnswer((_) async => mockCategories);

      final categories = await productRepository.getUsersCategories();

      expect(categories, isA<List<Categories>>());
      expect(categories.length, 2);
    });

    test('deleteCategory returns true on successful deletion', () async {
      when(mockUserServices.deleteUsersCategories(any)).thenAnswer((_) async => true);

      final result = await productRepository.deleteCategory(categoryId: 1);

      expect(result, true);
    });

    test('deleteProduct returns true on successful deletion', () async {
      when(mockUserServices.deleteUsersProduct(any)).thenAnswer((_) async => true);

      final result = await productRepository.deleteProduct(productId: 'test_product_id');

      expect(result, true);
    });

    test('addProductVariation adds a new variation successfully', () async {
      final product = Products();
      final variation = Variation(variationType: 'test_type', variationValue: 'test_value', variationQuantity: '10');
      

      final result = await productRepository.addProductVariation(product: product, variation: variation);

      expect(result, true);
    });

    test('editProduct updates product information successfully', () async {
      final product = Products();
      final mockImageFile = File('test_image.jpg'); 


      final result = await productRepository.editProduct(product: product, productImage: mockImageFile);

      expect(result, true);
    });
  });
}
