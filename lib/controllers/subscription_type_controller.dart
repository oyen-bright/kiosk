import 'package:flutter/material.dart';
import 'package:kiosk/cubits/subscription/subscription_cubit.dart';

class SubscriptionTypeController extends ValueNotifier<SubscriptionType?> {
  SubscriptionTypeController({SubscriptionType? initialValue})
      : super(initialValue ?? SubscriptionType.free);
}
