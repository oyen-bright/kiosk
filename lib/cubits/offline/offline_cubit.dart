import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/cubits/internet/internet_cubit.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';

part 'offline_state.dart';

/// Cubit for managing offline mode and data synchronization.
class OfflineCubit extends Cubit<OfflineState> {
  final UserRepository userRepository;
  final LocalStorage localStorage;
  final InternetCubit internetCubit;

  // Stream subscription for monitoring internet connectivity changes.
  late final StreamSubscription internetCubitStreamSub;

  OfflineCubit({
    required this.localStorage,
    required this.internetCubit,
    required this.userRepository,
  }) : super(const OfflineState()) {
    // Subscribe to changes in internet connectivity status.
    internetCubitStreamSub = internetCubit.stream.listen((InternetState event) {
      switch (event.status) {
        case InternetStatus.initial:
          // Do nothing on initial status.
          break;
        case InternetStatus.noInternet:
          // When there's no internet connection.
          _noInternet();
          break;
        case InternetStatus.connected:
          // When internet connection is detected.
          connected();
          break;
        default:
      }
    });
  }

  /// Handle no internet connection.
  void _noInternet() {
    emit(state.copyWith(offlineStatus: OfflineStatus.offlineMode));
  }

  /// Check if the app is currently in offline mode.
  bool isOffline() {
    return state.offlineStatus == OfflineStatus.offlineMode;
  }

  /// Handle internet connection being established.
  void connected() async {
    try {
      final offlineProducts = localStorage.readOfflineProducts();
      final offlineCheckout = localStorage.readOfflineCheckOut();

      // Log offline data (for debugging purposes).
      log(offlineProducts.toString());

      if (offlineCheckout != null || offlineProducts != null) {
        // If there's offline data to sync.

        // Update offline status to indicate syncing is in progress.
        emit(state.copyWith(offlineStatus: OfflineStatus.isSyncing));

        // Perform data synchronization with the server (assuming a function `dumpOfflineData` exists).
        await userRepository.dumpOfflineData();

        // Update offline status to indicate syncing is complete.
        emit(state.copyWith(offlineStatus: OfflineStatus.isSynced));
      } else {
        // No offline data, app is online.

        // Update offline status to indicate connected.
        emit(state.copyWith(offlineStatus: OfflineStatus.connected));
      }
    } catch (e) {
      // Handle any errors that occur during synchronization.

      // Update offline status to indicate an error occurred.
      emit(state.copyWith(
          offlineStatus: OfflineStatus.error, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    // Clean up the subscription when the cubit is closed.
    internetCubitStreamSub.cancel();
    return super.close();
  }
}
