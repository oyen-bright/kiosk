import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as wv;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kiosk/models/permission.dart';
import 'package:kiosk/models/sales_report.dart';
import 'package:kiosk/models/user.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';

part 'user_login_state.dart';

class UserLoginCubit extends Cubit<UsersState> {
  final UserRepository userRepository;
  final FlutterSecureStorage flutterSecureStorage;
  late final wv.InAppWebViewController _webViewController;

  final LocalStorage localStorage;

  UserLoginCubit({
    required this.localStorage,
    required this.userRepository,
    required this.flutterSecureStorage,
  }) : super(UsersState.initial()) {
    final userDetails = localStorage.readUserDetails();
    if (userDetails != null) {
      emit(UsersState.initial(
          currentUser: User.fromJson(jsonDecode(userDetails))));
    }
  }

  /// Remove the current user's data from storage.
  ///
  /// This method clears user-related data from local storage.
  /// It's called when a user logs out.
  Future<void> removeCurrentUser() async {
    try {
      await localStorage.removeCurrentUser();
      final box = GetStorage();
      await box.erase();
      emit(UsersState.initial());
    } catch (e) {
      await localStorage.removeCurrentUser();
      emit(UsersState.initial());
    }
  }

  /// Clear web view data, including cache and storage.
  ///
  /// This method clears the web view's cache and storage.
  /// It's typically used when user-specific data should be removed.
  Future<void> clearWebViewData() async {
    await _webViewController.clearCache();
    await _webViewController.webStorage.localStorage.clear();
    await _webViewController.webStorage.sessionStorage.clear();
  }

  /// Check if a user is currently logged in.
  ///
  /// This method can be used to determine if a user is logged in.
  /// However, it's currently commented out in the code.
  void isLoggedIn() {
    // emit(state.copyWith(isLoggedIn: true));
  }

  /// Get the current user.
  ///
  /// This method retrieves the current user from local storage.
  /// If the user is not found, it returns null.
  User? get currentUser {
    final _localUserDetails = localStorage.readUserDetails();
    return state.currentUser ??
        (_localUserDetails != null
            ? User.fromJson(jsonDecode(_localUserDetails))
            : null);
  }

  /// Attempt user login with provided email and password.
  ///
  /// [usersEmail] is the user's email.
  ///
  /// [usersPassword] is the user's password.
  ///
  /// [isBioLogin] determines if it's a biometric login.
  ///
  /// [isOfflineLogin] determines if it's an offline login.
  ///
  /// This method initiates the user login process. It handles both regular
  /// login and biometric login scenarios, and it manages the storage of
  /// sensitive data.
  Future<void> userLogin({
    required String usersEmail,
    required String usersPassword,
    bool isBioLogin = false,
    bool isOfflineLogin = false,
  }) async {
    emit(state.copyWith(status: UserLoginStateStatus.loading));

    try {
      if (isBioLogin) {
        final pwd = await flutterSecureStorage.read(key: "usersPassword");
        if (pwd != null) {
          usersPassword = pwd;
        } else {
          throw "An error occurred \n Please login by inputting your password";
        }
      }

      final UsersState _userLoginState = await userRepository.userLogin(
        usersEmail: usersEmail,
        usersPassword: usersPassword,
      );

      if (!isOfflineLogin) {
        flutterSecureStorage.write(
          key: "usersPassword",
          value: usersPassword,
          aOptions: _getAndroidOptions(),
        );
      }

      emit(state.copyWith(
        status: _userLoginState.status,
        merchantBusinessProfile: _userLoginState.merchantBusinessProfile,
        userPermissions: _userLoginState.userPermissions,
      ));
      return;
    } catch (e) {
      emit(state.copyWith(
        status: UserLoginStateStatus.error,
        errorMessage: e.toString(),
      ));
      rethrow;
    }
  }
}

/// Options for Android related to secure storage.
AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
