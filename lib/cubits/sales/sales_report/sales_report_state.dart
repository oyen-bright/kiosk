// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'sales_report_cubit.dart';

enum SalesReportStatus { initial, loading, loaded, error }

class SalesReportState extends Equatable {
  final SalesReportStatus salesReportStatus;
  final String msg;
  final SalesReport? salesReport;
  const SalesReportState(
      {required this.salesReportStatus, this.salesReport, this.msg = ""});

  @override
  List<Object?> get props => [salesReportStatus, salesReport, msg];

  @override
  bool get stringify => true;

  factory SalesReportState.initial() {
    return const SalesReportState(salesReportStatus: SalesReportStatus.initial);
  }

  SalesReportState copyWith({
    SalesReportStatus? salesReportStatus,
    String? msg,
    SalesReport? salesReport,
  }) {
    return SalesReportState(
      salesReportStatus: salesReportStatus ?? this.salesReportStatus,
      msg: msg ?? this.msg,
      salesReport: salesReport ?? this.salesReport,
    );
  }
}
