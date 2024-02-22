import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';

part 'payment_method_state.dart';

/// A Cubit responsible for managing payment methods-related state and actions.
class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  final UserCubit userCubit;
  final LocalStorage localStorage;

  PaymentMethodCubit({
    required this.localStorage,
    required this.userCubit,
  }) : super(const PaymentMethodState()) {
    final data = localStorage.readPaymentMethods();
    if (data != null) {
      emit(PaymentMethodState.fromJson(data));
    }
  }

  /// Retrieves a list of available payment methods.
  ///
  /// The list may include "Mobile Money" and "kroon" if the user has the necessary permissions.
  List<String> getPaymentMethodsList() {
    List<String> paymentMethods = [
      "Mobile Money",
    ];
    if (userCubit.state.permissions!.acceptKroon) {
      paymentMethods.add("kroon");
    }
    return paymentMethods;
  }

  /// Adds a new payment method to the list of payment methods.
  ///
  /// Checks if the payment method already exists before adding it.
  void addPaymentMethod(PaymentMethod paymentMethod) {
    // Check if paymentMethod already exists
    final paymentMethods = state.paymentMethods;

    final paymentMethodExists =
        paymentMethods.any((method) => method.name == paymentMethod.name);

    if (paymentMethodExists) {
      // If paymentMethod already exists, do nothing
      return;
    }
    final updatedList = List<PaymentMethod>.from(state.paymentMethods)
      ..add(paymentMethod);
    emit(state.copyWith(paymentMethods: updatedList));
    writeToLocalStorage();
  }

  /// Updates the enabled status of a payment method at the specified index.
  void updatePaymentMethodEnabled(int index, bool isEnabled) {
    final updatedList = List<PaymentMethod>.from(state.paymentMethods)
      ..[index] = state.paymentMethods[index].copyWith(isEnabled: isEnabled);
    emit(state.copyWith(paymentMethods: updatedList));
    writeToLocalStorage();
  }

  /// Removes a payment method from the list at the specified index.
  void removePaymentMethod(int index) {
    final updatedList = List<PaymentMethod>.from(state.paymentMethods)
      ..removeAt(index);

    emit(state.copyWith(paymentMethods: updatedList));
    writeToLocalStorage();
  }

  /// Writes the current payment methods state to local storage.
  void writeToLocalStorage() {
    localStorage.writePaymentMethods(state.toJson());
  }
}
