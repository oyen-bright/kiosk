import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/cubits/user/user_login_cubit.dart';
import 'package:kiosk/models/user.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockLocalStorage extends Mock implements LocalStorage {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('UserLoginCubit', () {
    late UserLoginCubit userLoginCubit;
    late UserRepository mockUserRepository;
    late LocalStorage mockLocalStorage;
    late FlutterSecureStorage mockFlutterSecureStorage;

    setUp(() {
      mockUserRepository = MockUserRepository();
      mockLocalStorage = MockLocalStorage();
      mockFlutterSecureStorage = MockFlutterSecureStorage();

      userLoginCubit = UserLoginCubit(
        userRepository: mockUserRepository,
        localStorage: mockLocalStorage,
        flutterSecureStorage: mockFlutterSecureStorage,
      );
    });

    tearDown(() {
      userLoginCubit.close();
    });

    test('initial state is UsersState.initial()', () {
      expect(userLoginCubit.state, equals(UsersState.initial()));
    });

    blocTest<UserLoginCubit, UsersState>(
      'emits loading and success state when userLogin is called successfully',
      build: () {
        when(() => mockUserRepository.userLogin(
              usersEmail: any(named: 'usersEmail'),
              usersPassword: any(named: 'usersPassword'),
            )).thenAnswer(
          (_) async => UsersState.initial(
            status: UserLoginStateStatus.success,
            currentUser: User(id: '1', email: 'test@example.com'),
          ),
        );
        return userLoginCubit;
      },
      act: (cubit) => cubit.userLogin(
        usersEmail: 'test@example.com',
        usersPassword: 'password',
      ),
      expect: () => [
        UsersState.initial(status: UserLoginStateStatus.loading),
        UsersState.initial(
          status: UserLoginStateStatus.success,
          currentUser: User(id: '1', email: 'test@example.com'),
        ),
      ],
    );
  });
}
