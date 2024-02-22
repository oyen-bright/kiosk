import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/cubits/sales/sales_cubit.dart';
import 'package:kiosk/models/sales.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';

// Create a mock UserRepository
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('SalesCubit', () {
    late UserRepository userRepository;
    late SalesCubit salesCubit;

    setUp(() {
      userRepository = MockUserRepository();
      salesCubit = SalesCubit(userRepository: userRepository);
    });

    tearDown(() {
      salesCubit.close();
    });

    test('initial state is correct', () {
      expect(salesCubit.state, const SalesState());
    });

    blocTest<SalesCubit, SalesState>(
      'emits [loaded] when loadSales is successful',
      build: () {
        when(() => userRepository.getUsersSales(
                queryParameters: any(named: 'queryParameters')))
            .thenAnswer((_) async => {
                  'sales': [],
                  'total_count': 0,
                  'next_page': null,
                  'prev_page': null
                });
        return salesCubit;
      },
      act: (cubit) => cubit.loadSales(),
      expect: () => [
        const SalesState(salesStatus: SalesStatus.loading),
        const SalesState(
            salesStatus: SalesStatus.loaded,
            sales: [],
            totalCount: {'all_sales': 0},
            nextPage: null,
            previousPage: null)
      ],
    );

    blocTest<SalesCubit, SalesState>(
      'emits [loaded] when nextPage is successful',
      build: () {
        when(() =>
                userRepository.getUsersSales(nextPage: any(named: 'nextPage')))
            .thenAnswer((_) async => {
                  'sales': [],
                  'total_count': 0,
                  'next_page': null,
                  'prev_page': null
                });
        return salesCubit;
      },
      seed: const SalesState(salesStatus: SalesStatus.loaded),
      act: (cubit) => cubit.nextPage(),
      expect: () => [
        const SalesState(salesStatus: SalesStatus.loading),
        const SalesState(
            salesStatus: SalesStatus.loaded,
            sales: [],
            totalCount: {'all_sales': 0},
            nextPage: null,
            previousPage: null)
      ],
    );

    blocTest<SalesCubit, SalesState>(
      'emits [error] when loadSales throws an exception',
      build: () {
        when(() => userRepository.getUsersSales(
                queryParameters: any(named: 'queryParameters')))
            .thenThrow(Exception('Error loading sales'));
        return salesCubit;
      },
      act: (cubit) => cubit.loadSales(),
      expect: () => [
        const SalesState(salesStatus: SalesStatus.loading),
        const SalesState(
            salesStatus: SalesStatus.error,
            msg: 'Exception: Error loading sales'),
      ],
    );

    // Add more test cases to cover other scenarios
  });
}
