import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/views/login/login.dart';
import 'package:kiosk/widgets/dialogs/error_alert_dialog.dart';
import 'package:kiosk/widgets/loader/loading_widget.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class SwitchAccount extends StatelessWidget {
  const SwitchAccount({
    Key? key,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    Future<void> _onPressed() async {
      try {
        context.read<LoadingCubit>().loading();
        final response =
            await context.read<UserRepository>().switchToMerchant();
        context.read<LoadingCubit>().loaded();
        await successfulDialog(
          context,
          res: response,
        );
        context.pushView(const LogIn(), clearStack: true);
      } catch (e) {
        context.read<LoadingCubit>().loaded();

        anErrorOccurredDialog(context, error: e.toString());
      }
    }

    return BlocBuilder<LoadingCubit, LoadingState>(builder: (context, state) {
      final isLoading = state.status == Status.loading;

      return WillPopScope(
        onWillPop: () async => !isLoading,
        child: Stack(children: [
          SizedBox(
            height: 1.sh,
            child: Material(
              color: context.theme.canvasColor,
              child: Center(
                child: SingleChildScrollView(
                    child: SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      10.h.height,
                      Text(
                        LocaleKeys.welcomeToKiosk.tr(),
                        style: context.theme.textTheme.headlineSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      10.h.height,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                            LocaleKeys.yourAreCurrentlyOnAPERSONALACCOUNT.tr(),
                            textAlign: TextAlign.justify,
                            style: context.theme.textTheme.titleSmall!),
                      ),
                      30.h.height,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: ElevatedButton(
                          onPressed: () => _onPressed(),
                          child: Text(
                            LocaleKeys.switchToMerchantAccount.tr(),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ),
            ),
          ),
          Visibility(
            child: const LoadingWidget(title: "Switching Account"),
            visible: isLoading,
          ),
        ]),
      );
    });
  }
}
