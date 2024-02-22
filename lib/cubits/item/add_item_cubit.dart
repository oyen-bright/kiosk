import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:faker/faker.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/models/variation.dart';
import 'package:kiosk/repositories/product_repository.dart';

part 'add_item_state.dart';

class AddItemCubit extends Cubit<AddItemState> {
  final ProductRepository productRepository;
  final LoadingCubit loadingCubit;

  // The constructor of the AddItemCubit class, which takes in a productRepository and loadingCubit,
  // and initializes the state of the cubit to AddItemState.initial(), and immediately calls the addItem() method.
  AddItemCubit({required this.productRepository, required this.loadingCubit})
      : super(const AddItemState()) {
    addItem(); // immediately call addItem() when the cubit is initialized
  }

  // This method emits a new state with all fields in their initial state.
  void addItem() {
    emit(AddItemState.initial());
  }

  // This method changes the product image in the state to a new image.
  void editImage(File? image) {
    emit(state.copyWith(productImage: image));
  }

  // This method changes the product title in the state to a new title.
  void editItemName(String? title) {
    emit(state.copyWith(productTitle: title));
  }

  // This method toggles the chargeByWeight field in the state.
  void toggleChargeWeight() {
    final chargeByWeight = !state.chargeByWeight;
    if (!chargeByWeight) {
      // If chargeByWeight is false, then set productVariation and stock to empty values.
      emit(state.copyWith(
          chargeByWeight: chargeByWeight, productVariation: [], stock: ""));
    } else {
      // If chargeByWeight is true, then only set chargeByWeight to true.
      emit(state.copyWith(chargeByWeight: chargeByWeight));
    }
  }

  // This method toggles the outOfStockNotify field in the state.
  void toggleOutOfStockNotification() {
    emit(state.copyWith(outOfStockNotify: !state.outOfStockNotify));
  }

  void toggleExpiryNotification() {
    final notifyOnExpire = !state.expiryNotify;
    if (!notifyOnExpire) {
      emit(state.copyWith(
        expiryNotify: notifyOnExpire,
      ));
    } else {
      emit(state.copyWith(expiryNotify: notifyOnExpire));
    }
  }

  void editNotificationPeriod(String? value) {
    emit(state.copyWith(expiryNotifyPeriod: value));
  }

  // This method changes the weightUnit field in the state to a new value.
  void editWeightUnit(String? value) {
    emit(state.copyWith(weightUnit: value));
  }

  // This method changes the stock field in the state to a new value.
  void editQuantity(String? value) {
    emit(state.copyWith(stock: value));
  }

  // This method changes the price field in the state to a new value.
  void editPrice(String? value) {
    emit(state.copyWith(price: value));
  }

  // This method changes the costPrice field in the state to a new value.
  void editCostPrice(String? value) {
    emit(state.copyWith(costPrice: value));
  }

  // This method changes the productSku field in the state to a new value.
  void editSku(String? value) {
    emit(state.copyWith(productSku: value));
  }

  // This method changes the expired date field in the state to a new value.
  void editExpireDate(String? value) {
    emit(state.copyWith(expireDate: value));
  }

  // This method changes the lowStockLimit field in the state to a new value.
  void editLowStockValue(String? value) {
    emit(state.copyWith(lowStockLimit: value));
  }

// Updates a variation at a specific index
  void editVariation(Variation newVariation, int index) {
// Get the list of variations from the state
    final variation = state.productVariation;

// Remove the variation at the specified index
    variation.removeAt(index);

// Check if there is already a variation with the same name (case insensitive)
    final filteredVariation = variation.where((element) =>
        element.variationValue.toUpperCase() ==
        newVariation.variationValue.toUpperCase());

// If there isn't a variation with the same name, add the new variation to the list
    if (filteredVariation.isEmpty) {
      final _newVariation = [...variation, newVariation];
      emit(state.copyWith(
          productVariation: _newVariation,
          stock: calculateQuantity(_newVariation).toString()));
    }
  }

  /// Remove a product variation at the specified index.
  void removeVariation(int index) {
    final variation = state.productVariation;
    variation.removeAt(index);
    final _newVariation = [
      ...variation,
    ];

    // Update the state with the new product variations and recalculated stock.
    emit(state.copyWith(
      productVariation: _newVariation,
      stock: calculateQuantity(_newVariation).toString(),
    ));
  }

  /// Add a new product variation.
  void addVariation(Variation newVariation) {
    // Remove any existing variations with the same variationValue.
    final variation = state.productVariation.where(
        (element) => element.variationValue != newVariation.variationValue);
    final _newVariation = [...variation, newVariation];

    // Update the state with the new product variations and recalculated stock.
    emit(state.copyWith(
      productVariation: _newVariation,
      stock: calculateQuantity(_newVariation).toString(),
    ));
  }

  /// Calculate the total quantity based on product variations.
  dynamic calculateQuantity(List<Variation> variations) {
    dynamic quantity = 0;

    // Calculate the total quantity based on whether the product charges by weight or not.
    for (var i in variations) {
      if (state.chargeByWeight) {
        quantity += double.parse(i.variationQuantity);
      } else {
        quantity += int.parse(i.variationQuantity);
      }
    }

    // If the quantity is zero, return an empty string; otherwise, return the calculated quantity.
    return quantity == 0 ? "" : quantity;
  }

  /// Upload a product, either a physical product or a service, with the specified category.
  Future<void> uploadProduct(bool isService, String category) async {
    try {
      // Function to generate a product SKU if it's not provided.
      String generateProductSKU() {
        final faker = Faker();
        const alphanumeric = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        return faker.randomGenerator.fromCharSet(alphanumeric, 6);
      }

      // Determine the product SKU.
      final productSku =
          state.productSku.isEmpty ? generateProductSKU() : state.productSku;

      // Determine the low stock limit based on the outOfStockNotify and chargeByWeight settings.
      final lowStockLimit = isService
          ? "0"
          : state.outOfStockNotify
              ? state.chargeByWeight
                  ? state.lowStockLimit
                      .substring(state.weightUnit.length)
                      .replaceAll(",", "")
                      .trim()
                  : state.lowStockLimit.replaceAll(",", "").trim()
              : "0";

      // Determine the weight unit for physical products, or an empty string for services.
      final weightUnit = isService ? "" : state.weightUnit;

      // Determine the stock quantity for physical products, or a default value for services.
      final stock =
          isService ? 10000.toString() : state.stock.replaceAll(",", "");

      // Call the productRepository's uploadProduct method with the specified parameters.
      await productRepository.uploadProduct(
          productName: state.productTitle,
          price: state.price,
          notifyOnExpire: state.expiryNotify,
          outOfStockNotify: state.outOfStockNotify,
          lowStockLimit: lowStockLimit,
          weightUnit: weightUnit,
          stock: stock,
          expireNotificationPeriod: convertToDays(state.expiryNotifyPeriod),
          expireDate: state.expireDate,
          category: category,
          costPrice: state.costPrice,
          productSKU: productSku,
          chargeByWeight: state.chargeByWeight,
          product: state.productVariation,
          productImage: state.productImage);
    } catch (e) {
      rethrow;
    }
  }

  List<String> sizeList = ["S", "M", "L", "XL", "XXL", "XXXL", "XXXXL"];
  List<String> variationTypeList = const ["Size", "Color"];
  List<String> colorLIst = const [
    "red",
    "blue",
    "green",
    "yellow",
    "purple",
    "pink",
    "orange",
    "brown",
    "black",
    "white",
    "gray",
    "gold",
    "silver",
    "navy blue",
    "sky blue",
    "lime green",
    "teal",
    "indigo",
    "magenta",
    "violet",
    "khaki",
    "salmon",
    "crimson",
    "lavender",
    "plum",
    "blue violet",
    'olive',
    "cyan",
    "maroon",
    "beige",
  ];

  List<String> notificationPeriodOptions = [
    '1 day before',
    '2 days before',
    '3 days before',
    '4 days before',
    '5 days before',
    '6 days before',
    '1 week before',
    '2 weeks before',
    '3 weeks before',
    '4 weeks before',
    '1 month before',
    '2 months before',
    '3 months before',
    '4 months before',
    '5 months before',
  ];

  String? convertToNotificationPeriod(int? days) {
    if (days == null) {
      return null;
    }
    if (days == 1) {
      return '1 day before';
    } else if (days < 7) {
      return '$days days before';
    } else if (days % 7 == 0) {
      int weeks = days ~/ 7;
      if (weeks == 1) {
        return '1 week before';
      } else {
        return '$weeks weeks before';
      }
    } else if (days % 30 == 0) {
      int months = days ~/ 30;
      if (months == 1) {
        return '1 month before';
      } else {
        return '$months months before';
      }
    }
    return null;
  }

  String? convertToDays(String? notificationPeriod) {
    if (notificationPeriod == null) {
      return null;
    }
    if (notificationPeriod.contains('day')) {
      return int.parse(notificationPeriod.split(' ')[0]).toString();
    } else if (notificationPeriod.contains('week')) {
      return (int.parse(notificationPeriod.split(' ')[0]) * 7).toString();
    } else if (notificationPeriod.contains('month')) {
      return (int.parse(notificationPeriod.split(' ')[0]) * 30).toString();
    }
    return null;
  }
}
