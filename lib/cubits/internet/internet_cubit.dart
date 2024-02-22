import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

part 'internet_state.dart';

/// A Cubit (State Management) class to handle internet connectivity status.
class InternetCubit extends Cubit<InternetState> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final Connectivity connectivity;

  InternetCubit({required this.connectivity}) : super(const InternetState()) {
    // Initialize connectivity and listen for changes.
    initConnectivity();
    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  /// Initialize connectivity status by checking the current status.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (_) {
      return; // Unable to determine connectivity on this platform.
    }
    return _updateConnectionStatus(result);
  }

  /// Update the connection status based on the given [connectivityResult].
  Future<void> _updateConnectionStatus(
      ConnectivityResult connectivityResult) async {
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection.
      emit(state.copyWith(status: InternetStatus.noInternet));
    } else {
      try {
        // Attempt to lookup an internet address to verify connectivity.
        final result = await InternetAddress.lookup("example.com");
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          // Internet connection is available.
          emit(state.copyWith(status: InternetStatus.connected));
        }
      } on SocketException catch (_) {
        // Unable to lookup an internet address, indicating no internet connection.
        emit(state.copyWith(status: InternetStatus.noInternet));
      }
    }
  }

  @override
  Future<void> close() {
    // Cancel the connectivity subscription when the Cubit is closed.
    _connectivitySubscription.cancel();
    return super.close();
  }
}
