import 'package:flutter/material.dart';

class ShareHOlder {
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController shareController;
  final TextEditingController sharePriceController;

  ShareHOlder(this.nameController, this.addressController, this.shareController,
      this.sharePriceController);
}
