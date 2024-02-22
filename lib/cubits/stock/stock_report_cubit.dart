import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/blocs/register_products/register_products_bloc.dart';
import 'package:kiosk/cubits/sales/sales_report/sales_report_cubit.dart';
import 'package:kiosk/models/product.dart';

part 'stock_report_state.dart';

/// A Cubit responsible for managing stock reports.
class StockReportCubit extends Cubit<StockReportState> {
  final RegisterProductsBloc registerProductsBloc;
  final SalesReportCubit salesReportCubit;

  late final StreamSubscription registerProductsBlocStream;
  late final StreamSubscription salesReportCubitStream;

  StockReportCubit({
    required this.registerProductsBloc,
    required this.salesReportCubit,
  }) : super(const StockReportState()) {
    // Initialize the StockReportCubit and fetch initial stock report.
    _getStockReport();

    // Listen to changes in the RegisterProductsBloc's state.
    registerProductsBlocStream =
        registerProductsBloc.stream.listen((RegisterProductsState event) {
      if (event is RegisterProductsLoaded) {
        // Extract the products from the RegisterProductsState.
        final allProduct = event.products;

        // Calculate out of stock and low stock products.
        final outOfStockProducts = _getOutOfStockProduct(allProduct);
        final lowStockProduct = _getLowStockProduct(allProduct);

        // Calculate the count of in-stock products.
        final inStockProduct = allProduct.length -
            (outOfStockProducts.length + lowStockProduct.length);

        // Update the state with the new stock information.
        emit(state.copyWith(
            inStockProduct: inStockProduct,
            allProduct: allProduct,
            lowOnStock: lowStockProduct,
            outOfStock: outOfStockProducts,
            outOfStockCount: outOfStockProducts.length,
            lowOnStockCount: lowStockProduct.length));
      }
    });

    // Listen to changes in the SalesReportCubit's state.
    salesReportCubitStream = salesReportCubit.stream.listen((event) {
      if (event.salesReportStatus == SalesReportStatus.loaded) {
        // Extract relevant data from the SalesReport.
        final soldItemsCount =
            event.salesReport!.dailyReportData["inventory"]["all_orders_count"];
        final uploadedItemsCount =
            event.salesReport!.dailyReportData["inventory"]["uploaded_items"];
        final mostSoldItems =
            event.salesReport!.stockReport!["most_sold_products"];
        final stockValue = event.salesReport!.stockReport!["cost_sales_total"];

        // Update the state with sales-related information.
        emit(state.copyWith(
            soldItemsCount: soldItemsCount,
            mostSoldItems: mostSoldItems,
            stockValue: double.parse(stockValue.toString()),
            uploadedItemsCount: uploadedItemsCount));
      }
    });
  }

  /// A private method to retrieve and update the stock report.
  void _getStockReport() {
    // Get the current state of the RegisterProductsBloc.
    final registerProductsState = registerProductsBloc.state;

    if (registerProductsState is RegisterProductsLoaded) {
      // Extract the products from the RegisterProductsLoaded state.
      final allProduct = registerProductsState.products;

      // Calculate out of stock and low stock products.
      final outOfStockProduct = _getOutOfStockProduct(allProduct);
      final lowStockProduct = _getLowStockProduct(allProduct);

      // Calculate the count of in-stock products.
      final inStockProduct = allProduct.length -
          (outOfStockProduct.length + lowStockProduct.length);

      // Update the state with the new stock information.
      emit(state.copyWith(
          inStockProduct: inStockProduct,
          allProduct: allProduct,
          lowOnStock: lowStockProduct,
          outOfStock: outOfStockProduct,
          outOfStockCount: outOfStockProduct.length,
          lowOnStockCount: lowStockProduct.length));
    }

    // Check if the sales report from SalesReportCubit is loaded.
    if (salesReportCubit.state.salesReportStatus == SalesReportStatus.loaded) {
      // Extract relevant data from the SalesReportCubit's state.
      final salesReportState = salesReportCubit.state;
      final soldItemsCount = salesReportState
          .salesReport!.allReportData["inventory"]["all_orders_count"];
      final uploadedItemsCount = salesReportState
          .salesReport!.dailyReportData["inventory"]["uploaded_items"];
      final mostSoldItems =
          salesReportState.salesReport!.stockReport!["most_sold_products"];
      final stockValue =
          salesReportState.salesReport!.stockReport!["cost_sales_total"];

      // Update the state with sales-related information.
      emit(state.copyWith(
          soldItemsCount: soldItemsCount,
          mostSoldItems: mostSoldItems,
          stockValue: double.parse(stockValue.toString()),
          uploadedItemsCount: uploadedItemsCount));
    }
  }

  /// A private method to filter out-of-stock products.
  List<Products> _getOutOfStockProduct(List<Products> products) {
    if (products.isNotEmpty) {
      final outOfStockProducts = products.where((product) {
        if (product.chargeByWeight) {
          if (double.parse(product.weightQuantity) <= 0.0) {
            return true; // Product is out of stock if weight quantity is zero or negative.
          }
        } else {
          if (int.parse(product.stock) <= 0) {
            return true; // Product is out of stock if stock count is zero or negative.
          }
        }
        return false;
      }).toList();

      return outOfStockProducts;
    }
    return []; // Return an empty list if there are no products.
  }

  /// A private method to filter low stock products based on the `lowStockLimit` and `outOfStockNotify` properties.
  List<Products> _getLowStockProduct(List<Products> products) {
    if (products.isNotEmpty) {
      final lowStockProducts = products.where((product) {
        if (product.outOfStockNotify) {
          if (product.chargeByWeight) {
            // Check if the product is charged by weight and weight is within the low stock limit.
            if (double.parse(product.weightQuantity) > 0.0 &&
                double.parse(product.weightQuantity) <
                    double.parse(product.lowStockLimit)) {
              return true;
            }
          } else {
            // Check if the product is not charged by weight and stock count is within the low stock limit.
            if (int.parse(product.stock) > 0 &&
                int.parse(product.stock) < int.parse(product.lowStockLimit)) {
              return true;
            }
          }
        }
        return false;
      }).toList();

      return lowStockProducts;
    }
    return []; // Return an empty list if there are no products.
  }

  /// Override the `close` method to cancel stream subscriptions when the cubit is closed.
  @override
  Future<void> close() {
    // Cancel the stream subscriptions to prevent memory leaks.
    registerProductsBlocStream.cancel();
    salesReportCubitStream.cancel();
    return super.close();
  }
}
