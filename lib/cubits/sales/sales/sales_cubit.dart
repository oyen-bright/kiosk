import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/repositories/user_repository.dart';

part 'sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  final UserRepository userRepository;

  /// Initialize the SalesCubit with the provided [userRepository].
  ///
  /// [userRepository] The repository for user-related data.
  SalesCubit({required this.userRepository}) : super(const SalesState()) {
    loadSales();
  }

  Map<String, String> queryParameters = {
    'page_size': "50",
  };

  /// Load sales data from the repository.
  ///
  /// [paymentMethod] Optional filter for the payment method (e.g., 'cash_payment').
  ///
  /// This method fetches sales data from the repository based on the specified [paymentMethod]
  /// and updates the state accordingly.
  Future<void> loadSales({String? paymentMethod}) async {
    try {
      // Create query parameters with a default page size.
      Map<String, String> params = Map.from(queryParameters);

      // If a paymentMethod filter is specified, add it to the query parameters.
      if (paymentMethod != null) {
        params["payment"] = paymentMethod;
      }

      // Update the state to indicate that sales data is being loaded.
      emit(state.copyWith(salesStatus: SalesStatus.loading));

      // Fetch sales data from the user repository using the specified parameters.
      final response =
          await userRepository.getUsersSales(queryParameters: params);

      // Cast the fetched data to a list of sales objects.
      final sales = (response['sales'] as List<dynamic>).cast<Sales>();

      // Update various properties in the state based on the fetched data.
      Map<String, int> newTotalCount = Map.from(state.totalCount);
      newTotalCount[paymentMethod ?? 'all_sales'] =
          response['total_count'] as int;

      // Update pagination information for next and previous pages.
      Map<String, String?>? nextPage = state.nextPage;
      if (nextPage != null) {
        nextPage[paymentMethod ?? 'all_sales'] = response['next_page'];
      } else {
        nextPage = {paymentMethod ?? 'all_sales': response['next_page']};
      }
      Map<String, String?>? previousPage = state.previousPage;
      if (previousPage != null) {
        previousPage[paymentMethod ?? 'all_sales'] = response['prev_page'];
      } else {
        previousPage = {paymentMethod ?? 'all_sales': response['prev_page']};
      }

      // Update the total count of sales in the state.
      Map<String, int> totalCount = Map.from(state.totalCount);
      totalCount[paymentMethod ?? 'all_sales'] = response['total_count'];

      // Update the state with the fetched sales data and pagination details.
      emit(state.copyWith(
        nextPage: nextPage,
        previousPage: previousPage,
        totalCount: totalCount,
        salesStatus: SalesStatus.loaded,
        cashSales: paymentMethod == 'cash_payment' ? sales : state.mobileSales,
        mobileSales:
            paymentMethod == 'mobile_money_payment' ? sales : state.mobileSales,
        cardSales: paymentMethod == 'card_payment' ? sales : state.cardSales,
        sales: paymentMethod == null ? sales : state.sales,
      ));

      return;
    } catch (e) {
      // Handle errors by updating the state with an error status and message.
      emit(state.copyWith(salesStatus: SalesStatus.error, msg: e.toString()));

      // Rethrow the error to propagate it to the caller.
      rethrow;
    }
  }

  /// Get a list of sales filtered by payment method.
  ///
  /// [paymentMethod] The payment method used to filter sales.
  ///
  /// This method returns a list of sales based on the specified [paymentMethod].
  List<Sales>? getSaleByPaymentMethod(String paymentMethod) {
    switch (paymentMethod) {
      case 'card_payment':
        // Return the list of sales with the 'card_payment' payment method.
        return state.cardSales;
      case 'mobile_money_payment':
        // Return the list of sales with the 'mobile_money_payment' payment method.
        return state.mobileSales;
      case 'cash_payment':
        // Return the list of sales with the 'cash_payment' payment method.
        return state.cashSales;
    }
    // If the payment method is not specified or not recognized, return all sales.
    return state.sales;
  }

  /// Fetch the next page of sales data.
  ///
  /// [paymentMethod] The payment method used to filter sales for the next page.
  ///
  /// This method retrieves the next page of sales data based on the specified [paymentMethod].
  Future<List<Sales>> nextPage({String? paymentMethod}) async {
    try {
      // Check if there is a next page available.
      if (state.nextPage != null) {
        // If the next page URL for the specified payment method is null, return an empty list.
        if (state.nextPage?[paymentMethod ?? "all_sales"] == null) {
          return [];
        }

        // Fetch the sales data for the next page.
        final response = await userRepository.getUsersSales(
            nextPage: state.nextPage![paymentMethod ?? "all_sales"]);

        // Cast the response data to a list of sales objects.
        final sales = (response['sales'] as List<dynamic>).cast<Sales>();

        // Update the total count of sales for the specified payment method.
        Map<String, int> newTotalCount = state.totalCount;
        newTotalCount[paymentMethod ?? 'all_sales'] =
            response['total_count'] as int;

        // Update the next page, previous page, and total count in the state.
        Map<String, String?>? nextPage = state.nextPage;
        if (nextPage != null) {
          nextPage[paymentMethod ?? 'all_sales'] = response['next_page'];
        } else {
          nextPage = {paymentMethod ?? 'all_sales': response['next_page']};
        }
        Map<String, String?>? previousPage = state.previousPage;

        if (previousPage != null) {
          previousPage[paymentMethod ?? 'all_sales'] = response['prev_page'];
        } else {
          previousPage = {paymentMethod ?? 'all_sales': response['prev_page']};
        }
        Map<String, int> totalCount = state.totalCount;
        totalCount[paymentMethod ?? 'all_sales'] = response['total_count'];

        // Update the state with the new data.
        emit(state.copyWith(
          nextPage: nextPage,
          previousPage: previousPage,
          totalCount: totalCount,
          salesStatus: SalesStatus.loaded,
          cashSales: paymentMethod == 'cash_payment'
              ? [...state.cashSales ?? [], ...sales]
              : state.cashSales,
          mobileSales: paymentMethod == 'mobile_money_payment'
              ? [...state.mobileSales ?? [], ...sales]
              : state.mobileSales,
          cardSales: paymentMethod == 'card_payment'
              ? [...state.cardSales ?? [], ...sales]
              : state.cardSales,
          sales:
              paymentMethod == null ? [...state.sales, ...sales] : state.sales,
        ));

        // Return the fetched sales data.
        return sales;
      }
      // If there is no next page available, return an empty list.
      return [];
    } catch (e) {
      // Handle any errors and update the state accordingly.
      emit(state.copyWith(
        salesStatus: SalesStatus.loaded,
      ));
      rethrow;
    }
  }
}
