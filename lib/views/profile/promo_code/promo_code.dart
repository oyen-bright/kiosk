import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class PromoCode extends StatefulWidget {
  final bool fromProfile;

  const PromoCode({Key? key, this.fromProfile = false}) : super(key: key);

  @override
  State<PromoCode> createState() => _PromoCodeState();
}

class _PromoCodeState extends State<PromoCode> {
  late final TextEditingController promoCodeTextController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    promoCodeTextController = TextEditingController();
  }

  @override
  void dispose() {
    promoCodeTextController.dispose();
    super.dispose();
  }

  void checkPromoCode() async {
    if (_formKey.currentState!.validate()) {
      try {
        context.unFocus();
        context.read<LoadingCubit>().loading(message: "Verifying Promo Code");
        await context
            .read<UserRepository>()
            .verifyPromoCode(promoCode: promoCodeTextController.text.trim());
        context.read<LoadingCubit>().loaded();
        await successfulDialog(context, res: "Promo code verified");
        await promoCodeDialog(context);
        context.popView();
      } catch (e) {
        context.read<LoadingCubit>().loaded();
        anErrorOccurredDialog(context, error: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingCubit, LoadingState>(
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Stack(children: [
            Scaffold(
                appBar: customAppBar(
                  context,
                  title: LocaleKeys.promoCode.tr(),
                  showBackArrow: true,
                  showNewsAndPromo: false,
                  showNotifications: false,
                  subTitle: LocaleKeys.profile.tr(),
                ),
                body: ListView(
                  shrinkWrap: true,
                  children: [
                    CustomContainer(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(
                          horizontal: 22.w, vertical: 10.h),
                      padding: EdgeInsets.all(16.r),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            ContainerHeader(
                                subTitle: LocaleKeys.promoCodeSubtitle.tr(),
                                title: LocaleKeys.doYouhaveaPromoCode.tr()),
                            SizedBox(
                              width: double.infinity,
                              child: Text(LocaleKeys.promoCode.tr(),
                                  style:
                                      Theme.of(context).textTheme.titleSmall!),
                            ),
                            5.h.height,
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LocaleKeys.required.tr();
                                }
                                return null;
                              },
                              controller: promoCodeTextController,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                          horizontal: 25.w, vertical: 15.h),
                      child: ElevatedButton(
                        onPressed: () => checkPromoCode(),
                        child: Text(LocaleKeys.verifyCode.tr()),
                      ),
                    ),
                  ],
                )),
            Visibility(
                visible: isLoading,
                child: LoadingWidget(
                  title: state.msg,
                ))
          ]),
        );
      },
    );
  }
}
