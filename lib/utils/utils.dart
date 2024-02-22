import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kiosk/cubits/User/users_cubit.dart';
import 'package:kiosk/models/cart_product.dart';
import 'package:kiosk/models/user.dart';
import 'package:kiosk/settings.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/amount_formatter.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'package:url_launcher/url_launcher.dart';

class Util {
  /// Sends an email with the given email address and subject.
  ///
  /// - [emailAddress] parameter is a string representing the recipient's email address.
  /// - [subject] parameter is a string representing the subject of the email.
  ///
  /// This method constructs a mailto URI with the provided email address and subject,
  /// and attempts to launch the email client with the generated URI.
  /// If the launch fails, an exception is thrown.
  static Future<void> sendEmail(String emailAddress, String subject) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: 'subject=$subject',
    );
    final String url = params.toString();

    if (!await launchUrl(params)) {
      throw Exception('Could not launch $url');
    }
  }

  static String? getFirstItem(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return null;
    }

    final key = data.keys.first;
    final value = data[key];

    if (value is List) {
      if (value.isEmpty) {
        return null;
      }

      return value.first.toString();
    }

    return null;
  }

  static checkIfDateIsInitialized() async {
    try {
      DateFormat('dd MMM', 'en');
      return;
    } catch (e) {
      await initializeDateFormatting('en_Us', null);
      return;
    }
  }

  /// Retrieves the currency from the authentication state.
  ///
  /// This method retrieves the business currency from the authentication state
  /// using the AuthenticationCubit provided by the context.
  ///
  /// Returns the business currency.
  static String getCurrency(BuildContext context) {
    final userState = context.read<UserCubit>().state;

    if (userState.permissions!.isAWorker) {
      return userState.permissions!.businessCurrency;
    }
    return userState.currentUser!.defaultCurrencyId;
  }

  /// Parses and formats an amount value.
  ///
  /// This method parses the amount value and formats it as a string with a specified currency.
  /// If no currency is provided, the default empty string is used.
  ///
  /// The [amount] parameter specifies the amount value to be parsed and formatted.
  /// The [currency] parameter specifies the currency symbol to be included in the formatted string.
  ///
  /// Returns the parsed and formatted amount string.
  static String parseAmount(dynamic amount, [String currency = ""]) {
    double value = double.tryParse(amount.toString()) ?? 0.0;
    String formattedAmount = value.toStringAsFixed(2);
    List<String> parts = formattedAmount.split('.');
    RegExp pattern = RegExp(r'\B(?=(\d{3})+(?!\d))');
    parts[0] = parts[0].replaceAll(pattern, ',');
    return currency.isNotEmpty
        ? currency + " " + parts.join('.')
        : parts.join('.');
  }

  static String getLocalizedCategory(String categoryName) {
    final listOfCategories = {
      "Airtime/Data": LocaleKeys.airtime_data.tr(),
      "Baby": LocaleKeys.baby.tr(),
      "Beverages": LocaleKeys.beverages.tr(),
      "Books": LocaleKeys.books.tr(),
      "Candy": LocaleKeys.candy.tr(),
      "Dairy": LocaleKeys.dairy.tr(),
      "Electronics": LocaleKeys.electronics.tr(),
      "Fashion": LocaleKeys.fashion.tr(),
      "Food": LocaleKeys.food.tr(),
      "Fresh Food": LocaleKeys.fresh_food.tr(),
      "Frozen": LocaleKeys.frozen.tr(),
      "General Merchandise": LocaleKeys.general_merchandise.tr(),
      "Groceries": LocaleKeys.groceries.tr(),
      "Hair Care": LocaleKeys.hair_care.tr(),
      "Household Cleaning": LocaleKeys.household_cleaning.tr(),
      "Manual Sale": LocaleKeys.manual_sale.tr(),
      "Service": LocaleKeys.service.tr(),
      "Skin Care": LocaleKeys.skin_care.tr(),
      "Toiletries": LocaleKeys.toiletries.tr(),
      "Toys": LocaleKeys.toys.tr()
    };

    return listOfCategories[categoryName] ?? categoryName;
  }

  static Future<Uint8List> _getImageFromAsset(String iconPath) async {
    Future<Uint8List> readFileBytes(String path) async {
      ByteData fileData = await rootBundle.load(path);
      Uint8List fileUnit8List = fileData.buffer
          .asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
      return fileUnit8List;
    }

    return await readFileBytes(iconPath);
  }

  static Future<void> sunmiPrinterPrintInvoice(
      {required User currentUser,
      required String customerToPay,
      required List<ProductCart> cartItem,
      required String orderId}) async {
    String qrData = AppSettings.base + "invoice/$orderId/";
    await SunmiPrinter.initPrinter();
    await SunmiPrinter.startTransactionPrint(true);
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    Uint8List byte = await _getImageFromAsset('assets/images/Group 6.png');
    await SunmiPrinter.printImage(byte);
    await SunmiPrinter.printText(currentUser.merchantBusinessName ?? "",
        style: SunmiStyle(bold: true, fontSize: SunmiFontSize.LG));
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.printText("Email :" + currentUser.email);
    await SunmiPrinter.printText("Contact NO :" + currentUser.contactNumber);
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
    await SunmiPrinter.printText("Receipt ID: $orderId",
        style: SunmiStyle(bold: true));
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(text: 'Item', width: 12, align: SunmiPrintAlign.LEFT),
      ColumnMaker(text: 'Qty', width: 6, align: SunmiPrintAlign.CENTER),
      ColumnMaker(text: 'TOT', width: 12, align: SunmiPrintAlign.RIGHT),
    ]);
    await SunmiPrinter.resetBold();

    for (var element in cartItem) {
      await SunmiPrinter.printRow(cols: [
        ColumnMaker(
            text: element.product["product_name"],
            width: 12,
            align: SunmiPrintAlign.LEFT),
        ColumnMaker(
            text: 'X${element.quantity}',
            width: 6,
            align: SunmiPrintAlign.CENTER),
        ColumnMaker(
            text: currentUser.defaultCurrencyId +
                " " +
                amountFormatter(element.product["price"]),
            width: 12,
            align: SunmiPrintAlign.RIGHT),
      ]);
    }

    await SunmiPrinter.line();
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(text: 'TOTAL', width: 25, align: SunmiPrintAlign.LEFT),
      ColumnMaker(
          text: currentUser.defaultCurrencyId + " " + customerToPay,
          width: 12,
          align: SunmiPrintAlign.RIGHT),
    ]);
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText(DateTime.now().toString().substring(0, 16));

    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.printText("Scan here for online invoice");

    await SunmiPrinter.printQRCode(qrData);

    await SunmiPrinter.printText("www.kroonapp.com");

    await SunmiPrinter.exitTransactionPrint(true);
  }

  static String generateProductSKU() {
    final faker = Faker();
    const alphanumeric = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return faker.randomGenerator.fromCharSet(alphanumeric, 6);
  }

  static String decodeString(dynamic data) {
    try {
      return utf8.decode(
        data.toString().replaceAll("â", "'").runes.toList(),
      );
    } catch (e) {
      return data.toString();
    }
  }
}
