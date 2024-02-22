import 'package:easy_localization/easy_localization.dart';
import 'package:kiosk/utils/utils.dart';

class User {
  final String name;
  final String email;
  final String firstName;
  final String lastName;
  final String defaultCurrencyId;
  final String contactNumber;
  final double kroonToken;
  final String walletId;
  final String? merchantBusinessName;
  final List address;
  final int? countryOfResidences;
  final bool kycComplete;
  final String? kycStatus;
  final bool kycSubmitted;
  final String? businessRegistrationNumber;
  List<dynamic>? virtualCards;

  User({
    required this.virtualCards,
    required this.merchantBusinessName,
    required this.address,
    required this.name,
    required this.countryOfResidences,
    required this.kycComplete,
    required this.kycSubmitted,
    required this.kycStatus,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.businessRegistrationNumber,
    required this.defaultCurrencyId,
    required this.contactNumber,
    required this.kroonToken,
    required this.walletId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        businessRegistrationNumber:
            json['business_registration_number'] ?? 'N/A',
        countryOfResidences: json["country_of_residence"],
        kycComplete: json["kyc_complete"],
        kycSubmitted: json["kyc_submitted"],
        kycStatus: json["kyc_status"],
        merchantBusinessName: toBeginningOfSentenceCase(
                Util.decodeString(json['merchant_business_name'])) ??
            json['merchant_business_name'],
        address: json['address'] ?? {},
        name: json['name'] ?? "name",
        firstName: Util.decodeString(json['first_name']),
        lastName: Util.decodeString(json['last_name']),
        defaultCurrencyId: json['default_currency_id'],
        contactNumber: json['contact_number'],
        kroonToken: double.parse(json['kroon_token']),
        walletId: json['wallet_id'],
        virtualCards: json["virtual_cards"],
        email: json['email'],
      );
    } catch (e) {
      rethrow;
    }
  }
}
