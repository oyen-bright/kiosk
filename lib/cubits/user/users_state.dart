// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'users_cubit.dart';

enum UserStateStatus { initial, loading, loaded, error }

class UserState extends Equatable {
  final UserStateStatus userStateStatus;
  final String? errorMessage;
  final User? currentUser;
  final Permissions? permissions;
  final SalesReport? usersSalesReport;
  const UserState(
      {required this.userStateStatus,
      this.currentUser,
      this.errorMessage,
      this.permissions,
      this.usersSalesReport});

  @override
  List<Object?> get props => [
        userStateStatus,
        currentUser,
        permissions,
        usersSalesReport,
        errorMessage
      ];

  factory UserState.initial() {
    return const UserState(userStateStatus: UserStateStatus.initial);
  }

  @override
  bool get stringify => true;

  UserState copyWith({
    UserStateStatus? userStateStatus,
    String? errorMessage,
    User? currentUser,
    Permissions? permissions,
    SalesReport? usersSalesReport,
  }) {
    return UserState(
      errorMessage: errorMessage ?? this.errorMessage,
      userStateStatus: userStateStatus ?? this.userStateStatus,
      currentUser: currentUser ?? this.currentUser,
      permissions: permissions ?? this.permissions,
      usersSalesReport: usersSalesReport ?? this.usersSalesReport,
    );
  }
}
