// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'stock_report_cubit.dart';

enum StockReportStatus { initial, loading, loaded, error }

class StockReportState extends Equatable {
  final StockReportStatus status;
  final List<Products>? allProduct;
  final List<Products> lowOnStock;
  final List<Products> outOfStock;
  final List<dynamic> mostSoldItems;
  final double stockValue;
  final int lowOnStockCount;
  final int outOfStockCount;
  final int inStockProduct;
  final int soldItemsCount;
  final int uploadedItemsCount;
  const StockReportState(
      {this.status = StockReportStatus.initial,
      this.stockValue = 0.0,
      this.inStockProduct = 0,
      this.allProduct,
      this.lowOnStock = const [],
      this.outOfStock = const [],
      this.mostSoldItems = const [],
      this.lowOnStockCount = 0,
      this.outOfStockCount = 0,
      this.soldItemsCount = 0,
      this.uploadedItemsCount = 0});

  @override
  List<Object?> get props => [
        status,
        lowOnStock,
        outOfStock,
        allProduct,
        lowOnStockCount,
        outOfStockCount,
        soldItemsCount,
        uploadedItemsCount,
        mostSoldItems,
        stockValue,
        inStockProduct
      ];

  @override
  bool get stringify => true;

  StockReportState copyWith({
    StockReportStatus? status,
    List<Products>? allProduct,
    List<Products>? lowOnStock,
    List<Products>? outOfStock,
    List<dynamic>? mostSoldItems,
    double? stockValue,
    int? lowOnStockCount,
    int? outOfStockCount,
    int? inStockProduct,
    int? soldItemsCount,
    int? uploadedItemsCount,
  }) {
    return StockReportState(
      inStockProduct: inStockProduct ?? this.inStockProduct,
      lowOnStock: lowOnStock ?? this.lowOnStock,
      outOfStock: outOfStock ?? this.outOfStock,
      stockValue: stockValue ?? this.stockValue,
      status: status ?? this.status,
      mostSoldItems: mostSoldItems ?? this.mostSoldItems,
      allProduct: allProduct ?? this.allProduct,
      lowOnStockCount: lowOnStockCount ?? this.lowOnStockCount,
      outOfStockCount: outOfStockCount ?? this.outOfStockCount,
      soldItemsCount: soldItemsCount ?? this.soldItemsCount,
      uploadedItemsCount: uploadedItemsCount ?? this.uploadedItemsCount,
    );
  }
}
