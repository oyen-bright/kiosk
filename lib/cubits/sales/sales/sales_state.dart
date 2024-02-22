// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'sales_cubit.dart';

enum SalesStatus { initial, loading, loaded, error }

class SalesState extends Equatable {
  final List<Sales> sales;
  final List<Sales>? cardSales;
  final List<Sales>? cashSales;
  final List<Sales>? mobileSales;
  final String msg;
  final int currentPage;
  final int pageSize;
  final Map<String, int> totalCount;

  final Map<String, String?>? nextPage;
  final Map<String, String?>? previousPage;
  final SalesStatus salesStatus;

  const SalesState({
    this.sales = const [],
    this.cardSales,
    this.cashSales,
    this.mobileSales,
    this.currentPage = 1,
    this.totalCount = const {
      "all_sales": 0,
      'card_payment': 0,
      'mobile_money_payment': 0,
      'cash_payment': 0
    },
    this.pageSize = 2,
    this.msg = "",
    this.nextPage,
    this.previousPage,
    this.salesStatus = SalesStatus.initial,
  });

  @override
  List<Object?> get props => [
        sales,
        msg,
        salesStatus,
        cardSales,
        cashSales,
        mobileSales,
        currentPage,
        pageSize,
        totalCount,
        nextPage,
        previousPage
      ];

  @override
  bool get stringify => true;

  SalesState copyWith({
    List<Sales>? sales,
    List<Sales>? cardSales,
    List<Sales>? cashSales,
    List<Sales>? mobileSales,
    String? msg,
    int? currentPage,
    int? pageSize,
    Map<String, int>? totalCount,
    Map<String, String?>? nextPage,
    Map<String, String?>? previousPage,
    SalesStatus? salesStatus,
  }) {
    return SalesState(
      sales: sales ?? this.sales,
      cardSales: cardSales ?? this.cardSales,
      cashSales: cashSales ?? this.cashSales,
      mobileSales: mobileSales ?? this.mobileSales,
      msg: msg ?? this.msg,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      nextPage: nextPage ?? this.nextPage,
      previousPage: previousPage ?? this.previousPage,
      salesStatus: salesStatus ?? this.salesStatus,
    );
  }
}
