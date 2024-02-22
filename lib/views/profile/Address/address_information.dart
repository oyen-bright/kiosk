import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/profile/Address/user_address.dart';
import 'package:kiosk/widgets/.widgets.dart';

//TODO:Deleting of users address, address id is missin from endpoint
//TODO:Editing  of users address, address id is missin from endpoint

class AddressInformation extends StatefulWidget {
  const AddressInformation({Key? key}) : super(key: key);

  @override
  State<AddressInformation> createState() => _AddressInformationState();
}

class _AddressInformationState extends State<AddressInformation> {
  void deleteAddress(String id) async {
    context.read<LoadingCubit>().loading();
    try {
      final response =
          await context.read<UserRepository>().deleteUserAddress(id: id);
      context.read<LoadingCubit>().loaded();
      await context.read<UserCubit>().getUserDetails();
      context.snackBar(LocaleKeys.successful.tr());
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

        return WillPopScope(
            onWillPop: () async => !isLoading,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Scaffold(
                  appBar: customAppBar(
                    context,
                    title: LocaleKeys.address.tr(),
                    showBackArrow: true,
                    showNewsAndPromo: false,
                    showNotifications: false,
                    subTitle: LocaleKeys.profile.tr(),
                  ),
                  body: BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      List<dynamic> address = state.currentUser?.address ?? [];
                      return ListView(
                        children: [
                          CustomContainer(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                                horizontal: 22.w, vertical: 10.h),
                            padding: EdgeInsets.all(16.r),
                            child: Column(
                              children: [
                                ContainerHeader(
                                    title: LocaleKeys.addressInformation.tr(),
                                    subTitle: LocaleKeys
                                        .pleaseseeyouraddressinformationbelowTomakechangessimplytapontheaddressyouwanttoeditorswipelefttodeleteit
                                        .tr()),
                                ...address.map((content) {
                                  final display =
                                      '${content['street_or_flat_number']} ${content['building_name']}, ${content['street_name']}, ${content['city']}, ${content['state']}';
                                  return _buildAdress(
                                      content, display, context);
                                }).toList(),
                                SizedBox(height: 10.h),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: address.isEmpty || address.length < 2,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 10.h),
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  context.pushView(const EditUserAddress());
                                },
                                child: Text(
                                  LocaleKeys.addAdddress.tr(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Visibility(
                  child: const LoadingWidget(),
                  visible: isLoading,
                ),
              ],
            ));
      },
    );
  }

  Column _buildAdress(content, String display, BuildContext context) {
    return Column(
      children: [
        Slidable(
          key: ValueKey(content['id']),
          endActionPane: ActionPane(
            // dismissible: DismissiblePane(onDismissed: () {}),
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => deleteAddress(content['id']),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                label: LocaleKeys.delete.tr(),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () {
              context.pushView(EditUserAddress(currentAddress: content));
            },
            child: Container(
              height: 30.h,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: AutoSizeText(
                display,
                maxLines: 1,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 0.h, bottom: 20.h),
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          width: double.infinity,
          child: AutoSizeText(
            content['type'] == 'permanent'
                ? LocaleKeys.permanentAddress.tr()
                : LocaleKeys.currentAddress.tr(),
            style: Theme.of(context).textTheme.bodySmall!,
          ),
        ),
      ],
    );
  }
}
