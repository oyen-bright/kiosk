import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/service/app_exceptions/app_exceptions.dart';
import 'package:kiosk/utils/compress_image.dart';
import 'package:kiosk/utils/generate_number.dart';
import 'package:kiosk/views/generate_agreement/generate_pdf.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tuple/tuple.dart';

import '../service/user_services.dart';

class UserRepository {
  final UserServices userServices;
  UserRepository({
    required this.userServices,
  }) {
    final box = GetStorage();
    box.erase();
  }

  static Future<String> get getPlatform async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "Unknown";
    } else {
      return 'Unknown';
    }
  }

  /// Checks the current version of the kiosk.
  ///
  /// Returns:
  ///
  /// A Future that resolves to the current kiosk version.
  Future<String> checkVersion() async {
    try {
      final String version = await userServices.getKioskVersion();
      return version;
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Creates a user account.
  ///
  /// Parameters:
  ///
  /// - `firstName`: First name of the user.
  /// - `lastName`: Last name of the user.
  /// - `email`: Email of the user.
  /// - `gender`: Gender of the user.
  /// - `dob`: Date of birth of the user.
  /// - `stateProvince`: State/province ID.
  /// - `phoneNumber`: Phone number of the user.
  /// - `governmentOrganizationName`: Name of the government organization.
  /// - `countryISO2`: ISO2 code of the country of residence.
  /// - `password`: Password of the user.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a message indicating the account creation status.
  Future<String> createAccount(
      {required String firstName,
      required String lastName,
      required String email,
      required String gender,
      required String dob,
      required int? stateProvince,
      required String phoneNumber,
      required String governmentOrganizationName,
      required String countryISO2,
      required String password}) async {
    try {
      // Creating the payload for account creation

      final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

      String? deviceId = await getPlatform;

      final firebaseToken = await _firebaseMessaging.getToken();
      final payload = {
        "device_id": firebaseToken ?? " ",
        "first_name": toBeginningOfSentenceCase(firstName),
        "last_name": toBeginningOfSentenceCase(lastName),
        "email": email.toLowerCase(),
        "gender": gender.toLowerCase(),
        "date_of_birth": dob,
        "platform": "kiosk",
        "country_province": stateProvince,
        "government_organization":
            governmentOrganizationName.isNotEmpty ? true : false,
        "government_organization_name": governmentOrganizationName.isNotEmpty
            ? governmentOrganizationName
            : null,
        "contact_number": phoneNumber,
        "country_of_residence": countryISO2.toString().toUpperCase(),
        "account_type": "merchant",
        "accept_terms": true,
        "agreed_to_data_usage": true,
        "email_verification": true,
        "password": password.toString().trim(),
        "device_fingerprint": deviceId.toString()
      };
      return userServices.createUserAccount(payload: payload);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Logs the user out.
  ///
  /// Returns:
  ///
  /// A Future that resolves when the logout is complete.
  Future<void> userLogout() async {
    try {
      return await userServices.logOUtUser();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Logs the user in.
  ///
  /// Parameters:
  ///
  /// - `usersEmail`: Email of the user.
  /// - `usersPassword`: Password of the user.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a UsersState object representing the user's state.
  Future<UsersState> userLogin({
    required String usersEmail,
    required String usersPassword,
  }) async {
    try {
      // Perform user login and construct the UsersState object
      final Map<String, dynamic> jsonData = await userServices.userLogin(
          usersEmail: usersEmail, usersPassword: usersPassword);

      return UsersState(
          loginDetails: {
            "usersEmail": usersEmail,
          },
          status: UserLoginStateStatus.loaded,
          merchantBusinessProfile: jsonData["merchant_business_profle"] ?? [],
          userPermissions: Permissions(
              hasPromoCode: jsonData["promo_code"],
              businessCurrency: jsonData["business_currency"] ?? "",
              merchantWalletId: jsonData["merchant_wallet_id"] ?? "",
              merchantSubscription:
                  jsonData["merchant_subscription"] ?? "basic",
              acceptKroon: jsonData["merchant_accept_kroon"] ?? false,
              isAWorker: jsonData["merchant_role"] == null
                  ? false
                  : jsonData["merchant_role"] == "merchant"
                      ? false
                      : true,
              accountType: jsonData["merchant_role"] == null ||
                      jsonData["merchant_role"] != "merchant"
                  ? "personal"
                  : "merchant"));
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Switches the user's personal account to a merchant account.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a message indicating the status of the switch.
  Future<String> switchToMerchant() async {
    try {
      return await userServices.switchToMerchant();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves a list of generated business plans.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a list of generated business plans.
  Future<List<Map<String, dynamic>>> generatedBusinessPlans() async {
    try {
      return await userServices.getGeneratedBusinessPlans();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves all generated agreements.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a map containing all generated agreements.
  Future<Map<String, dynamic>> generatedAgreements() async {
    try {
      return await userServices.getAllAgreements();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves available surveys.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a list of available surveys.
  Future<List> getAvailableSurveys() async {
    try {
      return await userServices.getAvailableSurveys();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Submits a survey.
  ///
  /// Parameters:
  ///
  /// - `result`: List of survey question and answer pairs.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a message indicating the status of survey submission.
  Future<String> submitSurvey({required List<Map> result}) async {
    try {
      final payload = {"survey_qa": result};
      return await userServices.submitSurvey(payload);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Deletes an agreement.
  ///
  /// Parameters:
  ///
  /// - `id`: Agreement ID.
  /// - `type`: Type of agreement (AgreementType).
  ///
  /// Returns:
  ///
  /// A Future that resolves when the deletion is complete.
  Future deleteAgreement({
    required String id,
    required AgreementType type,
  }) async {
    try {
      return await userServices.deleteAgreement(id: id, type: type);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves data for a generated business plan.
  ///
  /// Parameters:
  ///
  /// - `id`: ID of the generated business plan.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a map containing data for the generated business plan.
  Future<Map<String, dynamic>> generatedBusinessPlansGetData(String id) async {
    try {
      return await userServices.getGeneratedBusinessPlanGetData(id: id);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Generates an employee agreement.
  ///
  /// Generates an employee agreement using the provided data and signature file.
  ///
  /// Parameters:
  ///
  /// - `data`: Map containing agreement data.
  /// - `file`: Signature file for the agreement.
  ///
  /// Returns:
  ///
  /// A Future that resolves to the generated employee agreement.
  Future generateEmployeeAgreement(Map<String, dynamic> data, File file) async {
    try {
      return await userServices.generateEmployeeAgreement(data, [
        {"name": "signature", "file": file}
      ]);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Generates a share agreement.
  ///
  /// Generates a share agreement using the provided data and signature file.
  ///
  /// Parameters:
  ///
  /// - `data`: Map containing agreement data.
  /// - `file`: Signature file for the agreement.
  ///
  /// Returns:
  ///
  /// A Future that resolves to the generated share agreement.
  Future generateShareAgreement(Map<String, dynamic> data, File file) async {
    try {
      return await userServices.generateShareAgreement(data, [
        {"name": "signature", "file": file}
      ]);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Generates a loan agreement.
  ///
  /// Generates a loan agreement using the provided data and signature file.
  ///
  /// Parameters:
  ///
  /// - `data`: Map containing agreement data.
  /// - `file`: Signature file for the agreement.
  ///
  /// Returns:
  ///
  /// A Future that resolves to the generated loan agreement.
  Future generateLoanAgreement(Map<String, dynamic> data, File file) async {
    try {
      return await userServices.generateLoanAgreement(data, [
        {"name": "signature", "file": file}
      ]);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Generates a good and services agreement.
  ///
  /// Generates a good and services agreement using the provided data and signature file.
  ///
  /// Parameters:
  ///
  /// - `data`: Map containing agreement data.
  /// - `file`: Signature file for the agreement.
  ///
  /// Returns:
  ///
  /// A Future that resolves to the generated good and services agreement.
  Future generateGoodServicesAgreement(
      Map<String, dynamic> data, File file) async {
    try {
      return await userServices.generateGoodAndServiceAgreement(data, [
        {"name": "signature", "file": file}
      ]);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Generates a business plan.
  ///
  /// Generates a business plan using the provided data.
  ///
  /// Parameters:
  ///
  /// - `businessCategory`: Business category.
  /// - `numberOfEmployee`: Number of employees.
  /// - `expenses`: List of expenses.
  /// - `periodOfReport`: Period of the report.
  /// - `yearOfOperation`: Year of operation.
  ///
  /// Returns:
  ///
  /// A Future that resolves to the generated business plan.
  Future<String> businessPlan({
    required String businessCategory,
    required String numberOfEmployee,
    required List<Expense> expenses,
    required String periodOfReport,
    required String yearOfOperation,
  }) async {
    try {
      return await userServices.generateBusinesPlan(
        yearOfOperation: yearOfOperation,
        businessCategory: businessCategory,
        expenses: expenses.map((e) {
          return {
            "expenses": e.name,
            "expenses_amount": e.valueController.text.replaceAll(",", "")
          };
        }).toList(),
        numberOfEmployee: numberOfEmployee,
        periodOfReport: periodOfReport,
      );
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Sends an OTP to the user's email.
  ///
  /// Sends an OTP (One-Time Password) to the provided email address.
  ///
  /// Parameters:
  ///
  /// - `email`: User's email address.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a message indicating the status of the OTP sending.
  Future<String> sendOTP({required String email}) async {
    try {
      return await userServices.sendUserOTP(email: email);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Verifies an OTP for the user's email.
  ///
  /// Verifies the provided OTP (One-Time Password) for the user's email address.
  ///
  /// Parameters:
  ///
  /// - `email`: User's email address.
  /// - `pin`: OTP (One-Time Password) to verify.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a message indicating the status of OTP verification.
  Future<String> verifyOtp({required String email, required String pin}) async {
    try {
      return await userServices.verifyOtp(email: email, pin: pin);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Switches the business profile.
  ///
  /// Switches the business profile using the provided ID with user services.
  /// Fetches user information and sales report after the profile switch.
  ///
  /// Parameters:
  ///
  /// - `id`: The ID of the business profile to switch to.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a list containing user information and sales report.
  Future<List> switchBusinessProfile({
    required String id,
  }) async {
    try {
      // Switch business profile
      await userServices.selectBusinessProfile(id: id);

      // Fetch user information and sales report in parallel
      return await Future.wait([getUsersInformation(), getSalesReport()]);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Fetches the user's information.
  ///
  /// Fetches the user's information using user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a User object containing the user's information.
  Future<User> getUsersInformation() async {
    try {
      // Fetch user information
      return await userServices.getUserInformation();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Fetches the business report.
  ///
  /// Fetches the business report using user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a list of dynamic containing the business report data.
  Future<List<dynamic>> getBusinessReport() async {
    try {
      // Fetch business report
      return await userServices.getFinancialReport();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Fetches the sales report.
  ///
  /// Fetches the sales report using user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a SalesReport object containing the sales report data.
  Future<SalesReport> getSalesReport() async {
    try {
      // Fetch sales report
      return await userServices.getUserSalesReport();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Sends a password reset request.
  ///
  /// Sends a password reset request using the provided email with user services.
  ///
  /// Parameters:
  ///
  /// - `email`: The email for which to initiate the password reset.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string indicating the result of the password reset request.
  Future<String> forgetPassword({
    required String email,
  }) async {
    try {
      // Call user services to initiate password reset
      return await userServices.passwordReset(email: email);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Changes the user's password.
  ///
  /// Changes the user's password using the provided old and new passwords with user services.
  ///
  /// Parameters:
  ///
  /// - `oldPassword`: The old password of the user.
  /// - `newPassword`: The new password to set for the user.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string indicating the result of the password change.
  Future<String> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Call user services to change the user's password
      return await userServices.changePassword(oldPassword, newPassword);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Resets the user's password.
  ///
  /// Resets the user's password using the provided email and new password with user services.
  ///
  /// Parameters:
  ///
  /// - `email`: The email of the user.
  /// - `password`: The new password to set for the user.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string indicating the result of the password reset.
  Future<String> resetPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Call user services to reset the user's password
      return await userServices.resetUsersPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Updates business information.
  ///
  /// Updates the user's business information using the provided parameters with user services.
  ///
  /// Parameters:
  ///
  /// - `businessName`: The name of the business.
  /// - `businessRegistrationNumber`: The registration number of the business.
  /// - `businessContact`: The contact number of the business.
  /// - `businessCategory`: The categories of the business.
  /// - `businessType`: The type of the business.
  /// - `id`: The ID of the business.
  /// - `businessAddress`: The address of the business.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string indicating the result of the business information update.
  Future<String> updateBusinessInformation({
    required String businessName,
    required String businessRegistrationNumber,
    required String businessContact,
    required List businessCategory,
    required String businessType,
    required String id,
    required String businessAddress,
  }) async {
    try {
      // Call user services to update business information
      return await userServices.updateUsersBusinessInformation(
        businessName,
        businessRegistrationNumber,
        businessContact,
        businessCategory,
        businessType,
        businessAddress,
        id,
      );
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Verifies a worker's email.
  ///
  /// Verifies a worker's email using the provided email with user services.
  ///
  /// Parameters:
  ///
  /// - `email`: The email of the worker.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a map containing worker verification details.
  Future<Map<String, dynamic>?> verityWorkersEmail({
    required String email,
  }) async {
    try {
      // Try to verify the worker's email
      return await userServices.verifyWorkersEmail(email);
    } on NotFoundException {
      // If email not found, send OTP and return null
      await userServices.sendUserOTP(email: email);
      return null;
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Creates a new worker.
  ///
  /// Creates a new worker using the provided parameters with user services.
  ///
  /// Parameters:
  ///
  /// - `firstName`: The first name of the worker.
  /// - `lastName`: The last name of the worker.
  /// - `email`: The email of the worker.
  /// - `contactNumber`: The contact number of the worker.
  /// - `countryISO2`: The ISO2 code of the worker's country.
  /// - `gender`: The gender of the worker.
  /// - `password`: The password for the worker.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string indicating the result of the worker creation.
  Future<String> createWorker({
    required String firstName,
    required String lastName,
    required String email,
    required String contactNumber,
    required String countryISO2,
    required String gender,
    required String password,
  }) async {
    try {
      // Call user services to create a new worker
      return await userServices.createWorker(
        firstName,
        lastName,
        email,
        contactNumber,
        countryISO2,
        gender,
        password,
      );
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Adds a worker.
  ///
  /// Adds a worker using the provided email with user services.
  ///
  /// Parameters:
  ///
  /// - `email`: The email of the worker to be added.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string indicating the result of the worker addition.
  Future<String> addWorker({
    required String email,
  }) async {
    try {
      // Call user services to add the worker
      return await userServices.addWorker(email);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Removes a worker.
  ///
  /// Removes a worker using the provided email with user services.
  ///
  /// Parameters:
  ///
  /// - `email`: The email of the worker to be removed.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string indicating the result of the operation.
  Future<String> removeWorker({
    required String email,
  }) async {
    try {
      // Call user services to remove the worker
      return await userServices.removeWorker(email);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves a list of workers.
  ///
  /// Fetches a list of workers using user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a list of Worker objects.
  Future<List<Worker>> getWorkerList() async {
    try {
      // Call user services to retrieve the worker list
      return await userServices.workersList();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves details of a worker.
  ///
  /// Fetches details of a worker using the provided email with user services.
  ///
  /// Parameters:
  ///
  /// - `email`: The email of the worker.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a map containing worker details.
  Future<Map<String, List<dynamic>>> getWorkerDetails({
    required String email,
  }) async {
    try {
      // Call user services to retrieve worker details
      return await userServices.workerDetails(email);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Sends user feedback.
  ///
  /// Sends user feedback using the provided email, subject, and message with user services.
  ///
  /// Parameters:
  ///
  /// - `email`: The email of the user sending the feedback.
  /// - `subject`: The subject of the feedback.
  /// - `message`: The feedback message.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string indicating the result of the feedback submission.
  Future<String> sendFeedback({
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      // Call user services to send user feedback
      return await userServices.sendUsersFeedback(
        email: email,
        subject: subject,
        message: message,
      );
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves user sales.
  ///
  /// Fetches user sales using optional query parameters and a nextPage token with user services.
  ///
  /// Parameters:
  ///
  /// - `queryParameters`: Optional query parameters for filtering sales.
  /// - `nextPage`: The nextPage token for paginating results.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a map containing user sales and other details.
  Future<Map<String, dynamic>> getUsersSales({
    Map<String, dynamic>? queryParameters,
    String? nextPage,
  }) async {
    try {
      // Call user services to retrieve user sales
      Map<String, dynamic> response =
          await userServices.getUserSales(queryParameters, nextPage);

      // Convert the 'sales' list to a list of Sales objects
      response['sales'] = (response['sales'] as List<dynamic>)
          .map((e) => Sales.fromJson(e))
          .toList();

      return response;
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves sale details.
  ///
  /// Fetches details of a sale using the provided sale ID with user services.
  ///
  /// Parameters:
  ///
  /// - `saleId`: The ID of the sale.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a list containing sale details.
  Future<List<dynamic>> getSaleDetails({
    required String saleId,
  }) async {
    try {
      // Call user services to retrieve sale details
      return await userServices.getUserSaleDetails(saleId);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Verifies a purchase token.
  ///
  /// Verifies a purchase token using the provided data, platform, and token ID with user services.
  ///
  /// Parameters:
  ///
  /// - `data`: The purchase data.
  /// - `platform`: The platform of the purchase.
  /// - `tokenId`: The token ID of the purchase.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a tuple containing a boolean indicating success and an optional error message.
  Future<Tuple2<bool, String?>> verifyPurchase(
    String data, {
    required String platform,
    required String tokenId,
  }) async {
    try {
      // Call user services to verify the purchase token
      return await userServices.verifySubscriptionToken(
        platform: platform,
        tokenId: tokenId,
        data: data,
      );
    } catch (e) {
      // Return a tuple indicating failure and the error message
      return Tuple2(false, e.toString());
    }
  }

  /// Migrates a subscription plan.
  ///
  /// Migrates a subscription plan using the provided data, platform, expiration date,
  /// yearly product ID, subscription ID (optional), and product ID with user services.
  ///
  /// Parameters:
  ///
  /// - `data`: The migration data.
  /// - `platform`: The platform of the migration.
  /// - `expDate`: The expiration date.
  /// - `yearlyProductID`: The yearly product ID.
  /// - `subscriptionId`: The subscription ID (optional).
  /// - `productId`: The product ID.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a boolean indicating the success of the migration.
  Future<bool> migrateSubscriptionPlan(
    String data, {
    required String platform,
    required String expDate,
    required String yearlyProductID,
    String? subscriptionId,
    required String productId,
  }) async {
    try {
      // Call user services to migrate the subscription plan
      return await userServices.migrateSubscriptionPlan(
        platform: platform,
        yearlyProductID: yearlyProductID,
        productId: productId,
        data: data,
        expDate: expDate,
        subscriptionId: subscriptionId,
      );
    } catch (e) {
      // Return false if migration fails
      return false;
    }
  }

  /// Retrieves terms and conditions.
  ///
  /// Fetches terms and conditions using user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string containing the terms and conditions.
  Future<String> getTermsAndConditions() async {
    try {
      // Call user services to retrieve terms and conditions
      return await userServices.termsAndConditions();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves privacy policy.
  ///
  /// Fetches privacy policy using user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string containing the privacy policy.
  Future<String> getPrivacyPolicy() async {
    try {
      // Call user services to retrieve privacy policy
      return await userServices.privacyPolicy();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves frequently asked questions.
  ///
  /// Fetches frequently asked questions using user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a list containing FAQ items.
  Future<List> getFAQ() async {
    try {
      // Call user services to retrieve FAQ
      return await userServices.fAQ();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves e-learning videos.
  ///
  /// Fetches e-learning videos using user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a list of dynamic containing e-learning video information.
  Future<List<dynamic>> getELearningVideos() async {
    try {
      // Call user services to retrieve e-learning videos
      return await userServices.eLearningVideo();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Verifies a promo code.
  ///
  /// Verifies a promo code using the provided promo code and user services.
  ///
  /// Parameters:
  ///
  /// - `promoCode`: The promo code to verify.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string containing the result of the promo code verification.
  Future<String> verifyPromoCode({
    required String promoCode,
  }) async {
    try {
      // Call user services to verify the promo code
      return await userServices.promoCode(promoCode);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Creates a transaction PIN with user login.
  ///
  /// Creates a transaction PIN using the provided transaction PIN, user name,
  /// and password with user login and user services.
  ///
  /// Parameters:
  ///
  /// - `transactionPIn`: The new transaction PIN to create.
  /// - `userName`: The user's email or username.
  /// - `password`: The user's password.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string containing the result of the transaction PIN creation.
  Future<String> createTransactionPinWithLogin({
    required String transactionPIn,
    required String userName,
    required String password,
  }) async {
    try {
      // Login the user using provided credentials
      await userLogin(usersEmail: userName, usersPassword: password);

      // Call user services to create the transaction PIN
      final response =
          await userServices.createUsersTransactionPin(transactionPIn);

      // Format the response to sentence case
      return toBeginningOfSentenceCase(response) ?? response;
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Creates a transaction PIN.
  ///
  /// Creates a transaction PIN using the provided transaction PIN and user services.
  ///
  /// Parameters:
  ///
  /// - `transactionPIn`: The new transaction PIN to create.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string containing the result of the transaction PIN creation.
  Future<String> createTransactionPin({
    required String transactionPIn,
  }) async {
    try {
      // Call user services to create the transaction PIN
      final response =
          await userServices.createUsersTransactionPin(transactionPIn);

      // Format the response to sentence case
      return toBeginningOfSentenceCase(response) ?? response;
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Changes a transaction PIN.
  ///
  /// Changes the transaction PIN using the provided old transaction PIN, new transaction PIN,
  /// and user services.
  ///
  /// Parameters:
  ///
  /// - `oldTransactionPIn`: The old transaction PIN.
  /// - `newTransactionPin`: The new transaction PIN to set.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string containing the result of the transaction PIN change.
  Future<String> changeTransactionPin({
    required String oldTransactionPIn,
    required String newTransactionPin,
  }) async {
    try {
      // Call user services to change the transaction PIN
      final response = await userServices.changeUsersTransactionPin(
        oldTransactionPIn,
        newTransactionPin,
      );

      // Format the response to sentence case
      return toBeginningOfSentenceCase(response) ?? response;
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves business information.
  ///
  /// Fetches business information using user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a map containing business information.
  Future<Map<String, dynamic>> getBusinessInformation() async {
    try {
      // Call user services to retrieve business information
      return await userServices.usersBusinessInformation();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Creates or updates a user address.
  ///
  /// Creates or updates a user address with the provided details using user services.
  ///
  /// Parameters:
  ///
  /// - `type`: The type of address (e.g., "Current Address" or "Permanent Address").
  /// - `flatNumber`: The flat or apartment number.
  /// - `streetName`: The name of the street.
  /// - `buildingName`: The name of the building.
  /// - `state`: The state of the address.
  /// - `city`: The city of the address.
  /// - `zipPostCode`: The ZIP or postal code.
  /// - `id`: The ID of the address to update (optional).
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string containing the result of the address operation.
  Future<String> createUserAddress({
    required String type,
    required String flatNumber,
    required String streetName,
    required String buildingName,
    required String state,
    required String city,
    required String zipPostCode,
    String? id,
  }) async {
    try {
      // Determine the address type based on the provided type string
      final addressType = type == "Current Address" ? 'current' : 'permanent';

      // Call user services to create or update the user address
      return await userServices.editUserAddress(
        addressType,
        flatNumber,
        streetName,
        buildingName,
        state,
        city,
        zipPostCode,
        id: id,
      );
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Deletes a user address.
  ///
  /// Deletes a user address with the provided ID using user services.
  ///
  /// Parameters:
  ///
  /// - `id`: The ID of the address to delete.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string containing the result of the address deletion.
  Future<String> deleteUserAddress({
    required String id,
  }) async {
    try {
      // Call user services to delete the user address
      return await userServices.deleteUserAddress(
        id: id,
      );
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves a list of advertisement items.
  ///
  /// Fetches a list of advertisement items using the user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a list of [Ads] items.
  Future<List<Ads>> getAds() async {
    try {
      // Call user services to retrieve ads
      return await userServices.ads();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Dumps offline data to the server.
  ///
  /// Synchronizes offline product data and checkout information to the server using user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves when the synchronization is complete.
  Future<void> dumpOfflineData() async {
    try {
      // Synchronize offline products data
      await userServices.syncOfflineProducts();

      // Synchronize offline checkout information
      await userServices.syncOfflineCheckOuts();

      // Return when synchronization is complete
      return;
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Updates the device ID associated with the user's account.
  ///
  /// Updates the device ID for the user's account using the provided device ID
  /// and user services.
  ///
  /// Parameters:
  ///
  /// - `deviceId`: The new device ID to associate with the user's account.
  Future<void> deviceId({required String deviceId}) async {
    try {
      // Call user services to refresh the device ID
      await userServices.refreshDeviceId(deviceId);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Deletes the user's account.
  ///
  /// Deletes the user's account using user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves when the account deletion is complete.
  Future<void> deleteAccount() async {
    try {
      // Call user services to delete the user's account
      await userServices.deleteUsersAccount();

      // Return when account deletion is complete
      return;
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves a list of countries.
  ///
  /// Fetches a list of country information using the user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a list of [Countries] objects.
  Future<List<Countries>> getCountries() async {
    try {
      // Call user services to retrieve countries
      return await userServices.countriesList();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves a list of states for a specific country.
  ///
  /// Fetches a list of states associated with the specified country ID using the user services.
  ///
  /// Parameters:
  ///
  /// - `id`: The ID of the country for which to retrieve states.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a list of maps containing state information.
  Future<List<Map>> getCountryStates(String id) async {
    try {
      // Call user services to retrieve country states
      return await userServices.getCountryState(id);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves a list of government organizations.
  ///
  /// Fetches a list of government organization names using the user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a list of government organization names.
  Future<List<String>> getGovernmentList() async {
    try {
      // Call user services to retrieve government organization list
      final response = await userServices.getGovernmentOrganizationList();

      // Extract and map government organization names
      return response
          .map((e) => e['government_organization'].toString())
          .toList();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves a map of countries.
  ///
  /// Fetches a map containing country information using the user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a map containing country information.
  Future<Map<String, dynamic>> getCountriesAsMap() async {
    try {
      // Call user services to retrieve countries as a map
      return await userServices.countriesListMap();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Retrieves a list of news feed items.
  ///
  /// Fetches a list of news feed items using the user services.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a list of [NewsFeed] items.
  Future<List<NewsFeed>> getNotification() async {
    try {
      // Call user services to retrieve news feed
      return await userServices.newsFeed();
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Updates the business logo.
  ///
  /// Uploads a new business logo file and associates it with the provided business information.
  ///
  /// Parameters:
  ///
  /// - `businessLogo`: The file representing the new business logo.
  /// - `businessInformation`: A map containing business information, including the business ID.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string containing the result of the logo update.
  Future<String> updateBusinessLogo(File businessLogo,
      {required Map<String, dynamic> businessInformation}) async {
    try {
      Map<String, dynamic> fields = {};
      List<Map<String, dynamic>> files = [];

      // Get temporary directory and prepare image file
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath = dir.absolute.path;

      files.add({
        "name": "business_logo",
        "file": File(await compressImage((businessLogo),
            targetPath + "/business_logo_${generateNumber()}.jpg"))
      });

      // Call service to update business logo
      return await userServices.updateUsersBusinessLogo(fields, files,
          id: businessInformation['id']);
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }

  /// Creates a business profile.
  ///
  /// Creates a business profile with the provided payload data, user credentials (if available),
  /// and uploads the business logo (if provided).
  ///
  /// Parameters:
  ///
  /// - `payload`: A map containing the payload data for creating the business profile.
  /// - `userName`: The username of the user. If provided, user login will be attempted before creating the profile.
  /// - `password`: The password of the user. If provided, user login will be attempted before creating the profile.
  ///
  /// Returns:
  ///
  /// A Future that resolves to a string containing the result of the profile creation.
  Future<String> createBusinessProfile(
      Map<String, dynamic> payload, String? userName, String? password) async {
    try {
      // Attempt user login if credentials are provided
      if (userName != null && password != null) {
        await userLogin(usersEmail: userName, usersPassword: password);
      }

      Map<String, dynamic> fields = {};
      List<Map<String, dynamic>> files = [];
      List<dynamic> categories = [];

      // Prepare categories data for payload
      payload["business_category"].forEach((element) {
        categories.add({"category": element});
      });

      if (payload["business_logo"] == null) {
        // Case: No business logo provided
        fields.addAll({
          "business_registration_number":
              payload["business_registration_number"] ?? "",
          "business_name": payload["business_name"],
          "business_contact_number": payload["business_contact_number"],
          "business_address": payload["business_address"],
          "business_category": categories,
          "business_type": payload["business_type"]
        });

        // Call service to create business profile without logo
        return await userServices.createBusinessProfile(fields, files,
            withImage: false);
      } else {
        // Case: Business logo provided
        fields.addAll({
          "business_registration_number":
              payload["business_registration_number"] ?? "",
          "business_name": payload["business_name"],
          "business_contact_number": payload["business_contact_number"],
          "business_address": payload["business_address"],
          "business_type": payload["business_type"],
          "business_category": categories.toString(),
        });

        int i = 0;
        payload["business_category"].forEach((element) {
          fields.addAll({"business_category[$i]category": element.toString()});
          i++;
        });

        // Compress and prepare business logo image
        final dir = await path_provider.getTemporaryDirectory();
        final targetPath = dir.absolute.path;

        files.add({
          "name": "business_logo",
          "file": File(await compressImage((payload["business_logo"]),
              targetPath + "/business_logo${generateNumber()}.jpg"))
        });

        // Call service to create business profile with logo
        return await userServices.createBusinessProfile(fields, files);
      }
    } catch (e) {
      // Rethrow any caught exceptions
      rethrow;
    }
  }
}
