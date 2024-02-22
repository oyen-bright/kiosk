import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/cubits/account/select_account_cubit.dart';
import 'package:kiosk/cubits/login/user_login_cubit.dart';
import 'package:kiosk/models/permission.dart';
import 'package:kiosk/models/sales_report.dart';
import 'package:kiosk/models/user.dart';
import 'package:kiosk/repositories/.repositories.dart';

part 'users_state.dart';

/// A Cubit for managing user-related state in the application.
class UserCubit extends Cubit<UserState> {
  final SelectAccountCubit selectAccountCubit;
  final UserRepository userRepository;
  final UserLoginCubit userLoginCubit;

  late final StreamSubscription switchAccountCubitStreamSubscription;
  late final StreamSubscription userLoginCubitStreamSubscription;

  /// Creates an instance of the [UserCubit] with dependencies.
  ///
  /// This Cubit is responsible for managing user-related state and
  /// subscribing to changes in [SelectAccountCubit] and [UserLoginCubit]
  /// to keep the state up-to-date.
  UserCubit({
    required this.selectAccountCubit,
    required this.userLoginCubit,
    required this.userRepository,
  }) : super(UserState.initial()) {
    // Subscribe to changes in SelectAccountCubit and UserLoginCubit to update the state.
    switchAccountCubitStreamSubscription =
        selectAccountCubit.stream.listen((SelectAccountState state) {
      if (state.selectAccountStatus != SelectAccountStatus.error ||
          state.selectAccountStatus != SelectAccountStatus.loading) {
        _setState();
      }
    });

    userLoginCubitStreamSubscription = userLoginCubit.stream.listen((state) {
      if (state.status != UserLoginStateStatus.error ||
          state.status != UserLoginStateStatus.loading) {
        _setState();
      }
    });
  }

  /// Updates the state based on the current states of [SelectAccountCubit] and [UserLoginCubit].
  void _setState() {
    // Determine if the state is in its initial state based on null values in child Cubits.
    final isStateInitial = userLoginCubit.state.userPermissions == null ||
        selectAccountCubit.state.currentUser == null ||
        selectAccountCubit.state.usersSalesReport == null;

    emit(state.copyWith(
      userStateStatus:
          isStateInitial ? UserStateStatus.initial : UserStateStatus.loaded,
      currentUser: selectAccountCubit.state.currentUser,
      usersSalesReport: selectAccountCubit.state.usersSalesReport,
      permissions: userLoginCubit.state.userPermissions,
    ));
  }

  /// Fetches user details from the [UserRepository] and updates the state accordingly.
  Future<void> getUserDetails() async {
    try {
      emit(state.copyWith(userStateStatus: UserStateStatus.loading));
      final user = await userRepository.getUsersInformation();
      emit(state.copyWith(
          userStateStatus: UserStateStatus.loaded, currentUser: user));
    } catch (e) {
      emit(state.copyWith(
          userStateStatus: UserStateStatus.error, errorMessage: e.toString()));
      rethrow;
    }
  }

  @override
  Future<void> close() {
    // Cancel stream subscriptions when the cubit is closed.
    switchAccountCubitStreamSubscription.cancel();
    userLoginCubitStreamSubscription.cancel();
    return super.close();
  }
}
