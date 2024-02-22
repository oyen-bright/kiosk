import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/service/transaction_repository.dart';
import 'package:mockito/mockito.dart';

class MockUserServices extends Mock implements UserServices {}

void main() {
  group('TransactionRepository', () {
    late TransactionRepository transactionRepository;
    late MockUserServices mockUserServices;

    setUp(() {
      mockUserServices = MockUserServices();
      transactionRepository =
          TransactionRepository(userServices: mockUserServices);
    });

    test('generateFastCheckOut returns data', () async {
      // Arrange
      const String amount = '100';
      final expectedData = {'key': 'value'}; // Expected data from the service
      when(mockUserServices.generateFastCheckOut(any))
          .thenAnswer((_) async => expectedData);

      // Act
      final result =
          await transactionRepository.generateFastCheckOut(amount: amount);

      // Assert
      expect(result, equals(expectedData));
      verify(mockUserServices.generateFastCheckOut(amount));
    });

    test('generateFastCheckOut throws error', () async {
      // Arrange
      const String amount = '100';
      const expectedError =
          'Error message'; // Expected error message from the service
      when(mockUserServices.generateFastCheckOut(any)).thenThrow(expectedError);

      // Act & Assert
      expect(() => transactionRepository.generateFastCheckOut(amount: amount),
          throwsA(expectedError));
      verify(mockUserServices.generateFastCheckOut(amount));
    });
  });
}
