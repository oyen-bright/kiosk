// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:currency_picker/currency_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/mixins/validation_mixin.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sizedbox_extention/sizedbox_extention.dart';

import 'components/country_picker.dart';

//Todo: change design

class GenerateSaleServiceAgreement extends StatefulWidget {
  const GenerateSaleServiceAgreement({
    Key? key,
  }) : super(key: key);

  @override
  State<GenerateSaleServiceAgreement> createState() =>
      _GenerateSaleServiceAgreementState();
}

class _GenerateSaleServiceAgreementState
    extends State<GenerateSaleServiceAgreement> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController sellerNameController;
  late final TextEditingController sellerAddressController;
  late final TextEditingController sellerCountryController;
  late final TextEditingController buyerNameController;
  late final TextEditingController buyerAddressController;
  late final TextEditingController buyerCountryController;
  late final TextEditingController goodServiceController;
  late final TextEditingController goodServiceNameController;
  late final TextEditingController quantityOfGoodsServicesController;
  late final TextEditingController priceOfGoodsOrServicesController;
  late final TextEditingController goodServiceDeliveryAddressController;
  late final TextEditingController companyOrPersonController;
  late final TextEditingController companyOrPersonSellerController;

  late final FocusNode sellerNameFocusNode;
  late final FocusNode sellerAddressFocusNode;
  late final FocusNode sellerCountryFocusNode;
  late final FocusNode buyerNameFocusNode;
  late final FocusNode buyerAddressFocusNode;
  late final FocusNode buyerCountryFocusNode;
  late final FocusNode goodServiceFocusNode;
  late final FocusNode goodServiceNameFocusNode;
  late final FocusNode quantityOfGoodsServicesFocusNode;
  late final FocusNode priceOfGoodsOrServicesFocusNode;
  late final FocusNode goodServiceDeliveryAddressFocusNode;
  late final FocusNode companyOrPersonFocusNode;
  late final FocusNode companyOrPersonSellerFocusNode;

  @override
  void initState() {
    super.initState();

    context.read<LoadingCubit>().loaded();

    sellerNameController = TextEditingController();
    sellerAddressController = TextEditingController();
    sellerCountryController = TextEditingController();
    buyerNameController = TextEditingController();
    buyerAddressController = TextEditingController();
    buyerCountryController = TextEditingController();
    goodServiceNameController = TextEditingController();
    goodServiceController = TextEditingController();
    quantityOfGoodsServicesController = TextEditingController();
    priceOfGoodsOrServicesController = TextEditingController();
    goodServiceDeliveryAddressController = TextEditingController();
    companyOrPersonController = TextEditingController();
    companyOrPersonSellerController = TextEditingController();

    sellerNameFocusNode = FocusNode();
    sellerAddressFocusNode = FocusNode();
    sellerCountryFocusNode = FocusNode();
    buyerNameFocusNode = FocusNode();
    buyerAddressFocusNode = FocusNode();
    buyerCountryFocusNode = FocusNode();
    goodServiceFocusNode = FocusNode();
    goodServiceNameFocusNode = FocusNode();
    quantityOfGoodsServicesFocusNode = FocusNode();
    priceOfGoodsOrServicesFocusNode = FocusNode();
    goodServiceDeliveryAddressFocusNode = FocusNode();
    companyOrPersonFocusNode = FocusNode();
    companyOrPersonSellerFocusNode = FocusNode();
  }

  @override
  void dispose() {
    sellerNameController.dispose();
    sellerAddressController.dispose();
    sellerCountryController.dispose();
    buyerNameController.dispose();
    buyerAddressController.dispose();
    buyerCountryController.dispose();
    goodServiceController.dispose();
    goodServiceNameController.dispose();
    quantityOfGoodsServicesController.dispose();
    priceOfGoodsOrServicesController.dispose();
    goodServiceDeliveryAddressController.dispose();
    companyOrPersonController.dispose();

    sellerNameFocusNode.dispose();
    sellerAddressFocusNode.dispose();
    sellerCountryFocusNode.dispose();
    buyerNameFocusNode.dispose();
    buyerAddressFocusNode.dispose();
    buyerCountryFocusNode.dispose();
    goodServiceFocusNode.dispose();
    goodServiceNameFocusNode.dispose();
    quantityOfGoodsServicesFocusNode.dispose();
    priceOfGoodsOrServicesFocusNode.dispose();
    goodServiceDeliveryAddressFocusNode.dispose();
    companyOrPersonFocusNode.dispose();

    super.dispose();
  }

  static DateTime now = DateTime.now();
  final formattedDate2 = DateFormat("d'th day of' MMMM, yyyy").format(now);

  Map<String, String> getFormValues() {
    final formValues = <String, String>{
      'sellerName': sellerNameController.text,
      'sellerAddress': sellerAddressController.text,
      'ownerName': context.read<UserCubit>().state.currentUser!.name.toString(),
      'sellerCountry': sellerCountryController.text,
      'buyerCountry': buyerCountryController.text,
      'buyerName': buyerNameController.text,
      'buyerAddress': buyerAddressController.text,
      'type': goodServiceController.text,
      'productName': goodServiceNameController.text,
      'productQuantity': quantityOfGoodsServicesController.text,
      'priceOfGoodService':
          selectedCurrency.code + priceOfGoodsOrServicesController.text,
      'deliveryAddress': goodServiceDeliveryAddressController.text,
      'buyerType': companyOrPersonController.text,
      'sellerType': companyOrPersonSellerController.text,
      'formattedDate': formattedDate2,
    };

    return formValues;
  }

  onPressed() async {
    context.unFocus();
    if (_formKey.currentState!.validate()) {
      final userSignature = await showSignaturePad(context);

      if (userSignature != null) {
        final dir = await path_provider.getTemporaryDirectory();
        final targetPath = dir.absolute.path;

        final signature = convertUint8ListToFile(
            userSignature, targetPath + "/signature${generateNumber()}.png");
        try {
          context.read<LoadingCubit>().loading(message: "");
          await context
              .read<UserRepository>()
              .generateGoodServicesAgreement(getFormValues(), signature);
          context.read<LoadingCubit>().loaded();
          await successfulDialog(context,
              res: "Agreement Generated Successfully");
          context.popView();
        } catch (e) {
          context.read<LoadingCubit>().loaded();
          anErrorOccurredDialog(context, error: e.toString());
        }
      }
    }
  }

  Currency selectedCurrency = Currency.from(json: {
    'code': 'USD',
    'name': 'United States Dollar',
    'symbol': '\$',
    'number': 840,
    'flag': 'USD',
    'decimal_digits': 2,
    'name_plural': 'US dollars',
    'symbol_on_left': true,
    'decimal_separator': '.',
    'thousands_separator': ',',
    'space_between_amount_and_symbol': false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingCubit, LoadingState>(
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: Stack(children: [
            Scaffold(
              backgroundColor: context.theme.canvasColor,
              appBar: AppBar(
                backgroundColor: context.theme.canvasColor,
                foregroundColor: context.theme.colorScheme.primary,
                centerTitle: false,
                elevation: 0,
              ),
              body: Form(
                  key: _formKey,
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 25.w),
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ScreenHeader(
                                padding: 0,
                                subTitle:
                                    "Please provide information about the good or services being offered for sale, together with the details of the buyer and seller ot generate your Agreement.",
                                title:
                                    "Generate Sale of Good or Services Agreement"),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.info,
                              title: "Seller Information",
                            ),
                            FormDropDown(
                              title: "Company or Person?",
                              contentList: const ["Company", "Person"],
                              helperText:
                                  "Who is selling the goods or services?",
                              controller: companyOrPersonSellerController,
                              nextFocusNode: sellerNameFocusNode,
                              focusNode: companyOrPersonSellerFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: sellerNameFocusNode,
                              controller: sellerNameController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "What is the full legal name of the seller it can can be company?",
                              title: "Seller Name",
                              nextFocusNode: sellerAddressFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: sellerAddressFocusNode,
                              controller: sellerAddressController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "What is the registered address of the seller?",
                              title: "Seller Address",
                              nextFocusNode: sellerCountryFocusNode,
                            ),
                            20.h.height,
                            CountrySelectionFormField(
                              controller: sellerCountryController,
                              nextFocusNode: companyOrPersonFocusNode,
                              focusNode: sellerCountryFocusNode,
                              helperText:
                                  "In which country is the seller registered?",
                              title: "Seller Country",
                            ),
                            20.height,
                            const SegmentHeader(
                              icon: Icons.person,
                              title: "Buyer Information",
                            ),
                            FormDropDown(
                              title: "Company or Person?",
                              contentList: const ["Company", "Person"],
                              helperText: "Who are you selling to?",
                              controller: companyOrPersonController,
                              nextFocusNode: buyerNameFocusNode,
                              focusNode: companyOrPersonFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: buyerNameFocusNode,
                              controller: buyerNameController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "What is the full legal name of the buyer?",
                              title: "Buyer Name",
                              nextFocusNode: buyerAddressFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: buyerAddressFocusNode,
                              controller: buyerAddressController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "What is the registered address of the buyer?",
                              title: " Buyer Address",
                              nextFocusNode: buyerCountryFocusNode,
                            ),
                            20.h.height,
                            CountrySelectionFormField(
                              controller: buyerCountryController,
                              nextFocusNode: goodServiceFocusNode,
                              focusNode: buyerCountryFocusNode,
                              helperText:
                                  "In which country is the buyer registered?",
                              title: " Buyer Country",
                            ),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.person,
                              title: "Sale And Purchase Details",
                            ),
                            FormDropDown(
                              title: "Goods or Services?",
                              contentList: const ["Goods", "Services"],
                              helperText:
                                  "Are you selling a goods or services?",
                              controller: goodServiceController,
                              nextFocusNode: goodServiceNameFocusNode,
                              focusNode: goodServiceFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: goodServiceNameFocusNode,
                              controller: goodServiceNameController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "What goods or services are being sold?",
                              title: " Name",
                              nextFocusNode: quantityOfGoodsServicesFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: quantityOfGoodsServicesFocusNode,
                              controller: quantityOfGoodsServicesController,
                              keyboardType: TextInputType.text,
                              hintText: "100 units",
                              helperText:
                                  "What is the quantity of goods or the extent of services to be provided?",
                              title: "Quantity",
                              nextFocusNode: priceOfGoodsOrServicesFocusNode,
                            ),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.monetization_on,
                              title: "Payment, Price, and Title",
                            ),
                            20.h.height,
                            _InputField(
                              prefixIcon: GestureDetector(
                                onTap: () {
                                  showCurrencyPicker(
                                    context: context,
                                    showFlag: true,
                                    showCurrencyName: true,
                                    onSelect: (Currency currency) {
                                      setState(() {
                                        selectedCurrency = currency;
                                      });
                                    },
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    10.width,
                                    Text(
                                      selectedCurrency.symbol,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                              node: priceOfGoodsOrServicesFocusNode,
                              controller: priceOfGoodsOrServicesController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              hintText: "10,000",
                              helperText:
                                  "What is the agreed-upon price for the goods or services?",
                              title: "Price",
                              nextFocusNode:
                                  goodServiceDeliveryAddressFocusNode,
                            ),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.location_city,
                              title: "Possession, Delivery, and Risk",
                            ),
                            _InputField(
                              node: goodServiceDeliveryAddressFocusNode,
                              controller: goodServiceDeliveryAddressController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "When and where will the goods be delivered, or the services be performed?",
                              title: "Delivery Address",
                            ),
                            20.h.height,
                          ],
                        ),
                      ),
                      20.h.height,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onPressed,
                          child: Text(
                            LocaleKeys.continuE.tr(),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
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

class _InputField extends StatelessWidget with ValidationMixin {
  final TextEditingController? controller;
  final String title;
  final FocusNode? nextFocusNode;
  final FocusNode? node;
  final String? helperText;
  final String? hintText;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;

  const _InputField(
      {Key? key,
      required this.title,
      required this.controller,
      this.node,
      this.prefixIcon,
      this.hintText,
      this.helperText,
      this.keyboardType,
      this.nextFocusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(title, style: context.theme.textTheme.titleSmall!),
        ),
        5.h.height,
        SizedBox(
          width: double.infinity,
          child: TextFormField(
            textCapitalization: TextCapitalization.sentences,
            validator: emptyValidation,
            keyboardType: keyboardType ?? TextInputType.text,
            controller: controller,
            focusNode: node,
            onEditingComplete: nextFocusNode != null
                ? () {
                    FocusScope.of(context).requestFocus(nextFocusNode);
                  }
                : null,
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              hintText: hintText,
              errorMaxLines: 2,
              helperText: helperText,
            ),
          ),
        ),
      ],
    );
  }
}

class SegmentHeader extends StatelessWidget {
  final Widget? extraWidget;
  final IconData icon;
  final String title;
  const SegmentHeader(
      {Key? key, this.extraWidget, required this.icon, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon),
              SizedBox(
                width: 5.w,
              ),
              Text(title,
                  style: context.theme.textTheme.titleSmall!
                      .copyWith(fontWeight: FontWeight.bold))
            ],
          ),
          extraWidget ?? const SizedBox()
        ],
      ),
    );
  }
}

class FormDropDown extends StatefulWidget {
  const FormDropDown({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.nextFocusNode,
    required this.title,
    required this.helperText,
    required this.contentList,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;
  final String title;
  final String helperText;
  final List<String> contentList;

  @override
  _FormDropDownState createState() => _FormDropDownState();
}

class _FormDropDownState extends State<FormDropDown> with ValidationMixin {
  String? _selectedTermType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(widget.title,
              style: Theme.of(context).textTheme.titleSmall!),
        ),
        5.h.height,
        DropdownButtonFormField<String>(
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            helperText: widget.helperText,
          ),
          value: _selectedTermType,
          validator: emptyValidation,
          onChanged: (String? newValue) {
            setState(() {
              _selectedTermType = newValue!;
            });
            widget.controller.text = newValue ?? "";

            FocusScope.of(context).requestFocus(widget.nextFocusNode);
          },
          items: widget.contentList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}
