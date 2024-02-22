import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/utils.dart';
import 'package:kiosk/views/navigator/navigation.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class SwitchBusiness extends StatefulWidget {
  const SwitchBusiness({
    Key? key,
  }) : super(key: key);

  @override
  State<SwitchBusiness> createState() => _SwitchBusinessState();
}

class _SwitchBusinessState extends State<SwitchBusiness> {
  String logoPrefix =
      "https://nyc3.digitaloceanspaces.com/test-server-space/kroon-kiosk-test-static/";

  void _onTap(BuildContext context, String id) async {
    try {
      await context.read<SelectAccountCubit>().switchBusinessProfile(id: id);
      // context.read<AnalyticsService>().logLoginEvent();
      context.pushView(const KioskNavigator(), clearStack: true);
    } catch (e) {
      anErrorOccurredDialog(context, error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
            backgroundColor: context.theme.colorScheme.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(LocaleKeys.selectBusiness.tr().toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: context.theme.colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                  18.h.height,
                  Builder(builder: (_) {
                    List merchantBusinessProfile = context
                        .read<UserLoginCubit>()
                        .state
                        .merchantBusinessProfile!;

                    return Wrap(
                        children: List.generate(merchantBusinessProfile.length,
                            (index) {
                      String? businessLogo =
                          merchantBusinessProfile[index]["business_logo"];
                      String businessId = merchantBusinessProfile[index]["id"];
                      String businessName = Util.decodeString(
                          merchantBusinessProfile[index]["business_name"]);

                      return Padding(
                        padding: EdgeInsets.all(0.r),
                        child: SizedBox(
                          width: 120.w,
                          height: 120.w,
                          child: GestureDetector(
                            onTap: () => _onTap(context, businessId),
                            child: DisplayBusinessLogo(
                              businessName: businessName,
                              businessLogo: businessLogo,
                              logoPrefix: logoPrefix,
                            ),
                          ),
                        ),
                      );
                    }));
                  }),
                  70.h.height
                ],
              ),
            )),
      ),
      Visibility(
        child: const LoadingWidget(),
        visible:
            context.watch<SelectAccountCubit>().state.selectAccountStatus ==
                SelectAccountStatus.loading,
      ),
    ]);
  }
}

class DisplayBusinessLogo extends StatelessWidget {
  const DisplayBusinessLogo({
    Key? key,
    required this.businessName,
    required this.businessLogo,
    required this.logoPrefix,
  }) : super(key: key);

  final String businessName;
  final String? businessLogo;
  final String logoPrefix;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: GridTile(
            footer: SizedBox(
              child: GridTileBar(
                backgroundColor: context.theme.colorScheme.primary,
                title: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: FittedBox(
                    child: AutoSizeText(
                      businessName,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),
                ),
              ),
            ),
            child: Builder(builder: (_) {
              if (businessLogo != null) {
                return CachedNetworkImage(
                    imageUrl: logoPrefix + businessLogo!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                            child: SpinKitFoldingCube(
                          size: 10,
                          color: context.theme.colorScheme.primary,
                        )),
                    errorWidget: (context, url, error) => Image.asset(
                          "assets/images/logo_app.png",
                          fit: BoxFit.cover,
                        ));
              }
              return Container();
            })),
      ),
    );
  }
}
