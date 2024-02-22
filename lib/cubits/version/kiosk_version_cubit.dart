import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../repositories/user_repository.dart';

part 'kiosk_version_state.dart';

class KioskVersionCubit extends Cubit<KioskVersionState> {
  final UserRepository kioskVersionRepository;

  KioskVersionCubit({required this.kioskVersionRepository})
      : super(KioskVersionState.initial()) {
    // Automatically check the kiosk version when the cubit is created.
    checkKioskVersion();
  }

  /// Checks the kiosk version and updates the state accordingly.
  void checkKioskVersion() async {
    emit(state.copyWith(status: KioskVersionStatus.loading));

    try {
      final String kioskVersion = await kioskVersionRepository.checkVersion();
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      // Compare the app's version with the kiosk version to determine if an update is required.
      bool isUpdateRequired =
          double.parse(packageInfo.version.trim().replaceAll(".", "")) >=
                  double.parse(kioskVersion.trim().replaceAll(".", ""))
              ? false
              : true;

      emit(state.copyWith(
        status: KioskVersionStatus.loaded,
        updateAvailable: isUpdateRequired,
      ));
    } catch (e) {
      // Handle any errors that occur during the version check.
      emit(state.copyWith(
          status: KioskVersionStatus.error, errorMessage: e.toString()));
    }
  }
}
