// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'select_account_cubit.dart';

enum SelectAccountStatus { initial, loading, loaded, error }

class SelectAccountState extends Equatable {
  final String error;
  final SelectAccountStatus selectAccountStatus;
  final User? currentUser;
  final SalesReport? usersSalesReport;
  const SelectAccountState(
      {required this.selectAccountStatus,
      this.error = "",
      this.currentUser,
      this.usersSalesReport});

  @override
  List<Object?> get props =>
      [selectAccountStatus, error, currentUser, usersSalesReport];

  factory SelectAccountState.intitial() {
    return const SelectAccountState(
        selectAccountStatus: SelectAccountStatus.initial);
  }

  @override
  bool get stringify => true;

  SelectAccountState copyWith({
    String? error,
    SelectAccountStatus? selectAccountStatus,
    User? currentUser,
    SalesReport? usersSalesReport,
  }) {
    return SelectAccountState(
      error: error ?? this.error,
      selectAccountStatus: selectAccountStatus ?? this.selectAccountStatus,
      currentUser: currentUser ?? this.currentUser,
      usersSalesReport: usersSalesReport ?? this.usersSalesReport,
    );
  }
}
