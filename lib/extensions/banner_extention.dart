import 'package:flutter/material.dart';
import 'package:kiosk/widgets/banners/no_internet_banner.dart';

extension BannerExtension on BuildContext {
  void showBanner({
    bool isSyncing = false,
    bool syncDone = false,
    bool errorSync = false,
    String errorMessage = "",
  }) {
    // Get the ScaffoldMessenger for the current BuildContext.
    final scaffoldMessenger = ScaffoldMessenger.of(this);

    // Remove any existing MaterialBanner to avoid duplicates.
    scaffoldMessenger.removeCurrentMaterialBanner();

    // Show a new MaterialBanner based on the provided parameters.
    scaffoldMessenger.showMaterialBanner(
      // Use the showMaterialBanner function to generate the banner.
      showMaterialBanner(
        this,
        isSyncing: isSyncing,
        syncDone: syncDone,
        errorSync: errorSync,
        errorMessage: errorMessage,
      ),
    );
  }
}
