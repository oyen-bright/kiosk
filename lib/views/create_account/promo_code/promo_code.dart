import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/loading/loading_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/create_account/wellcome.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class PromoCode extends StatefulWidget {
  final bool isSME;
  const PromoCode({
    Key? key,
    this.isSME = false,
  }) : super(key: key);

  @override
  State<PromoCode> createState() => _PromoCodeState();
}

class _PromoCodeState extends State<PromoCode> {
  late final TextEditingController promoCodeTextController;
  final _formKey = GlobalKey<FormState>();
  bool havepromoCode = false;

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
    if (!havepromoCode) {
      context.pushView(const Wellcome(), clearStack: true);
    } else {
      if (_formKey.currentState!.validate()) {
        try {
          context.read<LoadingCubit>().loading();
          await context
              .read<UserRepository>()
              .verifyPromoCode(promoCode: promoCodeTextController.text.trim());
          context.read<LoadingCubit>().loaded();
          await successfulDialog(context, res: "Verified");

          context.pushView(const Wellcome(), clearStack: true);
        } catch (e) {
          context.read<LoadingCubit>().loaded();

          await anErrorOccurredDialog(context, error: e.toString());
          promoCodeTextController.clear();
          setState(() {
            havepromoCode = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingCubit, LoadingState>(
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        return WillPopScope(
          onWillPop: () async => false,
          child: Stack(children: [
            Scaffold(
                backgroundColor: context.theme.canvasColor,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: context.theme.canvasColor,
                  elevation: 0,
                  title: const AppbarLogo(),
                  centerTitle: true,
                ),
                body: Form(
                    key: _formKey,
                    child: ListView(children: [
                      20.h.height,
                      ScreenHeader(
                          title: widget.isSME
                              ? LocaleKeys.sMEAgency.tr()
                              : LocaleKeys.promoCode.tr(),
                          subTitle: widget.isSME
                              ? LocaleKeys.doYouHaveAMembershipNumber.tr()
                              : LocaleKeys.doYouHaveAPromoCode.tr()),
                      20.h.height,
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          width: double.infinity,
                          child: Text(
                              widget.isSME
                                  ? LocaleKeys.sMEAgencyGroupMembershipNumber
                                      .tr()
                                  : LocaleKeys.promoCode.tr(),
                              style: Theme.of(context).textTheme.titleSmall!)),
                      5.h.height,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: widget.isSME
                                ? LocaleKeys.sMEAgencyGroupMembershipNumber.tr()
                                : LocaleKeys.promoCode.tr(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return LocaleKeys.required.tr();
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                havepromoCode = true;
                              });
                            } else {
                              setState(() {
                                havepromoCode = false;
                              });
                            }
                          },
                          controller: promoCodeTextController,
                        ),
                      ),
                      20.h.height,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: ElevatedButton(
                          onPressed: () => checkPromoCode(),
                          child: Text(
                            havepromoCode
                                ? LocaleKeys.verifyCode.tr()
                                : LocaleKeys.skip.tr(),
                          ),
                        ),
                      )
                    ]))),
            Visibility(
              child: const LoadingWidget(),
              visible: isLoading,
            ),
          ]),
        );
      },
    );
  }
}
