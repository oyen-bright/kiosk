import 'package:kiosk/settings.dart';

class EndPoints {
  static String base = AppSettings.base;
  static String baseOTP = base + "kroon-opt/api/v1";
  static String baseUser = base + "kroon-user/api/v1";
  static String baseAut = base + "auth/api/v1";
  static String baseApi = base + "api";
  static String baseSale = base + "kiosk-sales/api/v1";
  static String baseTransaction = base + "transactions/api/v1";
  static String baseBankInformation = base + "bank-information/api/v1";
  static String basePayment = base + "payments/api/v1";
  static String baseWorker = base + "kiosk-workers/api/v1";
  static String baseSubscription = base + "subscription/api/v1/";
  static String baseAgreement = base + "agreements/api/v1/";
  static String baseGovPanel = base + "gov-panel/api/v1/";
  static String baseELearning = base + "e-learning/api/v1/";
  static String baseCategories = base + "kiosk-categories/api/v1/";
  static String baseSales = base + "kiosk-sales/api/v1/";
  static String baseOffline = base + "kiosk-offline-mode/api/v1/";
  static String baseVirtualCard = base + "virtual-cards/api/v1/";
  static String baseLocations = base + "locations/api/v1/";
  static String baseAds = base + "ads/api/v1/";
  static String baseKYC = base + "kroon-kyc/api/v1/";
  static String baseNotifications = base + "notifications/api/v1/";

  // Government Organizations
  var governmentOrganizations = baseGovPanel + "list-of-gov-orgs/";

  // E-learning
  var getSurveys = baseELearning + "list-survey-ques/";
  var submitSurvey = baseELearning + "app-survey/";
  var getELearning = baseELearning + "kiosk-e-learning/";

  // Agreements
  var salesAndServicesAgreement =
      baseAgreement + "good-and-services-agreements/";
  var loanAgreement = baseAgreement + "loan-agreements/";
  var shareAgreement = baseAgreement + "share-agreements/";
  var employeeAgreement = baseAgreement + "business-agreements-info/";
  var allAgreements = baseAgreement + "all-agreements/";

  // Subscription
  var verifySubscriptionToken =
      baseSubscription + "inapp-receipt-verification/";
  var migrateSubscriptionPlan = baseSubscription + "inapp-migrate/";
  var verifyPromoCode = baseSubscription + "migrate-plan/";

  // Worker
  var verifyWorkerEmail = baseWorker + "/check-workers-email/";
  var createWorker = baseWorker + "/create-workers-account/";
  var addWorker = baseWorker + "/add-workers/";
  var getWorkersList = baseWorker + "/workers-account/";
  var getWorkerDetails = baseWorker + "/workers-details/";
  var checkWorkersEmail = baseWorker + "check-workers-email/";
  var createWorkersAccount = baseWorker + "create-workers-account/";

  // Sale
  var getReport = baseSales + "my-report/";
  var getSales = baseSales + "list-of-sales/";
  var getSaleDetails = baseSales + "sale-details/";
  var refundProduct = baseSale + "/product-refund/";
  var refundSale = baseSale + "/order-refund/";
  var businessFinancialReport = baseSale + "/business-financial-reports/";

  // Transactions
  var createTransactionPin = baseTransaction + "/create-transaction-pin/";
  var changeTransactionalPin = baseTransaction + "/change-transactional-pin/";
  var verifyTransactionPin = base + "transactions/api/v1/verify-pin/";

  // OTP
  var emailOtp = baseOTP + "/email-opt/";
  var verifyEmailOtp = baseOTP + "/verify-otp/";

  // User
  var deleteUserAccount = baseUser + "/delete-my-account/";
  var switchMerchantAccount = baseUser + "/switch-merchant-account/";
  var termsAndConditions = baseUser + "/terms-and-conditions/kiosk/";
  var updateBankDetails = baseUser + "/create-user-bank-details/";
  var createUserBankDetails = baseUser + "/create-user-bank-details/";
  var switchBusinessAccount = baseUser + "/switch-business-account/";
  var createUserAddress = baseUser + "/create-user-address/";
  var updateUserAddress = baseUser + "/update-user-address/";
  var refreshDeviceId = baseUser + "/device-id/";
  var businessProfile = baseUser + "/business-profile/";
  var privacyPolicy = baseUser + "/kroon-policy/kiosk/";
  var forgetPasswordReset = baseUser + "/forgot-password/";
  var forgetPassword = baseUser + "/email-forget-password/";
  var faqs = baseUser + "/koisk-faqs/";

  // Authentication
  var createUserAccount = baseAut + "/create-account/";
  var getUserAccountInformation = baseAut + "/user/";
  var resetUserPassword = baseAut + "/password/change/";
  var logoutUser = base + "auth/api/v1/logout/";

  // Token
  var getToken = baseApi + "/kroon-kiosk-token/";
  var verifyToken = baseApi + "/token/verify/";
  var refreshToken = baseApi + "/token/refresh/";

  // Products
  var uploadProduct = base + "kiosk-products/api/v1/upload-products/";
  var getAllProduct = base + "kiosk-products/api/v1/upload-products/";
  var deleteProduct = base + "kiosk-products/api/v1/product/";
  var updateProduct = base + "kiosk-products/api/v1/product/";

  // Cart
  var clearCart = base + "kiosk-cart/api/v1/clear-cart/";
  var checkOutCart = base + "kiosk-cart/api/v1/checkout/";
  var addToCart = base + "kiosk-cart/api/v1/add-to-cart/";
  var deleteFromCart = base + "kiosk-cart/api/v1/delete-cart-item/";
  var fastCheckOut = base + "kiosk-cart/api/v1/kiosk_fast_checkout/";

  // Business
  var generateBusinessPlan = base + "business-plan/api/v1/business-plan";
  var getBusinessPlan = base + "business-plan/api/v1/business-plan-detials";

// Categories
  var kioskCategories = baseCategories + "categories-list/";
  var kioskUserCategories = baseCategories + "all-user-category/";
  var getCategoryProduct = baseCategories + "categories/";
  var addUserCategory = baseCategories + "add-user-category/";
  var deleteUserCategory = baseCategories + "remove-user-category/";

  // Offline
  var dumpOfflineDataProduct = baseOffline + "upload-offline-products/";
  var dumpOfflineData = baseOffline + "upload-offline-records/";
  var sendFeedBack = baseOffline + "support-email/";
  var getKioskAppVersion = baseOffline + "kroon-app-verison/";
  var checkInternetConnection = baseOffline + "network-test/";

  // VirtualCard
  var virtualCreateInitializePayment = baseVirtualCard + "initiate-payment/";
  var getAllCards = baseVirtualCard + "virtual-cards/";
  var createVCard = baseVirtualCard + "virtual-cards/";
  var paymentVerification = basePayment + "topup-payment-verification/";

  // Location
  var kioskCountries = baseLocations + "kiosk-countries/";
  var kioskCountryStates = baseLocations + "country-state/";

  //Ads
  var getAds = baseAds + "ads/kroon_kiosk/";

  // KYC
  var kycPersonal = baseKYC + "submit-kyc/";
  var kycMerchant = baseKYC + "marchant_kyc/";

  // Notification
  var newFeed = baseNotifications + "news-feed/kiosk/";
  Map<String, String> header = AppSettings.header;
}
