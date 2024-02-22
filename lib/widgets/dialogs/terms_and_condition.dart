import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<bool?> getTermsCondition(BuildContext context) async {
  final ScrollController _scrollController = ScrollController();
  return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => FutureBuilder(
            future: context.read<UserRepository>().getTermsAndConditions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return AlertDialog(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                    titleTextStyle: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                    title: Center(
                      child: Text(LocaleKeys.termsAndCondition.tr()),
                    ),
                    content: Scrollbar(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Text(
                          snapshot.data.toString().replaceAll('“', ''),
                          textAlign: TextAlign.left,
                          style: context.theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          maximumSize: null,
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => context.popView(), // passing false
                        child: Text(
                          LocaleKeys.decline.tr(),
                        ),
                      ),
                      5.h.height,
                      ElevatedButton(
                        onPressed: () {
                          if (_scrollController.offset <
                              _scrollController.position.maxScrollExtent) {
                            _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                          } else {
                            context.popView(value: true);
                          }
                        }, // passing true
                        child: Text(LocaleKeys.accept.tr()),
                      ),
                    ],
                  );
                }
              }

              return AlertDialog(
                titleTextStyle: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
                title: Center(
                  child: Text(LocaleKeys.termsAndCondition.tr()),
                ),
                content: Wrap(
                  children: const [LinearProgressIndicator()],
                ),
              );
            },
          ));
}
