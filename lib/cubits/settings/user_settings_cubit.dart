import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';
import 'package:local_auth/local_auth.dart';

part 'user_settings_state.dart';

class UserSettingsCubit extends Cubit<UserSettingsState> {
  final LocalStorage localStorage;
  final LocalAuthentication localAuthentication;

  /// Creates an instance of [UserSettingsCubit].
  ///
  /// [localStorage] is used to read and write user settings to local storage.
  /// [localAuthentication] is used for biometric authentication.
  UserSettingsCubit({
    required this.localAuthentication,
    required this.localStorage,
  }) : super(const UserSettingsState()) {
    final data = localStorage.readUserSettings();
    if (data != null) {
      emit(UserSettingsState.fromJson(data));
    }
  }

  /// Reset the user settings to their initial values.
  void reset() {
    try {
      emit(const UserSettingsState());
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle the offline mode setting.
  void toggleOfflineMode() {
    try {
      emit(state.copyWith(offlineMode: !state.offlineMode));
      writeToLocalStorage();
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle the setting for login with biometrics.
  ///
  /// This method prompts the user for biometric authentication and
  /// toggles the loginWithBiometrics setting if authentication is successful.
  Future<void> toggleLoginWithBiometrics() async {
    try {
      final didAuthenticate =
          await authenticate(reason: "Enable login with biometrics");

      if (didAuthenticate) {
        emit(state.copyWith(loginWithBiometrics: !state.loginWithBiometrics));
        writeToLocalStorage();
      }
    } catch (e) {
      throw e.toString();
    }
  }

  /// Disable notifications.
  void disableNotification() async {
    try {
      emit(state.copyWith(notificationEnabled: false));
      writeToLocalStorage();
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle the setting to show Kroon balance.
  void toggleShowKroonBalance() async {
    try {
      emit(state.copyWith(showKroonBalance: !state.showKroonBalance));
      writeToLocalStorage();
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle the setting to show Kiosk balance.
  void toggleShowKioskBalance() async {
    try {
      emit(state.copyWith(showKioskBalance: !state.showKioskBalance));
      writeToLocalStorage();
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle the app theme.
  ///
  /// [theme] The selected theme mode (system, light, dark).
  void toggleTheme(ThemeMode theme) async {
    try {
      switch (theme) {
        case ThemeMode.system:
          emit(state.copyWith(
              systemThemeMode: true, darkMode: false, lightMode: false));
          break;
        case ThemeMode.light:
          emit(state.copyWith(
              systemThemeMode: false, darkMode: false, lightMode: true));
          break;
        case ThemeMode.dark:
          emit(state.copyWith(
              systemThemeMode: false, darkMode: true, lightMode: false));
          break;
      }

      writeToLocalStorage();
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle the onboarding screens.
  ///
  /// [isBusinessPlan] Specifies whether it's for a business plan.
  void toggleOnboarding({
    bool isBusinessPlan = false,
  }) async {
    try {
      if (isBusinessPlan) {
        emit(state.copyWith(showBusinessPlanIntroScreen: false));
      } else {
        emit(state.copyWith(showWorkerIntroScreen: false));
      }

      writeToLocalStorage();
    } catch (e) {
      rethrow;
    }
  }

  /// Change the visibility of a specific intro screen.
  ///
  /// [name] The name of the intro screen to change visibility for.
  void changeShowIntro(String name) {
    Map<String, bool> showIntro = Map.from(state.showIntroTour);
    showIntro[name] = false;
    emit(state.copyWith(showIntroTour: showIntro));
    writeToLocalStorage();
  }

  /// Authenticate the user using biometric authentication.
  ///
  /// [reason] The reason for the authentication request.
  ///
  /// Returns `true` if authentication is successful, otherwise `false`.
  Future<bool> authenticate({required String reason}) async {
    try {
      final bool didAuthenticate = await localAuthentication.authenticate(
          localizedReason: reason,
          options: const AuthenticationOptions(biometricOnly: true));
      return didAuthenticate;
    } on PlatformException catch (e) {
      // Handle specific authentication exceptions if needed.
      // Uncomment the code below and customize it as required.
      //
      // String message;
      // if (e.code == auth_error.notAvailable || e.code == "NotAvailable") {
      //   message = "Biometrics not available";
      // } else if (e.code == auth_error.notEnrolled || e.code == "notEnrolled") {
      //   message = "Biometrics not enrolled";
      // } else {
      //   message = e.toString();
      // }
      //
      // throw message;
      throw e.message.toString(); // Use the default error message for now.
    } catch (e) {
      rethrow;
    }
  }

  /// Write the current user settings to local storage.
  void writeToLocalStorage() {
    localStorage.writeUserSettings(state.toJson());
  }
}
