// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kiosk/constants/.constants.dart';
import 'package:kiosk/controllers/.controllers.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class Subscription extends StatefulWidget {
  Subscription({Key? key, this.productDetaisl}) : super(key: key);

  ProductDetails? productDetaisl;

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  late final SubscriptionTypeController subscriptionTypeController;

  @override
  void initState() {
    context.read<SubscriptionCubit>().updatePromoCode(
        context.read<UserLoginCubit>().state.userPermissions!.hasPromoCode);
    subscriptionTypeController = SubscriptionTypeController();

    super.initState();
  }

  @override
  void dispose() {
    subscriptionTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionCubit, SubscriptionState>(
      listener: (context, state) {
        if (state.purchaseStatus == AppPurchaseStatus.error ||
            state.purchaseStatus == AppPurchaseStatus.invalid) {
          anErrorOccurredDialog(context, error: state.errorMessage);
        }
      },
      builder: (context, state) {
        final _storeLoading = state.status == StoreStatus.loading;
        final _purchasePending =
            state.purchaseStatus == AppPurchaseStatus.pending ||
                state.purchaseStatus == AppPurchaseStatus.verifying;
        final _currentSubscription = state.currentSubscription;
        final _currentSubscriptionId = state.currentSubscriptionId;
        subscriptionTypeController.value = _currentSubscription;

        return WillPopScope(
          onWillPop: () async => !_storeLoading || !_purchasePending,
          child: Stack(
            children: [
              Scaffold(
                appBar: customAppBar(
                  context,
                  title: LocaleKeys.subscription.tr(),
                  showBackArrow: true,
                  subTitle: LocaleKeys.profile.tr(),
                  showNewsAndPromo: false,
                  showNotifications: false,
                ),
                body: Builder(builder: (context) {
                  switch (state.status) {
                    case StoreStatus.storeUnavailable:
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(LocaleKeys.storeIsCurentlyNotAvailable.tr()),
                            TextButton(
                                onPressed: () {
                                  context
                                      .read<SubscriptionCubit>()
                                      .reloadStore();
                                },
                                child: Text(LocaleKeys.retry.tr()))
                          ],
                        ),
                      );
                    case StoreStatus.storeLoaded:
                      state.purchases.map((PurchaseDetails purchase) {
                        if (purchase.pendingCompletePurchase) {
                          context
                              .read<SubscriptionCubit>()
                              .completePurchase(purchase);
                        }
                      });

                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        if (widget.productDetaisl != null) {
                          final data = widget.productDetaisl;
                          context
                              .read<SubscriptionCubit>()
                              .upgradeSubscription(data!);
                          widget.productDetaisl = null;
                        }
                      });

                      return SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: ValueListenableBuilder(
                            valueListenable: subscriptionTypeController,
                            builder: (context, SubscriptionType? value, child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          ContainerHeader(
                                              subTitle: LocaleKeys
                                                  .subScriptionSubtitiel
                                                  .tr(),
                                              title: LocaleKeys
                                                  .chooseYourSubscriptionPlan
                                                  .tr()),
                                          _buildSubscriptionType(
                                              title: LocaleKeys.free.tr(),
                                              subTitle: "Basic",
                                              products: [],
                                              currentSubscription:
                                                  _currentSubscription,
                                              type: SubscriptionType.free,
                                              features: freeFeatures),
                                          _buildSubscriptionType(
                                              products: context
                                                  .read<SubscriptionCubit>()
                                                  .mapSelectedSubscription(
                                                      SubscriptionType
                                                          .kioskPlus),
                                              subTitle: "KroonKiosk Plus",
                                              title: LocaleKeys.paid.tr(),
                                              currentSubscription:
                                                  _currentSubscription,
                                              type: SubscriptionType.kioskPlus,
                                              features: kioskPlusFeatures),
                                          _buildSubscriptionType(
                                              products: context
                                                  .read<SubscriptionCubit>()
                                                  .mapSelectedSubscription(
                                                      SubscriptionType
                                                          .kioskPro),
                                              subTitle: "KroonKiosk Pro",
                                              title: LocaleKeys.paid.tr(),
                                              currentSubscription:
                                                  _currentSubscription,
                                              type: SubscriptionType.kioskPro,
                                              features: kioskProFeatures),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (value != SubscriptionType.free)
                                    ElevatedButton(
                                      onPressed: () async {
                                        final res = await showModalBottomSheet(
                                          isScrollControlled: true,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          context: context,
                                          builder: (context) =>
                                              SubscriptionBottomSheet(
                                            currentId: _currentSubscriptionId!,
                                            products: context
                                                .read<SubscriptionCubit>()
                                                .mapSelectedSubscription(
                                                    value!),
                                          ),
                                        );
                                        if (res != null) {
                                          context
                                              .read<SubscriptionCubit>()
                                              .upgradeSubscription(res);
                                        }
                                      },
                                      child: Text(
                                        _currentSubscription == value
                                            ? LocaleKeys
                                                .cancelUpgradeSubscription
                                                .tr()
                                            : LocaleKeys.upgradeSubscription
                                                .tr(),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<SubscriptionCubit>()
                                          .restoreSubscription();
                                    },
                                    child: Text(
                                        LocaleKeys.restoreSubscriptions.tr()),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );

                    case StoreStatus.error:
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(LocaleKeys.storeIsCurentlyNotAvailable.tr()),
                            Text(state.errorMessage ?? ""),
                            TextButton(
                                onPressed: () {
                                  context
                                      .read<SubscriptionCubit>()
                                      .reloadStore();
                                },
                                child: Text(LocaleKeys.retry.tr()))
                          ],
                        ),
                      );

                    case StoreStatus.loading:
                      return const Center(
                        child: LoadingWidget(),
                      );
                  }
                }),
              ),
              Visibility(
                child: const LoadingWidget(),
                visible: _purchasePending,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionType(
      {required String title,
      required String subTitle,
      required List<ProductDetails> products,
      required SubscriptionType currentSubscription,
      required SubscriptionType type,
      required List<String> features}) {
    return GestureDetector(
      onTap: () {
        subscriptionTypeController.value = type;
      },
      child: Container(
        // height: 150,
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
            border: Border.all(
                width: 3,
                color: subscriptionTypeController.value == type
                    ? context.theme.colorScheme.primary
                    : Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 5),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        5.height,
                        Text(
                          title,
                          textAlign: TextAlign.left,
                          style: context.theme.textTheme.titleSmall!,
                        ),
                        1.h.height,
                        Text(
                          subTitle,
                          style: context.theme.textTheme.titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 10,
                          children: [
                            for (var i in products)
                              Text.rich(
                                TextSpan(
                                  text: i.price,
                                  children: [
                                    TextSpan(
                                      style: context.theme.textTheme.bodyMedium,
                                      text: i.id.contains("yearly")
                                          ? " /" + LocaleKeys.yearly.tr()
                                          : " /" + LocaleKeys.monthly.tr(),
                                    ),
                                  ],
                                  style: context.theme.textTheme.titleLarge!
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        5.h.height,
                        Wrap(
                          children: features
                              .map((feature) => Text(
                                    '• $feature',
                                    style: context.theme.textTheme.bodySmall!,
                                  ))
                              .toList(),
                        ),
                        5.height,
                      ],
                    ),
                  ),
                  type == SubscriptionType.free
                      ? const SizedBox()
                      : Flexible(
                          child: SizedBox(
                          width: double.infinity,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                    width: 5,
                                    color:
                                        subscriptionTypeController.value == type
                                            ? context.theme.colorScheme.primary
                                            : Colors.grey)),
                            width: 20,
                            alignment: Alignment.centerRight,
                          ),
                        ))
                ],
              ),
            ),
            type == currentSubscription
                ? Positioned(
                    right: 0,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: context.theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        LocaleKeys.currentPlan.tr().toUpperCase(),
                        style: context.theme.textTheme.bodySmall!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}

class SubscriptionBottomSheet extends StatefulWidget {
  const SubscriptionBottomSheet({
    Key? key,
    required this.products,
    required this.currentId,
  }) : super(key: key);

  final List<ProductDetails> products;
  final String currentId;

  @override
  _SubscriptionBottomSheetState createState() =>
      _SubscriptionBottomSheetState();
}

class _SubscriptionBottomSheetState extends State<SubscriptionBottomSheet> {
  ProductDetails? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              10.height,
              Text(
                LocaleKeys.chooseYourSubscriptionPlan.tr(),
                style: context.theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              for (int i = 0; i < widget.products.length; i++)
                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: ListTile(
                        // enabled: widget.products[i].id != widget.currentId,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5.h, horizontal: 5.w),
                        horizontalTitleGap: 1,
                        leading: Radio<ProductDetails>(
                          value: widget.products[i],
                          groupValue: _selectedPlan,
                          onChanged: (ProductDetails? value) {
                            setState(() {
                              _selectedPlan = value;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _selectedPlan = widget.products[i];
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tileColor: context.theme.canvasColor.darken(5),
                        subtitle: Text(
                          widget.products[i].description,
                          style: context.theme.textTheme.bodySmall!.copyWith(
                              color: widget.products[i].id == widget.currentId
                                  ? Colors.grey
                                  : null),
                        ),
                        title: Text(
                          widget.products[i].title,
                          style: context.theme.textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: widget.products[i].id == widget.currentId
                                  ? Colors.grey
                                  : null),
                        ),
                        trailing: Text.rich(
                          TextSpan(
                            text: widget.products[i].price,
                            children: [
                              TextSpan(
                                style: context.theme.textTheme.bodyMedium,
                                text: i == widget.products.length - 1 ||
                                        widget.products[i].id.contains("yearly")
                                    ? " /" + LocaleKeys.yearly.tr()
                                    : " /" + LocaleKeys.monthly.tr(),
                              ),
                            ],
                            style: context.theme.textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: widget.products[i].id == widget.currentId
                                    ? Colors.grey
                                    : null),
                          ),
                        ),
                      ),
                    ),
                    if (i == widget.products.length - 1)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              decoration: const BoxDecoration(
                                  color: Color.fromRGBO(0, 186, 255, 1),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5))),
                              child: Text(
                                widget.products[i].id == "kiosk_plus_yearly_gov"
                                    ? "90% " + LocaleKeys.discount.tr()
                                    : "16% " + LocaleKeys.discount.tr(),
                                style: context.theme.textTheme.bodySmall!
                                    .copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                            5.width,
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              decoration: const BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5))),
                              child: Text(
                                LocaleKeys.RECOMMENDED.tr(),
                                style: context.theme.textTheme.bodySmall!
                                    .copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      )
                  ],
                ),
              50.h.height,
              ElevatedButton(
                child: Text(_selectedPlan?.id == widget.currentId
                    ? LocaleKeys.cancelSubscription.tr()
                    : LocaleKeys.continuE.tr()),
                onPressed: () {
                  if (_selectedPlan?.id == widget.currentId) {
                    context.read<SubscriptionCubit>().cancelSubscription();
                    context.popView();
                  } else {
                    context.popView(value: _selectedPlan);
                  }
                },
              ),
              TextButton(
                  onPressed: () => context.popView(),
                  child: Text(LocaleKeys.cancel.tr()))
            ],
          ),
        ),
      ),
    );
  }
}
