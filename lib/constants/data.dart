import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/login/support/faq/faq.dart';
import 'package:kiosk/views/login/support/feedback/user_feedback.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

List<Map<String, dynamic>> categoriesName = [
  {"Data": "Retail Store", "Title": LocaleKeys.retailStore.tr()},
  {"Data": "Grocery Store", "Title": LocaleKeys.groceryStore.tr()},
  {"Data": "Convenient Store", "Title": LocaleKeys.convenientStore.tr()},
  {"Data": "Beauty and Fashion", "Title": LocaleKeys.beautyAndFashion.tr()},
  {"Data": "Electronics", "Title": LocaleKeys.electronics.tr()},
  {"Data": "Services", "Title": LocaleKeys.services.tr()},
  {"Data": "Others", "Title": LocaleKeys.others.tr()},
];

final freeFeatures = <String>[
  LocaleKeys.cashRegister10Items.tr(),
  LocaleKeys.inventoryTracking.tr(),
  LocaleKeys.basicHelpSupport.tr(),
];
final kioskPlusFeatures = <String>[
  LocaleKeys.cashRegisterUnlimited.tr(),
  LocaleKeys.inventoryReport.tr(),
  LocaleKeys.salesReport.tr(),
  LocaleKeys.inventoryTracking.tr(),
  LocaleKeys.salesTracking.tr(),
  LocaleKeys.employeeManagement1.tr(),
  LocaleKeys.employeeReporting.tr(),
  LocaleKeys.emailReports.tr(),
  LocaleKeys.pdfReports.tr(),
  LocaleKeys.businessReport.tr(),
  LocaleKeys.dedicatedHelpSupport.tr(),
];
final kioskProFeatures = <String>[
  LocaleKeys.cashRegisterUnlimited.tr(),
  LocaleKeys.inventoryReport.tr(),
  LocaleKeys.salesReport.tr(),
  LocaleKeys.inventoryTracking.tr(),
  LocaleKeys.salesTracking.tr(),
  LocaleKeys.employeeManagement5Plus.tr(),
  LocaleKeys.employeeReporting.tr(),
  LocaleKeys.emailReports.tr(),
  LocaleKeys.pdfReports.tr(),
  LocaleKeys.businessReport.tr(),
  LocaleKeys.kioskAnalyticsDashboard.tr(),
  LocaleKeys.dedicatedHelpSupport.tr(),
];

final dataSupport = <Map>[
  {"icon": MdiIcons.helpBox, "title": "FAQ", "funtion": const FAQ()},
  {
    "icon": Icons.feedback,
    "title": LocaleKeys.sendFeedback.tr(),
    "funtion": const UserFeedBack()
  }
];

final dataSocials = <Map>[
  {
    "icon": MdiIcons.twitter,
    "title": "@kroonapp",
    "funtion": () async {
      try {
        if (!await launchUrl(Uri.parse("twitter://kroonapp"))) {
        } else {
          await launchUrl(Uri.parse('https://twitter.com/kroonapp'),
              mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        await launchUrl(Uri.parse('https://twitter.com/kroonapp'),
            mode: LaunchMode.externalApplication);
      }
    }
  },
  {
    "icon": MdiIcons.facebook,
    "title": "Kroon App",
    "funtion": () async {
      try {
        if (!await launchUrl(Uri.parse("fb://page/kroonapp"))) {
        } else {
          await launchUrl(Uri.parse('https://web.facebook.com/kroonapp'),
              mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        await launchUrl(Uri.parse('https://web.facebook.com/kroonapp'),
            mode: LaunchMode.externalApplication);
      }
    }
  },
  {
    "icon": MdiIcons.instagram,
    "title": "@Kroonapp",
    "funtion": () async {
      try {
        if (!await launchUrl(Uri.parse("instagram://Kroonapp"))) {
        } else {
          await launchUrl(Uri.parse('https://www.instagram.com/Kroonapp'),
              mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        await launchUrl(Uri.parse('https://www.instagram.com/Kroonapp'),
            mode: LaunchMode.externalApplication);
      }
    }
  }
];

final Map<String, dynamic> emailUsData = {
  "icon": Icons.mail,
  "title": 'support@mykroonapp.com',
  "funtion": () async {
    try {
      if (!await launchUrl(Uri.parse("mailto:support@mykroonapp.com?subject="
          "&body=''"))) {
      } else {
        await launchUrl(
            Uri.parse("mailto:support@mykroonapp.com?subject="
                "&body=''"),
            mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }
};
