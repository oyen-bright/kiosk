import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/cubits/account/select_account_cubit.dart';
import 'package:kiosk/models/sales_report.dart';
import 'package:kiosk/repositories/.repositories.dart';

part 'sales_report_state.dart';

/// A Cubit responsible for managing sales report-related state and actions.
class SalesReportCubit extends Cubit<SalesReportState> {
  final UserRepository userRepository;
  final SelectAccountCubit selectAccountCubit;

  late final StreamSubscription switchAccountCubitStreamSubscription;

  SalesReportCubit({
    required this.selectAccountCubit,
    required this.userRepository,
  }) : super(SalesReportState.initial()) {
    // Listen to changes in the SelectAccountCubit's state.
    switchAccountCubitStreamSubscription =
        selectAccountCubit.stream.listen((SelectAccountState state) {
      // Check if the SelectAccountState is not in an error or loading state.
      if (state.selectAccountStatus != SelectAccountStatus.error ||
          state.selectAccountStatus != SelectAccountStatus.loading) {
        // Call the private method _setState to update the SalesReportState.
        _setState();
      }
    });
  }

  /// Private method to set the SalesReportState based on the SelectAccountState.
  void _setState() {
    emit(state.copyWith(
        salesReportStatus: SalesReportStatus.loaded,
        salesReport: selectAccountCubit.state.usersSalesReport));
  }

  /// Fetch the sales report data.
  Future<void> getSaleReport() async {
    try {
      emit(state.copyWith(
        salesReportStatus: SalesReportStatus.loading,
      ));
      // Fetch the sales report data from the UserRepository.
      final salesReport = await userRepository.getSalesReport();
      emit(state.copyWith(
          salesReportStatus: SalesReportStatus.loaded,
          salesReport: salesReport));
    } catch (e) {
      // Handle any errors and update the state accordingly.
      emit(state.copyWith(
          salesReportStatus: SalesReportStatus.error, msg: e.toString()));
    }
  }

  @override
  Future<void> close() {
    // Cancel the StreamSubscription and call the super class's close method.
    switchAccountCubitStreamSubscription.cancel();
    return super.close();
  }
}
