// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'user_login_cubit.dart';

enum UserLoginStateStatus { initial, loading, loaded, error }

class UsersState extends Equatable {
  final UserLoginStateStatus status;
  final String errorMessage;
  final Map<String, dynamic>? loginDetails;
  final User? currentUser;
  final List<dynamic>? merchantBusinessProfile;
  final bool isLoggedIn;
  final Permissions? userPermissions;
  final SalesReport? usersSalesReport;
  const UsersState({
    required this.status,
    this.loginDetails,
    this.usersSalesReport,
    this.merchantBusinessProfile,
    this.errorMessage = "",
    this.currentUser,
    this.isLoggedIn = false,
    this.userPermissions,
  });

  @override
  List<Object?> get props => [
        status,
        currentUser,
        isLoggedIn,
        userPermissions,
        errorMessage,
        merchantBusinessProfile,
        usersSalesReport,
        loginDetails
      ];

  factory UsersState.initial({final User? currentUser}) {
    return UsersState(
        status: UserLoginStateStatus.initial,
        isLoggedIn: false,
        currentUser: currentUser);
  }

  @override
  bool get stringify => true;

  UsersState copyWith({
    UserLoginStateStatus? status,
    String? errorMessage,
    Map<String, dynamic>? loginDetails,
    User? currentUser,
    List<dynamic>? merchantBusinessProfile,
    bool? isLogedIn,
    Permissions? userPermissions,
    SalesReport? usersSalesReport,
  }) {
    return UsersState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      loginDetails: loginDetails ?? this.loginDetails,
      currentUser: currentUser ?? this.currentUser,
      merchantBusinessProfile:
          merchantBusinessProfile ?? this.merchantBusinessProfile,
      isLoggedIn: isLogedIn ?? isLoggedIn,
      userPermissions: userPermissions ?? this.userPermissions,
      usersSalesReport: usersSalesReport ?? this.usersSalesReport,
    );
  }
}
