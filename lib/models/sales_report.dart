// ignore_for_file: public_member_api_docs, sort_constructors_first

class SalesReport {
  final Map allReportData;

  Map dailyReportData;

  final Map? stockReport;

  SalesReport({
    required this.stockReport,
    required this.allReportData,
    required this.dailyReportData,
  });

  factory SalesReport.fromJson(Map<String, dynamic> json) {
    return SalesReport(
        allReportData: json["data"]["all_report_data"],
        stockReport: json["stock_report"],
        dailyReportData: json["data"]["daily_report_data"]);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'all_report_data': allReportData,
      'daily_report_data': dailyReportData,
      'stock_report': stockReport,
    };
  }

  Map<String, dynamic> toJson() => {
        "data": {
          "daily_report_data": dailyReportData,
          "all_report_data": allReportData
        },
        "stock_report": stockReport
      };
}
