// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'financial_report_cubit.dart';

enum ReportStatus { loading, loaded, initial, error }

class BusinessReportState extends Equatable {
  const BusinessReportState({
    this.status = ReportStatus.initial,
    this.businessReport,
    this.financialReport,
    this.response,
  });

  final ReportStatus status;
  final BusinessReport? businessReport;
  final FinancialReport? financialReport;
  final String? response;

  @override
  List<Object?> get props =>
      [status, businessReport, response, financialReport];

  BusinessReportState copyWith(
      {ReportStatus? status,
      BusinessReport? businessReport,
      String? response,
      FinancialReport? financialReport}) {
    return BusinessReportState(
      status: status ?? this.status,
      businessReport: businessReport ?? this.businessReport,
      financialReport: financialReport ?? this.financialReport,
      response: response ?? this.response,
    );
  }
}
