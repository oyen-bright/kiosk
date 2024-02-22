import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/cubits/.cubits.dart';

String getCurrency(BuildContext context) {
  final userState = context.read<UserCubit>().state;

  if (userState.permissions!.isAWorker) {
    return userState.permissions!.businessCurrency;
  }
  return userState.currentUser!.defaultCurrencyId;
}

String toUpperCase(String data) {
  return toBeginningOfSentenceCase(data) ?? "";
}
