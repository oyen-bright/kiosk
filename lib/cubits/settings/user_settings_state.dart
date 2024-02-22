// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'user_settings_cubit.dart';

class UserSettingsState extends Equatable {
  final bool? notificationEnabled;
  final bool offlineMode;
  final bool loginWithBiometrics;
  final bool darkMode;
  final bool lightMode;
  final bool systemThemeMode;
  final bool showKroonBalance;
  final bool showKioskBalance;
  final Map<String, bool> showIntroTour;
  final bool showWorkerIntroScreen;
  final bool showBusinessPlanIntroScreen;
  const UserSettingsState({
    this.lightMode = true,
    this.notificationEnabled,
    this.offlineMode = true,
    this.loginWithBiometrics = false,
    this.darkMode = false,
    this.showIntroTour = const {
      "home": true,
      "register": true,
      "cart": true,
      "cashPayment": true,
      "payment": true,
      "newItem": true
    },
    this.systemThemeMode = false,
    this.showKroonBalance = false,
    this.showKioskBalance = false,
    this.showWorkerIntroScreen = true,
    this.showBusinessPlanIntroScreen = true,
  });

  @override
  List<Object?> get props => [
        notificationEnabled,
        offlineMode,
        lightMode,
        loginWithBiometrics,
        showKioskBalance,
        showKroonBalance,
        darkMode,
        showBusinessPlanIntroScreen,
        showWorkerIntroScreen,
        systemThemeMode,
        showIntroTour
      ];

  @override
  bool get stringify => true;

  UserSettingsState copyWith({
    bool? notificationEnabled,
    bool? offlineMode,
    bool? loginWithBiometrics,
    bool? darkMode,
    bool? lightMode,
    bool? systemThemeMode,
    bool? showKroonBalance,
    bool? showKioskBalance,
    Map<String, bool>? showIntroTour,
    bool? showWorkerIntroScreen,
    bool? showBusinessPlanIntroScreen,
  }) {
    return UserSettingsState(
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      offlineMode: offlineMode ?? this.offlineMode,
      loginWithBiometrics: loginWithBiometrics ?? this.loginWithBiometrics,
      darkMode: darkMode ?? this.darkMode,
      lightMode: lightMode ?? this.lightMode,
      systemThemeMode: systemThemeMode ?? this.systemThemeMode,
      showKroonBalance: showKroonBalance ?? this.showKroonBalance,
      showKioskBalance: showKioskBalance ?? this.showKioskBalance,
      showIntroTour: showIntroTour ?? this.showIntroTour,
      showWorkerIntroScreen:
          showWorkerIntroScreen ?? this.showWorkerIntroScreen,
      showBusinessPlanIntroScreen:
          showBusinessPlanIntroScreen ?? this.showBusinessPlanIntroScreen,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notificationEnabled': notificationEnabled,
      'offlineMode': offlineMode,
      'loginWithBiometrics': loginWithBiometrics,
      'darkMode': darkMode,
      'lightMode': lightMode,
      'systemThemeMode': systemThemeMode,
      'showKroonBalance': showKroonBalance,
      'showKioskBalance': showKioskBalance,
      'showIntroTour': showIntroTour,
      'showWorkerIntroScreen': showWorkerIntroScreen,
      'showBusinessPlanIntroScreen': showBusinessPlanIntroScreen,
    };
  }

  factory UserSettingsState.fromMap(Map<String, dynamic> map) {
    return UserSettingsState(
      notificationEnabled: map['notificationEnabled'],
      lightMode: map['lightMode'] as bool,
      offlineMode: map['offlineMode'] as bool,
      loginWithBiometrics: map['loginWithBiometrics'] as bool,
      darkMode: map['darkMode'] as bool,
      systemThemeMode: map['systemThemeMode'] as bool,
      showKroonBalance: map['showKroonBalance'] as bool,
      showKioskBalance: map['showKioskBalance'] as bool,
      showIntroTour: Map<String, bool>.from(map['showIntroTour']),
      showWorkerIntroScreen: map['showWorkerIntroScreen'] as bool,
      showBusinessPlanIntroScreen: map['showBusinessPlanIntroScreen'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSettingsState.fromJson(String source) =>
      UserSettingsState.fromMap(json.decode(source) as Map<String, dynamic>);
}
