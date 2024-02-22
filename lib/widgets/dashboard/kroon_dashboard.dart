import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/constants/constant_color.dart';
import 'package:kiosk/cubits/settings/user_settings_cubit.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/widgets/.widgets.dart';

class KroonDashboard extends StatelessWidget {
  final String balance;
  final String walletId;
  const KroonDashboard(
      {Key? key, required this.balance, required this.walletId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 15.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        color: kioskBlue,
        child: Column(
          children: [
            _buildLogo(context),
            _buildBalance(context),
            _buildWalletId(context)
          ],
        ));
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      alignment: Alignment.centerLeft,
      height: 30.h,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Image.asset("assets/images/Group 10.png")),
          Flexible(
              child: GestureDetector(
                  onTap: () => showinformationDialog(context,
                      title: "Kroon",
                      information:
                          "Kroon App is the link between the merchant and the greater community. With low transaction fees the Kroon platform is designed and developed to be affordable and to assist the community in becoming more digital with how they use their money. "),
                  child: const Icon(
                    Icons.info,
                    color: Colors.white,
                  )))
        ],
      ),
    );
  }

  Widget _buildBalance(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            child: AutoSizeText(
          LocaleKeys.balance.tr(),
          maxLines: 1,
          style: const TextStyle(color: Colors.white),
        )),
        Flexible(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AutoSizeText(
              LocaleKeys.status.tr(),
              textAlign: TextAlign.end,
              maxLines: 1,
              style: const TextStyle(color: Colors.white),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: AutoSizeText(
                LocaleKeys.active.tr(),
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Colors.green),
              ),
            ),
          ],
        ))
      ],
    );
  }

  Widget _buildWalletId(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              const AutoSizeText(
                "K𝇍",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(left: 5.w),
                  child: Row(
                    children: [
                      BlocBuilder<UserSettingsCubit, UserSettingsState>(
                        builder: (context, state) {
                          final showKroonBalance = state.showKroonBalance;
                          return AutoSizeText(
                            hideAccBalance(context, amountFormatter(balance),
                                hideBalance: !showKroonBalance),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: Colors.white),
                          );
                        },
                      ),
                      SizedBox(
                        width: 2.w,
                      ),
                      const ShowHideBalance()
                    ],
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              Flexible(
                  child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AutoSizeText(
                      LocaleKeys.walletID.tr(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: AutoSizeText(
                      walletId,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )),
              Flexible(
                  child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AutoSizeText(
                      LocaleKeys.type.tr(),
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: AutoSizeText(
                      "Merchant",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: const Color.fromRGBO(248, 193, 32, 1)),
                    ),
                  )
                ],
              ))
            ],
          ),
        ],
      ),
    );
  }
}

class ShowHideBalance extends StatelessWidget {
  const ShowHideBalance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        context.read<UserSettingsCubit>().toggleShowKroonBalance();
      },
      child: Builder(builder: (context) {
        if (context.watch<UserSettingsCubit>().state.showKroonBalance) {
          return const Icon(
            Icons.visibility_off,
            color: Colors.white,
          );
        }
        return const Icon(
          Icons.visibility,
          color: Colors.white,
        );
      }),
    );
  }
}
