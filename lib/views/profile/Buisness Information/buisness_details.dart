import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/utils.dart';
import 'package:kiosk/views/profile/Buisness%20Information/buisness_info_edit.dart';
import 'package:kiosk/widgets/.widgets.dart';

class BuisnessDetails extends StatefulWidget {
  const BuisnessDetails({Key? key}) : super(key: key);

  @override
  State<BuisnessDetails> createState() => _BuisnessDetailsState();
}

class _BuisnessDetailsState extends State<BuisnessDetails> {
  Map<String, dynamic>? businessInformation;
  File? businessLogo;

  @override
  void initState() {
    getBusinessInformation();
    super.initState();
  }

  void getBusinessInformation() async {
    try {
      context.read<LoadingCubit>().loading();
      final response =
          await context.read<UserRepository>().getBusinessInformation();
      context.read<LoadingCubit>().loaded();
      setState(() {
        businessInformation = response;
      });
    } catch (e) {
      context.read<LoadingCubit>().loaded();
      context.snackBar(e.toString());
      context.popView();
    }
  }

  Future<void> updateLogo(File file) async {
    try {
      context.read<LoadingCubit>().loading();
      await context
          .read<UserRepository>()
          .updateBusinessLogo(file, businessInformation: businessInformation!);
      context.read<LoadingCubit>().loaded();
      context.read<UserCubit>().getUserDetails();

      setState(() {
        businessLogo = file;
      });
    } catch (e) {
      context.read<LoadingCubit>().loaded();
      context.snackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingCubit, LoadingState>(
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        if (businessInformation == null) {
          return Container(
              color: context.theme.scaffoldBackgroundColor,
              child: const LoadingWidget());
        }
        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Stack(
            children: [
              Scaffold(
                  appBar: customAppBar(context,
                      title: LocaleKeys.businessInformation.tr(),
                      showNewsAndPromo: false,
                      subTitle: LocaleKeys.profile.tr(),
                      showNotifications: false,
                      showBackArrow: true),
                  body: ListView(children: [
                    _buildBusinessLogo(context),
                    _buildBusinessDetails(),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 10.h),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.pushView(BuisnessInfoEdit(
                            data: businessInformation!,
                          ));
                        },
                        child: Text(
                          LocaleKeys.edit.tr(),
                        ),
                      ),
                    ),
                  ])),
              if (isLoading) const LoadingWidget()
            ],
          ),
        );
      },
    );
  }

  Widget _buildBusinessDetails() {
    return CustomContainer(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          ContainerHeader(
            title: LocaleKeys.businessInformation.tr(),
            subTitle: LocaleKeys
                .thisSectionDisplaysYourBusinessInformationWhichIncludesYourBusinessNameContactNumberAndAddress
                .tr(),
          ),
          _buildInfoRow(LocaleKeys.businessName.tr(),
              Util.decodeString(businessInformation!["business_name"])),
          const Divider(),
          _buildInfoRow(LocaleKeys.businessContactNumber.tr(),
              businessInformation!["business_contact_number"]),
          const Divider(),
          _buildInfoRow(LocaleKeys.businessAddress.tr(),
              businessInformation!["business_address"]),
          const Divider(),
          _buildInfoRow(LocaleKeys.businessRegistrationNumber.tr(),
              businessInformation!["business_registration_number"] ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildBusinessLogo(BuildContext context) {
    return CustomContainer(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          ContainerHeader(
            title: LocaleKeys.businessLogo.tr(),
            subTitle: LocaleKeys
                .youCanSeeYourBusinessLogoHereToMakeAnyChangesToYourLogoSimplyClickOnThePencilIcon
                .tr(),
          ),
          ListTile(
            title: Container(
                alignment: Alignment.center,
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20.r)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0.r),
                  child: Builder(builder: (context) {
                    if (businessLogo != null) {
                      return Image.file(businessLogo!, fit: BoxFit.contain);
                    }
                    if (businessInformation?["business_logo"] == null) {
                      return Container();
                    }
                    return CachedNetworkImage(
                        imageUrl: businessInformation?["business_logo"] ?? "");
                  }),
                )),
            trailing: IconButton(
                onPressed: () async {
                  final image = await imagePicker(context);

                  if (image != null) {
                    await updateLogo(image);
                  }
                },
                icon: const Icon(Icons.edit)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 20.h),
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          width: double.infinity,
          child: Text(label, style: context.theme.textTheme.bodySmall!),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          width: double.infinity,
          child: AutoSizeText(
            value,
            maxLines: 1,
            textAlign: TextAlign.left,
            style: context.theme.textTheme.bodyMedium!.copyWith(
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ].reversed.toList(),
    );
  }
}
