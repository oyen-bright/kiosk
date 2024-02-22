import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/user.dart';
import 'package:kiosk/settings.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/generate_agreement/view_agrements.dart';
import 'package:kiosk/views/login/support/login_support.dart';
import 'package:kiosk/views/profile/Address/address_information.dart';
import 'package:kiosk/views/profile/payment/payment.dart';
import 'package:kiosk/views/profile/privacy/privacy_policy.dart';
import 'package:kiosk/views/profile/subscription/subscription.dart';
import 'package:kiosk/views/profile/subscription/subscription_huawei.dart';
import 'package:kiosk/views/profile/terms_and_conditions/terms_and_condition.dart';
import 'package:kiosk/views/survey/survey.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

import 'Buisness Information/buisness_details.dart';
import 'add_on/add_ons.dart';
import 'change_password/change_password.dart';
import 'e_learning/e_lerning.dart';
import 'loading/loading.dart';
import 'promo_code/promo_code.dart';
import 'settings/user_settings.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RefreshController _refreshController = RefreshController();
    final ScrollController _scrollController = ScrollController();

    String currentLocale = context.locale.toString();
    Map<String, String> supportedLanguages = {
      "en": "English",
      "fr": "Français",
      "es": "Español",
      "pt": "Portuguese",
      "yo": "Yorùbá",
      "ig": "Igbo",
      "ha": "Hausa",
      "pd": "Pidgin English",
    };

    return Scaffold(
      appBar: customAppBar(context,
          showBackArrow: false,
          showSubtitle: false,
          title: LocaleKeys.profile.tr(),
          actions: [
            languagePicker(context, supportedLanguages, currentLocale)
          ]),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: (() async {
          try {
            _refreshController.isRefresh;
            await context.read<UserCubit>().getUserDetails();
            _refreshController.refreshCompleted();
          } catch (e) {
            _refreshController.refreshFailed();
          }
        }),
        child: BlocConsumer<UserCubit, UserState>(
          listener: ((context3, state) {
            if (state.userStateStatus == UserStateStatus.error) {
              context.snackBar(state.errorMessage.toString());
            }
          }),
          builder: (context, state) {
            final currentUser = state.currentUser!;
            final offlineMode = context.watch<OfflineCubit>().isOffline();

            List<Map<String, dynamic>> menuData = [
              {
                "title": LocaleKeys.buisnessDetails.tr(),
                "icon": "assets/images/Shape2.png",
                "callback": () {
                  if (offlineMode) {
                    offlineDialog(context);
                  } else {
                    pushNewScreen(context,
                        screen: const BuisnessDetails(), withNavBar: false);
                  }
                },
              },
              {
                "title": LocaleKeys.addressDetails.tr(),
                "icon": "assets/images/address_icon.png",
                "callback": () {
                  if (offlineMode) {
                    offlineDialog(context);
                  } else {
                    pushNewScreen(context,
                        screen: const AddressInformation(), withNavBar: false);
                  }
                },
              },
              {
                "title": LocaleKeys.generateAgreements.tr(),
                "icon": "assets/images/pngwing.com.png",
                "callback": () {
                  if (offlineMode) {
                    offlineDialog(context);
                  } else {
                    pushNewScreen(context,
                        screen: const ViewAgreements(), withNavBar: false);
                  }
                },
              },
              {
                "title": LocaleKeys.payment.tr(),
                "icon": "assets/images/payemt_methods.png",
                "callback": () {
                  if (offlineMode) {
                    offlineDialog(context);
                  } else {
                    pushNewScreen(context,
                        screen: const Payment(), withNavBar: false);
                  }
                },
              },
              {
                "title": LocaleKeys.password.tr(),
                "icon": "assets/images/Path_49.png",
                "callback": () {
                  if (offlineMode) {
                    offlineDialog(context);
                  } else {
                    pushNewScreen(context,
                        screen: const ChangePassword(), withNavBar: false);
                  }
                },
              },
              // {
              //   "title": "Transaction Pin",
              //   "icon": "assets/images/transaction_pin.png",
              //   "callback": () {
              //     if (offlineMode) {
              //       offlineDialog(context);
              //     } else {
              //       pushNewScreen(context,
              //           screen: const ChangeTransactionPIN(),
              //           withNavBar: false);
              //     }
              //   },
              // },
              {
                "title": LocaleKeys.support.tr(),
                "icon": "assets/images/supportIcon.png",
                "callback": () {
                  if (offlineMode) {
                    offlineDialog(context);
                  } else {
                    pushNewScreen(context,
                        screen: const LoginSupport(), withNavBar: false);

                    // pushNewScreen(context,
                    //     screen: const FrequentlyAskedQuestions(),
                    //     withNavBar: false);
                  }
                },
              },
              {
                "title": LocaleKeys.privacyPolicy.tr(),
                "icon": "assets/images/privacy.png",
                "callback": () {
                  ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                  pushNewScreen(context,
                      screen: const PrivacyPolicy(), withNavBar: false);
                },
              },
              {
                "title": LocaleKeys.termsAndCondition.tr(),
                "icon": "assets/images/termsandc.png",
                "callback": () {
                  ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                  pushNewScreen(context,
                      screen: const TermsAndConditions(), withNavBar: false);
                },
              },
              {
                "title": LocaleKeys.eLearning.tr(),
                "icon": "assets/images/e-learning.png",
                "callback": () {
                  if (offlineMode) {
                    offlineDialog(context);
                  } else {
                    pushNewScreen(context,
                        screen: const ELearning(), withNavBar: false);
                  }
                },
              },
              if (Platform.isAndroid)
                {
                  "title": LocaleKeys.redeemPromoCode.tr(),
                  "icon": "assets/images/pizzar.png",
                  "callback": () {
                    if (offlineMode) {
                      offlineDialog(context);
                    } else {
                      pushNewScreen(context,
                          screen: const PromoCode(
                            fromProfile: true,
                          ),
                          withNavBar: false);
                    }
                  },
                },
              if (!AppSettings.isSunmiDevice)
                {
                  "title": LocaleKeys.subscription.tr(),
                  "icon": "assets/images/subscripton.png",
                  "callback": () {
                    if (offlineMode) {
                      offlineDialog(context);
                    } else {
                      pushNewScreen(context,
                          screen: AppSettings.isHuaweiDevice
                              ? SubscriptionHuawei()
                              : Subscription(),
                          withNavBar: false);
                    }
                  },
                },
              {
                "title": LocaleKeys.settings.tr(),
                "icon": "assets/images/settings.png",
                "callback": () async {
                  pushNewScreen(context,
                      screen: const UserSettings(), withNavBar: false);
                },
              },
              {
                "title": LocaleKeys.integrations.tr(),
                "icon": "assets/images/add_on.png",
                "callback": () async {
                  pushNewScreen(context,
                      screen: const AddOns(), withNavBar: false);
                },
              },
              if (!AppSettings.isSunmiDevice)
                {
                  "title": LocaleKeys.survey.tr(),
                  "icon": "assets/images/survey_icon.png",
                  "callback": () async {
                    pushNewScreen(context,
                        screen: const Survey(), withNavBar: false);
                  },
                },

              {
                "title": LocaleKeys.deleteAccount.tr(),
                "icon": "assets/images/delete_account.png",
                "callback": () async {
                  final response =
                      await logoutDeleteDialog(context, isDeleteAccount: true);
                  if (response != null) {
                    final response = await pushNewScreen(context,
                        screen: const ProfileLoadingScreen(
                          isDeleteAccount: true,
                        ),
                        withNavBar: false);
                    context.snackBar(response);
                  }
                },
              },
            ];

            final isAWorker =
                context.read<UserCubit>().state.permissions!.isAWorker;
            if (isAWorker) {
              menuData.removeAt(0);
              menuData.removeAt(9);
            }

            return ListView(
              controller: _scrollController,
              shrinkWrap: true,
              children: [
                _buildPersonalInformation(currentUser, offlineMode, context),
                _buildKioskSettings(menuData),
                10.h.height,
                _buidLogoutButton(context),
                40.h.height
              ],
            );
          },
        ),
      ),
    );
  }

  Container _buidLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: ElevatedButton(
          onPressed: () async {
            final response = await logoutDeleteDialog(context);
            if (response != null) {
              pushNewScreen(context,
                  screen: const ProfileLoadingScreen(), withNavBar: false);
            }
          },
          child: Text(LocaleKeys.logout.tr().toUpperCase())),
    );
  }

  CustomContainer _buildKioskSettings(List<Map<String, dynamic>> menuData) {
    return CustomContainer(
        alignment: Alignment.center,
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(children: [
          ContainerHeader(
              title: "Kiosk " + LocaleKeys.settings.tr(),
              subTitle: LocaleKeys
                  .toCustomizeYourKioskAppToYourLikingSimplyLocateTheFeatureYouWantToModifyAndTapOnTheCorrespondingButtonToMakeChanges
                  .tr()),
          GridView.count(
            crossAxisCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: List.generate(menuData.length, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: MenuButton(
                  callback: menuData[index]["callback"],
                  title: menuData[index]["title"],
                  iconData: menuData[index]["icon"],
                ),
              );
            }),
          )
        ]));
  }

  CustomContainer _buildPersonalInformation(
      User currentUser, bool offlineMode, BuildContext context) {
    return CustomContainer(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
        padding: EdgeInsets.all(16.r),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Builder(builder: (context) {
              final List<String> data = [
                LocaleKeys.accountHolder.tr(),
                LocaleKeys.address.tr(),
                LocaleKeys.businessName.tr(),
                LocaleKeys.businessRegistrationNumber.tr(),
                LocaleKeys.accountEmail.tr(),
              ];
              final List<String> userData = [
                '${currentUser.firstName} ${currentUser.lastName}',
                currentUser.address.isEmpty
                    ? 'N/A'
                    : '${currentUser.address[0]["street_or_flat_number"]}, ${currentUser.address[0]["street_name"]}, ${currentUser.address[0]["building_name"]}, ${currentUser.address[0]["state"]}, ${currentUser.address[0]["city"]}',
                currentUser.merchantBusinessName ?? 'N/A',
                currentUser.businessRegistrationNumber ?? 'N/A',
                currentUser.email,
              ];
              return Column(
                children: [
                  ContainerHeader(
                      title: LocaleKeys.personalInformation.tr(),
                      subTitle: LocaleKeys
                          .thisSectionDisplaysYourPersonalInformationIfYouNeedToMakeAnyChangesToYourAddressSimplyClickOnThePencilIcon
                          .tr()),
                  Column(
                      children: List.generate(data.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: AutoSizeText(
                              data[index],
                              style: context.theme.textTheme.titleSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          4.h.height,
                          SizedBox(
                            width: double.infinity,
                            child: AutoSizeText(
                              userData[index],
                            ),
                          ),
                        ],
                      ),
                    );
                  })),
                ],
              );
            }),
            // GestureDetector(
            //   onTap: () {
            //     if (offlineMode) {
            //       offlineDialog(context);
            //     } else {
            //       pushNewScreen(context,
            //           screen: const AddressInformation(), withNavBar: false);
            //     }
            //   },
            //   child: CustomContainer(
            //     height: 38.w,
            //     width: 38.w,
            //     padding: EdgeInsets.all(10.r),
            //     child: Image.asset(
            //       "assets/images/Icons - Icons Pack - Edit Pencil.png",
            //       color: context.theme.colorScheme.primary,
            //     ),
            //   ),
            // )
          ],
        ));
  }
}
