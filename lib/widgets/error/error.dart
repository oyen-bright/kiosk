import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/offline/offline_cubit.dart';
import 'package:kiosk/translations/locale_keys.g.dart';

class Error extends StatelessWidget {
  final String? info;
  final void Function()? onPressed;
  final String? buttonTitle;

  const Error({Key? key, this.info, this.onPressed, this.buttonTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final offlineMode = context.read<OfflineCubit>().isOffline();

    return SizedBox(
      child: Center(
        child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.transparent,
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 50.w),
                    child: Image.asset(
                      "assets/images/Cancelled.png",
                      height: 120.h,
                      width: 150.w,
                    )),
                Container(
                  margin: EdgeInsets.only(
                    bottom: 4.h,
                  ),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    offlineMode
                        ? LocaleKeys.offlineMode.tr()
                        : LocaleKeys.anErrorOccured.tr(),
                    style:
                        TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: 10.h,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    offlineMode
                        ? LocaleKeys.youReCurrentlyOnOfflineMode.tr()
                        : info.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15.sp, fontWeight: FontWeight.normal),
                  ),
                ),
                onPressed == null
                    ? Container()
                    : TextButton(
                        onPressed: onPressed, child: Text(buttonTitle!))
              ],
            )),
      ),
    );
  }
}
