import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSettings {
  static const String base = "https://kroonapp.xyz/";
  // static String base = "https://mykroonapp.com/";
  static const bool isHuaweiDevice = false;
  static const bool isSunmiDevice = false;
  static const bool huaweiInAppSubscriptionTest = false;

  static Map<String, String> header = {
    'Content-Type': 'application/json',
    "accept": "application/json",
    'KOK-Authentication-Token': dotenv.env["KOK-Authentication-Token"]!,
    "Charset": 'utf-8',
  };
}
