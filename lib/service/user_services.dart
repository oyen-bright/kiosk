import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kiosk/cubits/internet/internet_cubit.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/service/api/urls.dart';
import 'package:kiosk/service/http/http_client.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';
import 'package:kiosk/views/generate_agreement/generate_pdf.dart';
import 'package:tuple/tuple.dart';

class UserServices {
  final http.Client httpClient;
  final LocalStorage localStorage;
  final InternetCubit internetCubit;
  late final BaseClient baseClient;
  late final EndPoints endPoints;

  final box = GetStorage();
  UserServices({
    required this.internetCubit,
    required this.localStorage,
    required this.httpClient,
  }) {
    baseClient = BaseClient();
    endPoints = EndPoints();
  }

  Future<String> getKioskVersion() async {
    try {
      final http.Response response = await baseClient.getRequest(httpClient,
          endpoint: endPoints.getKioskAppVersion);

      return json.decode(response.body)["kiosk_version"];
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createUserAccount(
      {required Map<String, dynamic> payload}) async {
    try {
      log(payload.toString());
      await baseClient.postRequest(httpClient,
          endpoint: endPoints.createUserAccount, payload: payload);
      return "";
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> userLogin({
    required String usersEmail,
    required String usersPassword,
  }) async {
    try {
      if (internetCubit.state.status == InternetStatus.noInternet) {
        final data = localStorage.readToken();
        checkData(data);
        final token = json.decode(data!);
        await box.write("Token", token);
        return token;
      }

      final http.Response response = await baseClient
          .postRequest(httpClient, endpoint: endPoints.getToken, payload: {
        "email": usersEmail,
        "password": usersPassword,
      });

      final data = json.decode(response.body);

      //save login token for authentication
      await box.write("Token", data);

      //Save login token for localStorage
      localStorage.writeToken(response.body);

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> selectBusinessProfile({
    required String id,
  }) async {
    try {
      if (internetCubit.state.status == InternetStatus.noInternet) {
        return true;
      }
      await baseClient.getRequest(httpClient,
          endpoint: endPoints.switchBusinessAccount + id + "/");
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> resetUsersPassword(
      {required String email, required String password}) async {
    try {
      final http.Response response = await baseClient.postRequest(httpClient,
          endpoint: endPoints.forgetPasswordReset,
          payload: {
            "email": email,
            "new_password1": password,
            "new_password2": password
          });
      final msg = json.decode(response.body)['message'];
      return toBeginningOfSentenceCase(msg) ?? msg;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> sendUsersFeedback(
      {required String email,
      required String subject,
      required String message}) async {
    try {
      final http.Response response = await baseClient.postRequest(httpClient,
          endpoint: endPoints.sendFeedBack,
          payload: {
            "customer_email": email,
            "email_subject": subject,
            "message": message
          });
      final msg = json.decode(response.body)['message'];
      return toBeginningOfSentenceCase(msg) ?? msg;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> logOUtUser() async {
    try {
      await baseClient
          .postRequest(httpClient, endpoint: endPoints.logoutUser, payload: {});

      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getUserInformation() async {
    try {
      if (internetCubit.state.status == InternetStatus.noInternet) {
        final data = localStorage.readUserDetails();
        checkData(data);

        return User.fromJson(json.decode(data!));
      }
      final http.Response response = await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.getUserAccountInformation,
      );

      localStorage.writeUserDetails(response.body);
      return User.fromJson(json.decode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<String> switchToMerchant() async {
    try {
      final http.Response response = await baseClient.postRequest(httpClient,
          endpoint: endPoints.switchMerchantAccount, payload: {});
      final message = json.decode(response.body)['message'];
      return toBeginningOfSentenceCase(message) ?? message;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getGeneratedBusinessPlans() async {
    try {
      final http.Response response = await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.generateBusinessPlan,
      );

      final data = json.decode(response.body)['data'];
      return List.from(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAllAgreements() async {
    try {
      final http.Response response = await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.allAgreements,
      );
      String? data;
      try {
        data = utf8.decode(response.bodyBytes);
      } catch (e) {
        data = response.body;
      }

      return json.decode(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List> getAvailableSurveys() async {
    try {
      final http.Response response = await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.getSurveys,
      );

      String? data;
      try {
        data = utf8.decode(response.bodyBytes);
      } catch (e) {
        data = response.body;
      }

      return json.decode(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> submitSurvey(Map<String, dynamic> payload) async {
    try {
      final http.Response response = await baseClient.postRequest(
        httpClient,
        payload: payload,
        endpoint: endPoints.submitSurvey,
      );

      return json.decode(response.body)['message'] ?? "";
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getGeneratedAgreements() async {
    try {
      final http.Response response = await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.generateBusinessPlan,
      );

      final data = json.decode(response.body)['data'];
      return List.from(data);
    } catch (e) {
      rethrow;
    }
  }

  Future generateShareAgreement(
      Map<String, dynamic> payload, List<Map<String, dynamic>> files) async {
    try {
      Map<String, String> fields = {};

      int i = 0;
      for (var _ in payload['share_holder']) {
        fields.addAll({
          "share_holders[$i]name": payload['share_holder'][i]["name"],
          "share_holders[$i]address": payload['share_holder'][i]["address"],
          "share_holders[$i]share": payload['share_holder'][i]["share"],
          "share_holders[$i]shares_signature": "",
          "share_holders[$i]share_price": payload['share_holder'][i]
              ["share_price"],
        });
        i++;
      }
      fields.addAll({
        "share_holders": jsonEncode(payload['share_holder']),
        "company_name": payload['companyName'],
        "company_share": payload['companyShares'],
        "owner_name": payload['ownerName'],
        "non_compete_period": payload['non_compete_period'],
        "company_country": payload['companyCountry'],
        "formatted_date": payload["formattedDate"]
      });

      await baseClient.multipartRequest(httpClient,
          endpoint: endPoints.shareAgreement, fields: fields, file: files);

      return;
    } catch (e) {
      rethrow;
    }
  }

  Future generateEmployeeAgreement(
      Map<String, dynamic> payload, List<Map<String, dynamic>> files) async {
    try {
      await baseClient.multipartRequest(httpClient,
          endpoint: endPoints.employeeAgreement,
          fields: {
            "business_name": payload['businessName'],
            "industry": payload['industry'],
            "business_owner_name": payload['ownerName'],
            "business_address": payload['businessAddress'],
            "employee_name": payload['employeeName'],
            "employee_address": payload['employeeAddress'],
            "employee_position": payload['employeePosition'],
            "employee_start_date": payload['employeeStartDate'],
            "employment_term": payload['employmentTerm'],
            "employee_end_date": payload['employmentEndDate'],
            "employee_salary": payload['employeeSalary'],
            "payment_frequency": payload['paymentFrequency'],
            "employee_responsibilities": payload['employeeResponsibilities'],
            "weekly_hours": payload['weeklyHours'],
            "travel_required": payload['travelRequired'],
            "company_policies": payload['companyPolicies'],
            "business_country": payload['country'],
            "formatted_date": payload['formattedDate'],
          },
          file: files);

      return;
    } catch (e) {
      rethrow;
    }
  }

  Future generateLoanAgreement(
      Map<String, dynamic> payload, List<Map<String, dynamic>> files) async {
    try {
      await baseClient.multipartRequest(httpClient,
          endpoint: endPoints.loanAgreement,
          fields: {
            "borrower_name": payload['borrowerName'],
            "lender_name": payload['lenderName'],
            "amount": payload['amount'],
            "date_of_execution": payload['dateOfExecution'],
            "payment_frequency": payload['paymentFrequency'],
            "first_payment_date": payload['firstPaymentDate'],
            "amount_of_each_payment": payload['amountOfEachPayment'],
            "interest_name": payload['interestName'],
            "asset": payload['asset'],
            "lender_address": payload['lenderAddress'],
            "borrower_address": payload['borrowerAddress'],
            "loaner_type": payload['loanerType'],
            "asset_location": payload['assetLocation'],
            "borrower_type": payload['borrowerType'],
            "formatted_date": payload['formattedDate'],
            "lender_country": payload['lenderCountry'],
          },
          file: files);

      return;
    } catch (e) {
      rethrow;
    }
  }

  Future generateGoodAndServiceAgreement(
      Map<String, dynamic> payload, List<Map<String, dynamic>> files) async {
    try {
      await baseClient.multipartRequest(httpClient,
          endpoint: endPoints.salesAndServicesAgreement,
          fields: {
            "seller_name": payload['sellerName'],
            "seller_address": payload['sellerAddress'],
            "owner_name": payload['ownerName'],
            "buyer_name": payload['buyerName'],
            "buyer_address": payload['buyerAddress'],
            "type": payload['type'],
            "product_name": payload['productName'],
            "product_quantity": payload['productQuantity'],
            "price_of_good_and_service": payload['priceOfGoodService'],
            "delivery_address": payload['deliveryAddress'],
            "buyer_type": payload['buyerType'],
            "seller_type": payload['sellerType'],
            "formatted_date": payload['formattedDate'],
            "seller_country": payload['sellerCountry'],
            "buyer_country": payload['buyerCountry'],
          },
          file: files);

      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> generateBusinesPlan(
      {required String businessCategory,
      required String numberOfEmployee,
      required List<Map> expenses,
      required String periodOfReport,
      required String yearOfOperation}) async {
    try {
      final http.Response response = await baseClient.postRequest(httpClient,
          endpoint: endPoints.generateBusinessPlan,
          payload: {
            "business_category": [businessCategory],
            "year_of_operation": yearOfOperation,
            "number_of_employees": numberOfEmployee,
            "business_expenses": expenses,
            "period_of_report": periodOfReport
          });

      final message = json.decode(response.body)['message'];
      return toBeginningOfSentenceCase(message) ?? message;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getGeneratedBusinessPlanGetData(
      {required String id}) async {
    try {
      final http.Response response = await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.getBusinessPlan + "/$id/",
      );

      final message = json.decode(response.body)['data'];
      return message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> passwordReset({required String email}) async {
    try {
      final http.Response response = await baseClient.postRequest(httpClient,
          endpoint: endPoints.forgetPassword, payload: {"email": email.trim()});
      final message = json.decode(response.body)['message'];
      return toBeginningOfSentenceCase(message) ?? message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> changePassword(String oldPassword, String newPassword) async {
    try {
      final http.Response response = await baseClient.postRequest(httpClient,
          endpoint: endPoints.resetUserPassword,
          payload: {
            'old_password': oldPassword,
            'new_password1': newPassword,
            'new_password2': newPassword,
          });
      final message = json.decode(response.body)['detail'];
      return toBeginningOfSentenceCase(message) ?? message;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> usersBusinessInformation() async {
    try {
      final http.Response response = await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.businessProfile,
      );
      return json.decode(response.body.replaceAll("â", "'"));
    } catch (e) {
      rethrow;
    }
  }

  Future<String> updateUsersBusinessInformation(
      String businessName,
      String businessRegistrationNumber,
      String businessContact,
      List businessCategory,
      String businessType,
      String businessAddress,
      String id) async {
    try {
      final http.Response response = await baseClient.patchRequest(
        httpClient,
        payload: {
          "business_registration_number": businessRegistrationNumber,
          "business_type": businessType,
          "business_name": businessName,
          "business_contact_number": businessContact,
          "business_address": businessAddress
        },
        endpoint: endPoints.businessProfile + "$id/",
      );

      final message = json.decode(response.body)['message'] ?? "";
      return toBeginningOfSentenceCase(message) ?? message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> updateUsersBusinessLogo(
      Map<String, dynamic> businessInfo, List<Map<String, dynamic>> files,
      {required String id}) async {
    try {
      final String response = await baseClient.multipartRequest(
        httpClient,
        file: files,
        method: "PATCH",
        fields: Map.from(businessInfo),
        endpoint: endPoints.businessProfile + "$id/",
      );

      final message = json.decode(response)['message'] ?? "";
      return toBeginningOfSentenceCase(message) ?? message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createBusinessProfile(
      Map<String, dynamic> fields, List<Map<String, dynamic>> files,
      {bool withImage = true}) async {
    try {
      log(fields.toString());
      if (withImage) {
        final String response = await baseClient.multipartRequest(
          httpClient,
          file: files,
          fields: Map.from(fields),
          endpoint: endPoints.businessProfile,
        );
        final message = json.decode(response)['message'];
        return toBeginningOfSentenceCase(message) ?? message;
      } else {
        final http.Response response = await baseClient.postRequest(
          httpClient,
          payload: fields,
          endpoint: endPoints.businessProfile,
        );
        final message = json.decode(response.body)['message'];
        return toBeginningOfSentenceCase(message.toString()) ??
            message.toString();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> submitKYC(Map<String, String> fields,
      List<Map<String, dynamic>> files, bool isMerchant) async {
    try {
      final String response = await baseClient.multipartRequest(
        httpClient,
        file: files,
        fields: fields,
        endpoint: isMerchant ? endPoints.kycMerchant : endPoints.kycPersonal,
      );
      final message = json.decode(response)['message'];
      return toBeginningOfSentenceCase(message) ?? message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> editUserAddress(
      String? type,
      String? flatNumber,
      String? streetName,
      String? buildingName,
      String? state,
      String? city,
      String? zipPostCode,
      {String? id}) async {
    try {
      final payload = {
        'type': type,
        'street_or_flat_number': flatNumber,
        'street_name': streetName,
        'building_name': buildingName,
        "state": state,
        "city": city,
        "zip_post_code": zipPostCode,
      };

      if (id == null) {
        final http.Response response = await baseClient.postRequest(
          httpClient,
          payload: payload,
          endpoint: endPoints.createUserAddress,
        );

        final message = json.decode(response.body)['message'];
        return toBeginningOfSentenceCase(message) ?? message;
      }

      final http.Response response = await baseClient.putRequest(
        httpClient,
        payload: payload,
        endpoint: endPoints.updateUserAddress + "$id/",
      );

      final message = json.decode(response.body)['message'] ?? "";
      return toBeginningOfSentenceCase(message) ?? message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> deleteUserAddress({required String id}) async {
    try {
      final http.Response response = await baseClient.deleteRequest(
        httpClient,
        endpoint: endPoints.updateUserAddress + "$id/",
      );
      return "";

      // final message = json.decode(response.body)['message'];
      // return toBeginningOfSentenceCase(message) ?? message.toString();
    } catch (e) {
      rethrow;
    }
  }

  Future deleteAgreement(
      {required String id, required AgreementType type}) async {
    try {
      switch (type) {
        case AgreementType.employee:
          await baseClient.deleteRequest(
            httpClient,
            endpoint: endPoints.employeeAgreement + "$id/",
          );
          break;
        case AgreementType.shareHolder:
          await baseClient.deleteRequest(
            httpClient,
            endpoint: endPoints.shareAgreement + "$id/",
          );
          break;
        case AgreementType.saleServiceGoods:
          await baseClient.deleteRequest(
            httpClient,
            endpoint: endPoints.salesAndServicesAgreement + "$id/",
          );
          break;
        case AgreementType.loan:
          await baseClient.deleteRequest(
            httpClient,
            endpoint: endPoints.loanAgreement + "$id/",
          );
          break;
      }

      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> refundProduct(
      String orderId, String productSku, String quantity) async {
    try {
      final http.Response response = await baseClient.postRequest(
        httpClient,
        payload: {},
        endpoint: endPoints.refundProduct + "$orderId/$productSku/$quantity/",
      );

      final message = json.decode(response.body)['message'];
      return toBeginningOfSentenceCase(message) ?? message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> refundSale(
    String orderId,
  ) async {
    try {
      final http.Response response = await baseClient.postRequest(
        httpClient,
        payload: {},
        endpoint: endPoints.refundSale + "$orderId/",
      );

      final message = json.decode(response.body)['message'];
      return toBeginningOfSentenceCase(message) ?? message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> termsAndConditions() async {
    try {
      if (internetCubit.state.status == InternetStatus.noInternet) {
        final data = localStorage.readTermsCondition();
        checkData(data);

        json.decode(data!)['data']['content'];
      }
      final http.Response response = await baseClient.getRequest(httpClient,
          endpoint: endPoints.termsAndConditions);
      localStorage.writeTermsCondition(response.body);

      return json.decode(response.body)['data']['content'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Tuple2<bool, String?>> verifySubscriptionToken(
      {required String data,
      required String platform,
      required String tokenId}) async {
    try {
      log({
        "device_type": platform,
        "receipt_data": data,
        "subcription_id": tokenId
      }.toString());
      final http.Response response = await baseClient.postRequest(httpClient,
          payload: {
            "device_type": platform,
            "receipt_data": data,
            "subcription_id": tokenId
          },
          endpoint: endPoints.verifySubscriptionToken);
      final responseBody = json.decode(response.body);

      return Tuple2(responseBody['verification'], responseBody['exp_date']);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> migrateSubscriptionPlan(
      {required String data,
      required String platform,
      required String expDate,
      String? subscriptionId,
      required String yearlyProductID,
      required String productId}) async {
    try {
      final http.Response response = await baseClient.postRequest(httpClient,
          payload: {
            "device_type": platform,
            "receipt_data": data,
            "subcription_id": subscriptionId ?? "subcription_id",
            "exp_date": expDate,
            "yearly_product_id": yearlyProductID,
            "product_id": productId
          },
          endpoint: endPoints.migrateSubscriptionPlan);
      final responseBody = json.decode(response.body);

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> privacyPolicy() async {
    try {
      if (internetCubit.state.status == InternetStatus.noInternet) {
        final data = localStorage.readPrivacyPolicy();
        checkData(data);

        return json.decode(data!)['data']['content'];
      }
      final http.Response response = await baseClient.getRequest(httpClient,
          endpoint: endPoints.privacyPolicy);
      localStorage.writePrivacyPolicy(response.body);

      return json.decode(response.body)['data']['content'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Ads>> ads() async {
    try {
      final http.Response response =
          await baseClient.getRequest(httpClient, endpoint: endPoints.getAds);
      final _fetchdata = json.decode(response.body)["data"] as List;

      return (_fetchdata).map((e) => Ads.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List> fAQ() async {
    try {
      if (internetCubit.state.status == InternetStatus.noInternet) {
        final data = localStorage.readFAQ();
        checkData(data);

        return json.decode(data!)['data'];
      }
      final http.Response response =
          await baseClient.getRequest(httpClient, endpoint: endPoints.faqs);

      localStorage.writeFAQ(response.body);

      return json.decode(response.body)['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Countries>> countriesList() async {
    try {
      final http.Response response = await baseClient.getRequest(httpClient,
          endpoint: endPoints.kioskCountries);
      List<dynamic> _fetchedData = json.decode(response.body)['data'] as List;
      return List<Countries>.from(
          _fetchedData.map((e) => Countries.fromJson(e)));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map>> getCountryState(String id) async {
    try {
      final http.Response response = await baseClient.getRequest(httpClient,
          endpoint: endPoints.kioskCountryStates + "$id/");
      List<dynamic> _fetchedData = json.decode(response.body) as List;
      return List.from(_fetchedData);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getGovernmentOrganizationList() async {
    try {
      final http.Response response = await baseClient.getRequest(httpClient,
          endpoint: endPoints.governmentOrganizations);
      return json.decode(response.body) as List;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> countriesListMap() async {
    try {
      final http.Response response = await baseClient.getRequest(httpClient,
          endpoint: endPoints.kioskCountries);
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NewsFeed>> newsFeed() async {
    try {
      final http.Response response =
          await baseClient.getRequest(httpClient, endpoint: endPoints.newFeed);
      List<dynamic> _fetchedData = json.decode(response.body)['data'] as List;

      localStorage.writeUserNewsFeeds(
        _fetchedData,
      );

      return List<NewsFeed>.from(_fetchedData.map((e) => NewsFeed.fromJson(e)));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> eLearningVideo() async {
    try {
      final http.Response response = await baseClient.getRequest(httpClient,
          endpoint: endPoints.getELearning);

      return json.decode(response.body)['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<String> promoCode(String promoCode) async {
    try {
      final http.Response response = await baseClient.postRequest(httpClient,
          endpoint: endPoints.verifyPromoCode,
          payload: {"promo_code": promoCode});

      return json.decode(response.body)["message"] ?? "";
    } catch (e) {
      rethrow;
    }
  }
  // ===========================================================================
// DEVICE MANAGEMENT SECTION
//
// This section contains functions for managing the device in the app.
// The functions in this section are responsible for refreshing the device ID.
// ===========================================================================

  /// Function to refresh the device ID on the server
  Future<void> refreshDeviceId(String deviceId) async {
    try {
      // Make a POST request to the server to refresh the device ID
      await baseClient.postRequest(
        httpClient,
        endpoint: endPoints.refreshDeviceId,
        payload: {
          "device_id": deviceId,
          "device_type": "phone",
        },
      );

      return;
    } catch (e) {
      // If an error occurs, rethrow the exception to the calling code
      return;
    }
  }

// ===========================================================================
// SYNC FUNCTIONS
//
// This section contains functions for syncing offline data with the server.
// The functions in this section are responsible for syncing offline checkouts
// and offline products.
// ===========================================================================

  // Define a function for syncing offline checkouts with the server
  Future<void> syncOfflineCheckOuts() async {
    try {
      // Read the offline checkouts from local storage
      final offlineCheckouts = localStorage.readOfflineCheckOut();
      if (offlineCheckouts == null) {
        // If there are no offline checkouts, return immediately
        return;
      }

      // Send a POST request to the server to sync the offline checkouts
      await baseClient.postRequest(
        httpClient,
        endpoint: endPoints.dumpOfflineData,
        payload: {"offline_checkout": offlineCheckouts},
      );
      // If the request was successful, clear the offline checkouts from local storage
      localStorage.clearOfflineCheckOuts();
      return;
    } catch (e) {
      // If an error occurs, rethrow the exception to the calling code
      rethrow;
    }
  }

// Define a function for syncing offline products with the server
  Future<void> syncOfflineProducts() async {
    try {
      // Read the offline products from local storage
      final offlineProducts = localStorage.readOfflineProducts();
      if (offlineProducts == null) {
        // If there are no offline products, return immediately
        return;
      }

      // Send a POST request to the server to sync the offline products
      await baseClient.postRequest(
        httpClient,
        endpoint: endPoints.dumpOfflineDataProduct,
        payload: {"offline_products": offlineProducts},
      );
      // If the request was successful, clear the offline products from local storage
      localStorage.clearOfflineProducts();
      return;
    } catch (e) {
      // If an error occurs, rethrow the exception to the calling code
      rethrow;
    }
  }

// ===========================================================================
// WORKERS SECTION
//
// This section contains functions for managing workers in the app.
// Workers are users of the app who perform tasks for customers.
// The functions in this section are responsible for creating new workers,
// verifying worker email addresses, and displaying a list of workers.
// ===========================================================================

  // Define a function for verifying a worker's email on the server
  Future<Map<String, dynamic>> verifyWorkersEmail(String email) async {
    try {
      // Make a GET request to the server to verify the worker's email
      final http.Response response = await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.verifyWorkerEmail +
            "$email/", // The endpoint for verifying a worker's email
      );

      // Extract the data from the response body and return it
      return json.decode(response.body)[
          'data']; // The 'data' field of the response body contains the verification result
    } catch (e) {
      // If an error occurs, rethrow the exception to the calling code
      rethrow; // The calling code can handle the exception appropriately
    }
  }

// Define a function for creating a worker account on the server
  Future<String> createWorker(
      String firstName, // A string representing the worker's first name
      String lastName, // A string representing the worker's last name
      String email, // A string representing the worker's email address
      String contactNumber, // A string representing the worker's contact number
      String
          countryISO2, // A string representing the worker's country of residence as a 2-letter ISO code
      String
          gender, // A string representing the worker's gender can only be either male or female
      String password // A string representing the worker's password
      ) async {
    try {
      final http.Response response = await baseClient.postRequest(httpClient,
          endpoint: endPoints.createWorkersAccount,
          payload: {
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "gender": gender,
            "contact_number": contactNumber,
            "country_of_residence": countryISO2,
            "password": password
          });

      // Extract the message from the response body and return it
      return json.decode(response.body)['message'];
    } catch (e) {
      // If an error occurs, rethrow the exception to the calling code
      rethrow;
    }
  }

  Future<String> addWorker(String email) async {
    try {
      // Send a POST request to the API with the email in the endpoint
      final http.Response response = await baseClient.postRequest(httpClient,
          endpoint: endPoints.addWorker + "$email/", payload: {});

      // Extract the message from the response body and return it
      return json.decode(response.body)['message'];
    } catch (e) {
      // Rethrow the error if any occurs
      rethrow;
    }
  }

// This function retrieves a list of workers from the server
  Future<List<Worker>> workersList() async {
    try {
// sends a GET request to the server to retrieve worker list
      final http.Response response = await baseClient.getRequest(httpClient,
          endpoint: endPoints.getWorkersList);

      // extracts the data from the server's response
      List<dynamic> _fetchedData = json.decode(response.body)['data'] as List;

      // maps the fetched data to a List of Worker objects and returns it
      return List<Worker>.from(_fetchedData.map((e) => Worker.fromJson(e)));
    } catch (e) {
      // rethrows any error that may have occurred
      rethrow;
    }
  }

// Asynchronously fetches worker details using email address as a parameter and returns a Map containing two Lists
// The function throws an error if the request fails

  Future<Map<String, List>> workerDetails(String email) async {
    try {
// Sends a GET request to the API endpoint to fetch worker details using the provided email address
      final http.Response response = await baseClient.getRequest(httpClient,
          endpoint: endPoints.getWorkerDetails + "$email/");
// Extracts the "data" property from the JSON response and converts it to a Map
      final _fetchedData =
          json.decode(response.body)['data'] as Map<String, dynamic>;

// Extracts the "worker_report" property from the fetched data Map and converts it to a List
      final workersReport = _fetchedData["worker_report"] as List;

// Maps each element in the workersReport list to the first element of the inner list, if it exists
      List salesReport = workersReport.map((e) {
        if (e.isNotEmpty) {
          return e[0];
        }
        return e;
      }).toList();

// Removes any empty lists from the salesReport List
      if (salesReport.every((innerList) => innerList.isEmpty)) {
        salesReport = [];
      }
      salesReport.removeWhere((item) => item is List && item.isEmpty);

// Returns a Map containing the "workers_weekly_days" and "worker_report" Lists
      return {
        "workers_weekly_days": _fetchedData["workers_weekly_days"] as List,
        "worker_report": salesReport
      };
    } catch (e) {
// Throws the error if the request fails
      rethrow;
    }
  }

// A future function that removes a worker based on their email address
// The function takes the email address of the worker to remove as a parameter
  Future<String> removeWorker(String email) async {
    try {
// Makes a DELETE request to remove the worker with the specified email address
      final http.Response response = await baseClient.deleteRequest(httpClient,
          endpoint: endPoints.getWorkerDetails + "$email/");
// Returns the message from the response body
      return json.decode(response.body)['message'];
    } catch (e) {
// Throws an error if there was an issue with the request
      rethrow;
    }
  }

  // ===========================================================================
// OTP VERIFICATION SECTION
//
// This section contains functions for sending and verifying OTP (One-Time
// Password) codes for user authentication. The OTP codes are sent via email,
// and the user must enter the correct code to verify their email address.
// The functions in this section are responsible for sending the OTP code
// via email, and verifying the OTP code entered by the user.
// ===========================================================================

// Define a function for sending an OTP code via email
  Future<String> sendUserOTP({
    required String email,
  }) async {
    try {
      // Make a POST request to the server to send an OTP code via email
      final http.Response response = await baseClient.postRequest(
        httpClient,
        removeToken: true,
        endpoint: endPoints
            .emailOtp, // The endpoint for sending an OTP code via email
        payload: {
          "email": email
              .trim()
              .toLowerCase(), // The email address of the user to send the OTP code to
          "platform": "kiosk",
        },
      );

      // Extract the message from the response body and return it
      return json.decode(response.body)['message'];
    } catch (e) {
      // If an error occurs, rethrow the exception to the calling code
      rethrow; // The calling code can handle the exception appropriately
    }
  }

  /// Verifies an OTP code entered by the user.
  ///
  /// This method makes a POST request to the server to verify the OTP code entered by the user.
  /// It includes the required parameters, such as [email] and [pin], in the request payload.
  ///
  /// The [email] parameter specifies the email address of the user to verify.
  /// The [pin] parameter specifies the OTP code entered by the user.
  ///
  /// Returns a String indicating the verification status.
  ///
  /// Throws an error if there is an issue with verifying the OTP code.
  Future<String> verifyOtp({
    required String email,
    required String pin,
  }) async {
    try {
      final http.Response response = await baseClient.postRequest(
        httpClient,
        endpoint: endPoints.verifyEmailOtp,
        payload: {
          "otp_pin": pin.trim(),
          "email": email.toString().trim(),
        },
      );

      return json.decode(response.body)['message'];
    } catch (e) {
      rethrow;
    }
  }

// ===========================================================================
// SALES SECTION
//
// This section contains functions for retrieving sales data for the current
// user. The `getUserSalesReport()` function retrieves an overall summary of
// the user's sales data, while the `getUserSales()` function retrieves a
// list of individual sales. The `getUserSaleDetails()` function retrieves
// detailed information about a specific sale, given its ID. These functions
// use the `baseClient` and `httpClient` instances to make HTTP requests to
// the backend API, and they use the `localStorage` instance to cache data
// locally to improve performance when there is no internet connection.
// ===========================================================================

// Fetches the user's sales report, which contains aggregate sales data over time.
  Future<SalesReport> getUserSalesReport() async {
    try {
      if (internetCubit.state.status == InternetStatus.noInternet) {
        // If the user has no internet connection, retrieve sales data from local storage.
        final data = localStorage.readUserSalesReport();
        checkData(data);

        // Return the sales report object from the decoded local storage data.
        return SalesReport.fromJson(json.decode(data!));
      }

      // If the user is online, retrieve the sales report from the server.
      final http.Response response = await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.getReport,
      );

      // Write the sales report data to local storage for future offline use.
      localStorage.writeUserSalesReport(response.body);

      // Return the sales report object from the decoded server response.
      return SalesReport.fromJson(json.decode(response.body));
    } catch (e) {
      rethrow;
    }
  }

// Fetches the user's individual sales data, which is represented as a list of Sales objects.
  Future<Map<String, dynamic>> getUserSales(
      Map<String, dynamic>? queryParameters, String? nextPage) async {
    try {
      if (internetCubit.state.status == InternetStatus.noInternet) {
        // If the user has no internet connection, retrieve sales data from local storage.
        final data = localStorage.readUserSales();
        checkData(data);

        // Return a list of Sales objects from the decoded local storage data.
        Map fetchedData = json.decode(data!);
        return {
          'total_count': fetchedData['count'],
          'next_page': fetchedData['next'],
          'prev_page': fetchedData['previous'],
          'sales': fetchedData['results'] as List
        };
      }

      // If the user is online, retrieve the sales data from the server.
      final http.Response response = await baseClient.getRequest(
        httpClient,
        queryParameters: queryParameters,
        endpoint: nextPage ?? endPoints.getSales,
      );

      // Write the sales data to local storage for future offline use.
      localStorage.writeUserSales(response.body);

      // Return a list of Sales objects from the decoded server response.
      Map fetchedData = json.decode(response.body);
      return {
        'total_count': fetchedData['count'],
        'next_page': fetchedData['next'],
        'prev_page': fetchedData['previous'],
        'sales': fetchedData['results'] as List
      };
    } catch (e) {
      rethrow;
    }
  }

// Fetches the details of a particular sale, given its unique ID.
  Future<List<dynamic>> getUserSaleDetails(String id) async {
    try {
      final http.Response response = await baseClient.postRequest(
        httpClient,
        endpoint: endPoints.getSaleDetails + "$id/",
        payload: {},
      );

      // Return a list of dynamic objects representing the sale's details.
      final _fetchedData = json.decode(response.body)['data'] as List<dynamic>;
      return _fetchedData;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getFinancialReport() async {
    try {
      final http.Response response = await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.businessFinancialReport,
      );

      // Return a list of dynamic objects representing the sale's details.
      final _fetchedData =
          json.decode(response.body)['data'] as Map<String, dynamic>;
      return [
        BusinessReport.fromJson(_fetchedData["business_report"][0]),
        FinancialReport.fromJson(_fetchedData["financial_report"][0])
      ];
    } catch (e) {
      rethrow;
    }
  }

  // ===========================================================================
// PRODUCT SERVICE SECTION
//
// This section contains functions for managing products and categories in the
// kiosk app. The functions allow for uploading, fetching, deleting, and editing
// products and categories. The data is fetched from an API endpoint, but if the
// device has no internet connection, the data is read from a local storage.
//
// uploadProduct() function uploads a product to the server. The function takes
// a map of product fields, a list of files (e.g. images), a generated ID, and
// a map of the product details to be stored offline (in case there is no internet
// connection). The function returns a boolean value indicating if the upload
// was successful or not.
//
// getUsersProductsByCategory() function fetches all products belonging to a
// particular category specified by an ID. The function takes an integer ID and
// returns a list of Products objects.
//
// getUsersProducts() function fetches all products available in the kiosk app.
// If there is no internet connection, the function reads the data from local storage.
// The function returns a list of Products objects.
//
// getUsersProductsCategories() function fetches all product categories available
// in the kiosk app. The function returns a list of Categories objects.
//
// getAllProductsCategories() function fetches all product categories available
// in the kiosk app. The function returns a list of dynamic objects.
//
// deleteUsersProduct() function deletes a product specified by its ID. The function
// takes a string ID and returns a boolean value indicating if the deletion was successful or not.
//
// editProduct() function edits a product specified by its ID. The function takes a
// map of product fields and a string ID. The function returns a boolean value indicating
// if the edit was successful or not.
//
// ===========================================================================

/*
This function is responsible for uploading a product to the server. If there is no internet connection, it stores the product information offline
in the local storage and returns true. If there is an internet connection, it makes a multipart request to the server with the product information
and returns true. If there is any error during the process, it throws an exception.

Input:

fields: a map containing the product fields
files: a list of maps containing the product files
generatedId: a string containing the generated id for the product
offlineProductMap: a map containing the product information to be stored offline
Output:

a boolean value indicating whether the product was successfully uploaded (true) or not (false)
*/
  Future<bool> uploadProduct(
      Map<String, String> fields,
      List<Map<String, dynamic>> files,
      String generatedId,
      Map<String, Object> offlineProductMap) async {
    try {
      // Check if there is no internet connection
      if (internetCubit.state.status == InternetStatus.noInternet) {
        // Save the offline product to local storage
        final List<dynamic> offlineProductList =
            localStorage.readOfflineProducts() ?? [];
        offlineProductList.add(offlineProductMap);
        await localStorage.writeOfflineProducts(offlineProductList);

        // Add the offline product to the user's product list in local storage
        final data = localStorage.readUserProducts() ??
            json.encode(
                {'count': 1, 'next': null, 'previous': null, 'results': []});

        Map fetchedData = json.decode(data);
        (fetchedData['results'] as List).insert(0, offlineProductMap);

        offlineProductMap.addAll({"id": generatedId});
        await localStorage.writeUserProducts(json.encode(fetchedData));
        return true;
      }

      // Upload the product to the server
      await baseClient.multipartRequest(
        httpClient,
        fields: fields,
        file: files,
        endpoint: endPoints.uploadProduct,
      );
      // Log the product upload event
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Products>> getUsersProductsByCategory(int id) async {
    try {
      // Fetch the user's products in a certain category from the server
      final http.Response response = await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.getCategoryProduct + "$id/",
      );
      List<dynamic> _fetchedData = json.decode(response.body)['data'] as List;

      // Convert the fetched data to a list of products
      return (_fetchedData).map((data) => Products.fromJson(data)).toList();
    } catch (_) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUsersProducts(
      Map<String, dynamic>? queryParameters, String? nextPage) async {
    try {
      if (internetCubit.state.status == InternetStatus.noInternet) {
        final data = localStorage.readUserProducts();
        checkData(data);

        Map fetchedData = json.decode(data!);

        return {
          'total_count': fetchedData['count'],
          'next_page': fetchedData['next'],
          'prev_page': fetchedData['previous'],
          'products': fetchedData['results'] as List
        };
      }
      final http.Response response = await baseClient.getRequest(
        httpClient,
        queryParameters: queryParameters,
        endpoint: nextPage ?? endPoints.getAllProduct,
      );

      localStorage.writeUserProducts(response.body);
      Map fetchedData = json.decode(response.body);

      return {
        'total_count': fetchedData['count'],
        'next_page': fetchedData['next'],
        'prev_page': fetchedData['previous'],
        'products': fetchedData['results'] as List
      };
    } catch (_) {
      rethrow;
    }
  }

  Future<List<Categories>> getUsersProductsCategories() async {
    try {
      final http.Response response = await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.kioskUserCategories,
      );
      List<dynamic> _fetchedData = json.decode(response.body)['data'] as List;

      return (_fetchedData).map((data) => Categories.fromJson(data)).toList();
    } catch (_) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAllProductsCategories() async {
    try {
      final http.Response response = await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.kioskCategories,
      );
      List<dynamic> _fetchedData = json.decode(response.body)['data'] as List;

      return _fetchedData;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> deleteUsersProduct(String productId) async {
    try {
      await baseClient.deleteRequest(
        httpClient,
        endpoint: endPoints.deleteProduct + "$productId/",
      );

      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> editProduct(
    Map<String, String> fields,
    String productId,
    List<Map<String, dynamic>> files,
  ) async {
    try {
      await baseClient.multipartRequest(
        httpClient,
        endpoint: endPoints.updateProduct + "$productId/",
        fields: fields,
        file: files,
        method: "PATCH",
      );

      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> addToUsersCategories(List<int> categories) async {
    try {
      await baseClient.postRequest(httpClient,
          endpoint: endPoints.addUserCategory,
          payload: {"business_category": categories});

      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> deleteUsersCategories(int categoryId) async {
    try {
      await baseClient.postRequest(httpClient,
          endpoint: endPoints.deleteUserCategory,
          payload: {
            "business_category": [categoryId]
          });

      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> addProductsToCart(
      List<Map<dynamic, dynamic>> myCartCheckOUt) async {
    try {
      if (internetCubit.state.status == InternetStatus.noInternet) {
        return true;
      }
      await baseClient.postRequest(httpClient,
          endpoint: endPoints.addToCart,
          payload: {"add_to_cart": myCartCheckOUt});

      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<String> checkOutProducts(Map<String, dynamic> checkOut,
      List<Map<dynamic, dynamic>> myCartCheckOUt) async {
    try {
      if (internetCubit.state.status == InternetStatus.noInternet) {
        final amountPaid = double.parse(checkOut["amount_paid"]);
        final dataS = localStorage.readUserSales();
        final dataSR = localStorage.readUserSalesReport();
        final offlineCheckoutList = localStorage.readOfflineCheckOut() ?? [];

        //UPDATING THE OFFLINE CHECKOUT
        checkOut.remove("kroon_transaction_ref");
        checkOut.addAll({
          "created_date": DateTime.now().toString(),
          "products": myCartCheckOUt,
        });
        offlineCheckoutList.add(checkOut);

        await localStorage.writeOfflineCheckOut(offlineCheckoutList);

        //UPDATING THE SALES REPORT
        //TODO: add to amout to respective sales type
        if (dataSR != null) {
          final salesReport = SalesReport.fromJson(json.decode(dataSR));
          salesReport.dailyReportData["total_sales"]["total_sales"] =
              salesReport.dailyReportData["total_sales"]["total_sales"] +
                  amountPaid;
          salesReport.dailyReportData["inventory"]["all_orders_count"] =
              salesReport.dailyReportData["inventory"]["all_orders_count"] + 1;

          await localStorage
              .writeUserSalesReport(json.encode(salesReport.toJson()));
        }

        //UPDATING THE SALES
        if (dataS != null) {
          final sales = json.decode(dataS)["results"] as List;
          final generatedSale = {
            "payment": {
              "payment_ref": "Offline Sale",
              "verified": true,
              "payment_method": checkOut["payment_method"]
            },
            "order_number": "Offline Sale",
            "order_total": amountPaid.toString(),
            "is_ordered": true,
            "refund": false,
            "created_date": DateTime.now().toString(),
            "worker": "Ofline",
          };
          sales.insert(0, generatedSale);

          Map data = json.decode(dataS) as Map;
          data['results'] = sales;

          await localStorage.writeUserSales(json.encode(data));
        }

        return "Offline Sale";
      }

      final http.Response response = await baseClient.postRequest(httpClient,
          endpoint: endPoints.checkOutCart, payload: checkOut);

      return json.decode(response.body)["order_id"];
    } catch (e) {
      await clearCart();
      rethrow;
    }
  }

  Future<bool> clearCart() async {
    try {
      await baseClient.getRequest(
        httpClient,
        endpoint: endPoints.clearCart,
      );

      return true;
    } catch (_) {
      rethrow;
    }
  }

  // ==============================================================================
// TRANSACTION SECTION
//
// This section contains functions for managing payments in the app.
// Payments are transactions made by users of the app for various services.
// The functions in this section are responsible for generating fast checkouts,
// creating and changing transaction pins, and managing users' payment history.
// ==============================================================================

  // Generate a fast checkout token for a given amount
  Future<Map<String, dynamic>> generateFastCheckOut(String amount) async {
    try {
      final http.Response response = await baseClient.postRequest(httpClient,
          endpoint: endPoints.fastCheckOut,
          payload: {"amount_in_kroon_token": amount});

      final data = json.decode(response.body);

      // Return a map containing the generated checkout details
      return {
        "kroon_token_amount": data["data"]["amount_in_kroon_token"],
        "wallet_id": data["data"]["recipient"]["wallet_id"],
        "transactional_id": data["data"]["transactional_id"]
      };
    } catch (_) {
      // Rethrow any errors encountered to calling code
      rethrow;
    }
  }

// Create a transactional PIN for the current user
  Future<String> createUsersTransactionPin(String pin) async {
    try {
      final http.Response response = await baseClient.postRequest(httpClient,
          endpoint: endPoints.createTransactionPin,
          payload: {"pin": pin, "pin_confirm": pin});

      // Extract the success message from the response and return it
      return json.decode(response.body)["message"];
    } catch (e) {
      // Rethrow any errors encountered to calling code
      rethrow;
    }
  }

// Change the transactional PIN for the current user
  Future<String> changeUsersTransactionPin(String oldPin, String newPIn) async {
    try {
      final http.Response response = await baseClient.postRequest(httpClient,
          endpoint: endPoints.changeTransactionalPin,
          payload: {"old_pin": oldPin, "new_pin": newPIn, "new_pin2": newPIn});

      // Extract the success message from the response and return it
      return json.decode(response.body)["message"];
    } catch (e) {
      // Rethrow any errors encountered to calling code
      rethrow;
    }
  }

  void checkData(final data) {
    if (data == null) {
      throw "An error occured";
    }
    return;
  }

  //---------------------ACCOUNT---------------------------//

  Future<void> deleteUsersAccount() async {
    try {
      await baseClient.postRequest(httpClient,
          endpoint: endPoints.deleteUserAccount, payload: {});
      return;
    } catch (e) {
      rethrow;
    }
  }
}
