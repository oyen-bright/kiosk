import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/cubits/add_item/add_item_cubit.dart';
import 'package:kiosk/models/add_item_state.dart';
import 'package:kiosk/models/variation.dart';
import 'package:kiosk/repositories/product_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  group('AddItemCubit', () {
    late AddItemCubit addItemCubit;
    late MockProductRepository mockProductRepository;

    setUp(() {
      mockProductRepository = MockProductRepository();
      addItemCubit = AddItemCubit(
        productRepository: mockProductRepository,
        loadingCubit: LoadingCubit(),
      );
    });

    tearDown(() {
      addItemCubit.close();
    });

    test('initial state is AddItemState.initial()', () {
      expect(addItemCubit.state, equals(const AddItemState()));
    });

    blocTest<AddItemCubit, AddItemState>(
      'edit item name emits correct state',
      build: () => addItemCubit,
      act: (cubit) => cubit.editItemName('New Item Name'),
      expect: () => [const AddItemState(productTitle: 'New Item Name')],
    );

    blocTest<AddItemCubit, AddItemState>(
      'toggle charge by weight emits correct state',
      build: () => addItemCubit,
      act: (cubit) => cubit.toggleChargeWeight(),
      expect: () => [const AddItemState(chargeByWeight: true)],
    );

    blocTest<AddItemCubit, AddItemState>(
      'edit image emits correct state',
      build: () => addItemCubit,
      act: (cubit) => cubit.editImage(File('image.jpg')),
      expect: () => [const AddItemState(productImage: File('image.jpg'))],
    );

    blocTest<AddItemCubit, AddItemState>(
      'toggle out of stock notification emits correct state',
      build: () => addItemCubit,
      act: (cubit) => cubit.toggleOutOfStockNotification(),
      expect: () => [const AddItemState(outOfStockNotify: true)],
    );

    blocTest<AddItemCubit, AddItemState>(
      'toggle expiry notification emits correct state',
      build: () => addItemCubit,
      act: (cubit) => cubit.toggleExpiryNotification(),
      expect: () => [const AddItemState(expiryNotify: true)],
    );

    blocTest<AddItemCubit, AddItemState>(
      'edit notification period emits correct state',
      build: () => addItemCubit,
      act: (cubit) => cubit.editNotificationPeriod('1 week before'),
      expect: () => [const AddItemState(expiryNotifyPeriod: '1 week before')],
    );

    blocTest<AddItemCubit, AddItemState>(
      'edit weight unit emits correct state',
      build: () => addItemCubit,
      act: (cubit) => cubit.editWeightUnit('kg'),
      expect: () => [const AddItemState(weightUnit: 'kg')],
    );

    blocTest<AddItemCubit, AddItemState>(
      'edit quantity emits correct state',
      build: () => addItemCubit,
      act: (cubit) => cubit.editQuantity('10'),
      expect: () => [const AddItemState(stock: '10')],
    );
  });
}
