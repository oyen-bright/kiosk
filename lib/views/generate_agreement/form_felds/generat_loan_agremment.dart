// ignore_for_file: public_member_api_docs, sort_constructors_first
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

class GenerateLoanAgreement extends StatefulWidget {
  const GenerateLoanAgreement({
    Key? key,
  }) : super(key: key);

  @override
  State<GenerateLoanAgreement> createState() => _GenerateLoanAgreementState();
}

class _GenerateLoanAgreementState extends State<GenerateLoanAgreement> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController borrowerNameController;
  late final TextEditingController lenderNameController;
  late final TextEditingController amountController;
  late final TextEditingController dateOfExecution;
  late final TextEditingController paymentFrequencyController;
  late final TextEditingController firstPaymentDateController;
  late final TextEditingController amountOfEachPaymentController;
  late final TextEditingController interestRateController;
  late final TextEditingController assetController;
  late final TextEditingController lenderAddressController;
  late final TextEditingController borrowerAddressController;
  late final TextEditingController companyOrPersonLoanerController;
  late final TextEditingController companyOrPersonBorrowerController;
  late final TextEditingController lenderCountryController;
  late final TextEditingController assetLocationController;

  late final FocusNode borrowerNameFocusNode;
  late final FocusNode lenderNameFocusNode;
  late final FocusNode amountFocusNode;
  late final FocusNode dateOfExecutionFocusNode;
  late final FocusNode paymentFrequencyFocusNode;
  late final FocusNode buyerCountryFocusNode;
  late final FocusNode firstPaymentDateFocusNode;
  late final FocusNode amountOfEachPaymentFocusNode;
  late final FocusNode interestRateFocusNode;
  late final FocusNode priceOfGoodsOrServicesFocusNode;
  late final FocusNode assetFocusNode;
  late final FocusNode lenderCompanyFocusNode;
  late final FocusNode lenderAddressFocusNode;
  late final FocusNode borrowerAddressFocusNode;
  late final FocusNode companyOrPersonLoanerFocusNode;
  late final FocusNode companyOrPersonBorrowerFocusNode;
  late final FocusNode lenderCountryFocusNode;
  late final FocusNode assetLocationFocusNode;

  @override
  void initState() {
    super.initState();

    context.read<LoadingCubit>().loaded();

    borrowerNameController = TextEditingController();
    lenderNameController = TextEditingController();
    amountController = TextEditingController();
    dateOfExecution = TextEditingController();
    paymentFrequencyController = TextEditingController();
    firstPaymentDateController = TextEditingController();
    amountOfEachPaymentController = TextEditingController();
    interestRateController = TextEditingController();
    assetController = TextEditingController();
    lenderAddressController = TextEditingController();
    borrowerAddressController = TextEditingController();
    companyOrPersonLoanerController = TextEditingController();
    companyOrPersonBorrowerController = TextEditingController();
    lenderCountryController = TextEditingController();
    assetLocationController = TextEditingController();

    dateOfExecution.text = formateDate(DateTime.now());

    borrowerNameFocusNode = FocusNode();
    lenderNameFocusNode = FocusNode();
    amountFocusNode = FocusNode();
    dateOfExecutionFocusNode = FocusNode();
    paymentFrequencyFocusNode = FocusNode();
    buyerCountryFocusNode = FocusNode();
    firstPaymentDateFocusNode = FocusNode();
    amountOfEachPaymentFocusNode = FocusNode();
    interestRateFocusNode = FocusNode();
    priceOfGoodsOrServicesFocusNode = FocusNode();
    assetFocusNode = FocusNode();
    lenderCompanyFocusNode = FocusNode();
    lenderAddressFocusNode = FocusNode();
    borrowerAddressFocusNode = FocusNode();
    companyOrPersonLoanerFocusNode = FocusNode();
    companyOrPersonBorrowerFocusNode = FocusNode();
    lenderCountryFocusNode = FocusNode();
    assetLocationFocusNode = FocusNode();
  }

  @override
  void dispose() {
    borrowerNameController.dispose();
    lenderNameController.dispose();
    amountController.dispose();
    dateOfExecution.dispose();
    paymentFrequencyController.dispose();
    firstPaymentDateController.dispose();
    amountOfEachPaymentController.dispose();
    interestRateController.dispose();
    assetController.dispose();
    lenderAddressController.dispose();
    borrowerAddressController.dispose();
    companyOrPersonLoanerController.dispose();
    companyOrPersonBorrowerController.dispose();
    assetLocationController.dispose();

    borrowerNameFocusNode.dispose();
    lenderNameFocusNode.dispose();
    amountFocusNode.dispose();
    dateOfExecutionFocusNode.dispose();
    paymentFrequencyFocusNode.dispose();
    buyerCountryFocusNode.dispose();
    firstPaymentDateFocusNode.dispose();
    amountOfEachPaymentFocusNode.dispose();
    interestRateFocusNode.dispose();
    priceOfGoodsOrServicesFocusNode.dispose();
    assetFocusNode.dispose();
    lenderCompanyFocusNode.dispose();
    lenderAddressFocusNode.dispose();
    borrowerAddressFocusNode.dispose();
    companyOrPersonLoanerFocusNode.dispose();
    companyOrPersonBorrowerFocusNode.dispose();
    assetLocationFocusNode.dispose();

    super.dispose();
  }

  static DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  final formattedDate2 = DateFormat("d'th day of' MMMM, yyyy").format(now);

  Map<String, String> getFormValues() {
    final formValues = <String, String>{
      'borrowerName': borrowerNameController.text,
      'lenderName': lenderNameController.text,
      'amount': amountController.text,
      'dateOfExecution': dateOfExecution.text,
      'paymentFrequency': paymentFrequencyController.text,
      'firstPaymentDate': firstPaymentDateController.text,
      'amountOfEachPayment': amountOfEachPaymentController.text,
      'interestName': interestRateController.text,
      'asset': assetController.text,
      'assetLocation': assetLocationController.text,
      'lenderAddress': lenderAddressController.text,
      'borrowerAddress': borrowerAddressController.text,
      'loanerType': companyOrPersonLoanerController.text,
      'borrowerType': companyOrPersonBorrowerController.text,
      'lenderCountry': lenderCountryController.text,
      'formattedDate': formattedDate2.toString(),
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
              .generateLoanAgreement(getFormValues(), signature);
          context.read<LoadingCubit>().loaded();
          await successfulDialog(context,
              res: "Loan Agreement Generated Successfully");
          context.popView();
        } catch (e) {
          context.read<LoadingCubit>().loaded();
          anErrorOccurredDialog(context, error: e.toString());
        }
      }
    }
  }

  String formateDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
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
                                    "Please provide detailed information about the Lender, borrower and loan to generate a Loan Agreement.",
                                title: "Generate Loan Agreement"),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.info,
                              title: "Lender Information",
                            ),
                            FormDropDown(
                              title: "Company or Person?",
                              contentList: const ["Company", "Person"],
                              helperText: "Who is Lending?",
                              controller: companyOrPersonLoanerController,
                              nextFocusNode: lenderNameFocusNode,
                              focusNode: companyOrPersonLoanerFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: lenderNameFocusNode,
                              controller: lenderNameController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "What is the full legal name of the lender it can can be company?",
                              title: "Name",
                              nextFocusNode: lenderAddressFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: lenderAddressFocusNode,
                              controller: lenderAddressController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "What is the registered address of the lender?",
                              title: "Lender Address",
                              nextFocusNode: lenderCountryFocusNode,
                            ),
                            20.h.height,
                            CountrySelectionFormField(
                              controller: lenderCountryController,
                              focusNode: lenderCompanyFocusNode,
                              nextFocusNode: amountFocusNode,
                              helperText: "What is the country of the lender?",
                              title: "Country",
                            ),
                            20.h.height,
                            _InputField(
                              node: amountFocusNode,
                              controller: amountController,
                              hintText: "(In Numbers and Words)",
                              keyboardType: TextInputType.text,
                              helperText:
                                  "Please specify the amount of money being lent (In Numbers and Words).",
                              title: "Amount",
                              nextFocusNode: companyOrPersonBorrowerFocusNode,
                            ),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.info,
                              title: "Borrower Information",
                            ),
                            FormDropDown(
                              title: "Company or Person?",
                              contentList: const ["Company", "Person"],
                              helperText: "Who is borrower?",
                              controller: companyOrPersonBorrowerController,
                              nextFocusNode: borrowerNameFocusNode,
                              focusNode: companyOrPersonBorrowerFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: borrowerNameFocusNode,
                              controller: borrowerNameController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "What is the full legal name of the borrower it can can be company?",
                              title: "Name",
                              nextFocusNode: borrowerAddressFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: borrowerAddressFocusNode,
                              controller: borrowerAddressController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "What is the registered address of the borrower?",
                              title: "Borrower Address",
                              nextFocusNode: dateOfExecutionFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: dateOfExecutionFocusNode,
                              controller: dateOfExecution,
                              keyboardType: TextInputType.text,
                              onTap: () async {
                                final date = await datePicker(context,
                                    agreementDate: true);
                                if (date != null) {
                                  context.unFocus();
                                  dateOfExecution.text = formateDate(date);
                                }
                                context.unFocus();
                              },
                              helperText:
                                  "Please provide the date when the loan will be delivered/transferred to the borrower",
                              title: "Date of Execution",
                              nextFocusNode: paymentFrequencyFocusNode,
                            ),
                            20.height,
                            const SegmentHeader(
                              icon: Icons.payment,
                              title: "Repayment Information",
                            ),
                            FormDropDown(
                              title: "Frequency of repayment",
                              contentList: const [
                                "Weekly",
                                "Monthly",
                                "Yearly"
                              ],
                              helperText: "What is the frequency of repayment?",
                              controller: paymentFrequencyController,
                              nextFocusNode: firstPaymentDateFocusNode,
                              focusNode: paymentFrequencyFocusNode,
                            ),
                            20.height,
                            _InputField(
                              node: firstPaymentDateFocusNode,
                              controller: firstPaymentDateController,
                              keyboardType: TextInputType.text,
                              onTap: () async {
                                final date = await datePicker(context,
                                    agreementDate: true);
                                if (date != null) {
                                  firstPaymentDateController.text =
                                      formateDate(date);
                                }
                                context.unFocus();
                              },
                              helperText: "When is the first payment due?",
                              title: "First Payment",
                              nextFocusNode: amountOfEachPaymentFocusNode,
                            ),
                            20.h.height,
                            _InputField(
                              node: amountOfEachPaymentFocusNode,
                              controller: amountOfEachPaymentController,
                              keyboardType: TextInputType.text,
                              hintText: "(In Numbers and Words)",
                              helperText:
                                  "What is the amount of each payment? ",
                              title: "Payment Amount",
                              nextFocusNode: interestRateFocusNode,
                            ),
                            20.height,
                            const SegmentHeader(
                              icon: Icons.percent,
                              title: "Interest Information",
                            ),
                            InterestWidget(
                              controller: interestRateController,
                              focusNode: interestRateFocusNode,
                              nextFocusNode: assetFocusNode,
                            ),
                            20.h.height,
                            AssetsWidget(
                              controller2: assetLocationController,
                              controller: assetController,
                              focusNode: assetFocusNode,
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
  final void Function()? onTap;
  final TextInputType? keyboardType;

  const _InputField(
      {Key? key,
      required this.title,
      required this.controller,
      this.node,
      this.hintText,
      this.helperText,
      this.onTap,
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
            onTap: onTap,
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

class InterestWidget extends StatefulWidget {
  const InterestWidget({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.nextFocusNode,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;

  @override
  _InterestWidgetState createState() => _InterestWidgetState();
}

class _InterestWidgetState extends State<InterestWidget> {
  String? _isInterestRate;

  final FocusNode interestRateFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text("Will the loan bear interest?",
              style: Theme.of(context).textTheme.titleSmall!),
        ),
        5.h.height,
        DropdownButtonFormField<String>(
          focusNode: widget.focusNode,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          value: _isInterestRate,
          onChanged: (String? newValue) {
            setState(() {
              _isInterestRate = newValue!;
            });

            FocusScope.of(context).requestFocus(_isInterestRate == 'Yes'
                ? interestRateFocusNode
                : widget.nextFocusNode);
          },
          items: ['Yes', 'No'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        if (_isInterestRate == 'Yes') ...[
          20.height,
          FormDropDown(
            contentList:
                List.generate(15, (index) => (index + 1).toString() + '%'),
            controller: widget.controller,
            focusNode: interestRateFocusNode,
            nextFocusNode: widget.nextFocusNode,
            title: "Interest rate",
            helperText: "What is the annual interest rate?",
          )
        ]
      ],
    );
  }
}

class AssetsWidget extends StatefulWidget {
  const AssetsWidget({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.controller2,
  }) : super(key: key);

  final TextEditingController controller;
  final TextEditingController controller2;
  final FocusNode focusNode;

  @override
  _AssetsWidgetState createState() => _AssetsWidgetState();
}

class _AssetsWidgetState extends State<AssetsWidget> {
  String? _isInterestRate;

  final FocusNode assetNameFocusNode = FocusNode();
  final FocusNode assetLocationFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text("Will this loan be secured?",
              style: Theme.of(context).textTheme.titleSmall!),
        ),
        5.h.height,
        DropdownButtonFormField<String>(
          focusNode: widget.focusNode,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          value: _isInterestRate,
          onChanged: (String? newValue) {
            setState(() {
              _isInterestRate = newValue!;
            });

            _isInterestRate == 'Yes'
                ? FocusScope.of(context).requestFocus(assetNameFocusNode)
                : context.unFocus();
          },
          items: ['Yes', 'No'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        if (_isInterestRate == 'Yes') ...[
          20.height,
          _InputField(
            node: assetNameFocusNode,
            nextFocusNode: assetLocationFocusNode,
            title: "Asset",
            controller: widget.controller,
            helperText:
                "Please describe the asset(s) that will be used as security for the loan.",
          ),
          20.height,
          _InputField(
            node: assetLocationFocusNode,
            title: "Asset Location",
            controller: widget.controller2,
            helperText:
                "Please describe the asset(s) locations that will be used as security for the loan.",
          )
        ]
      ],
    );
  }
}
