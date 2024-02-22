import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/repositories/.repositories.dart';

part 'financial_report_state.dart';

class BusinessReportCubit extends Cubit<BusinessReportState> {
  BusinessReportCubit({required this.userRepository})
      : super(const BusinessReportState()) {
    getFinancialReport();
  }
  final UserRepository userRepository;

  Future<void> getFinancialReport() async {
    try {
      emit(state.copyWith(status: ReportStatus.loading));
      final response = await userRepository.getBusinessReport();
      emit(state.copyWith(
          status: ReportStatus.loaded,
          businessReport: response[0],
          financialReport: response[1]));
    } catch (e) {
      emit(state.copyWith(status: ReportStatus.error, response: e.toString()));
      rethrow;
    }
  }
}
