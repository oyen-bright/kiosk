// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/mixins/validation_mixin.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sizedbox_extention/sizedbox_extention.dart';

import 'components/country_picker.dart';

//Todo: change design

class GenerateShareHolderAgreement extends StatefulWidget {
  const GenerateShareHolderAgreement({
    Key? key,
  }) : super(key: key);

  @override
  State<GenerateShareHolderAgreement> createState() =>
      _GenerateShareHolderAgreementState();
}

class _GenerateShareHolderAgreementState
    extends State<GenerateShareHolderAgreement> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController companyNameController;
  late final TextEditingController companyShareController;
  late final TextEditingController nonCompetePeriodController;
  late final TextEditingController countryController;

  late final FocusNode companyNameFocusNode;
  late final FocusNode companyShareFocusNode;
  late final FocusNode nonCompeteControllerFocusNode;
  late final FocusNode countryFocusNode;

  final List<ShareHOlder> _shareHolders = [];

  @override
  void initState() {
    companyNameController = TextEditingController();
    companyShareController = TextEditingController();
    nonCompetePeriodController = TextEditingController();
    countryController = TextEditingController();
    companyNameFocusNode = FocusNode();
    companyShareFocusNode = FocusNode();
    nonCompeteControllerFocusNode = FocusNode();
    countryFocusNode = FocusNode();

    // getCategories();
    super.initState();

    context.read<LoadingCubit>().loaded();
  }

  @override
  void dispose() {
    companyNameController.dispose();
    companyShareController.dispose();
    nonCompetePeriodController.dispose();

    companyNameFocusNode.dispose();
    companyShareFocusNode.dispose();
    nonCompeteControllerFocusNode.dispose();
    countryFocusNode.dispose();

    super.dispose();
  }

  Map<String, dynamic> getFormValues() {
    DateTime now = DateTime.now();
    final formattedDate2 = DateFormat("d'th day of' MMMM, yyyy").format(now);
    final currentUser = context.read<UserCubit>().state.currentUser;
    final ownerName = currentUser?.name ?? '';

    final formValues = <String, dynamic>{
      'companyName': companyNameController.text,
      'companyCountry': countryController.text,
      'companyShares': companyShareController.text,
      'formattedDate': formattedDate2.toString(),
      'ownerName': ownerName,
      'non_compete_period': nonCompetePeriodController.text,
      'share_holder': _shareHolders
          .map((e) => {
                'name': e.nameController.text,
                'address': e.addressController.text,
                'share': e.shareController.text,
                'share_price': e.sharePriceController.text,
              })
          .toList(),
    };

    return formValues;
  }

  onPressed() async {
    context.unFocus();
    if (_formKey.currentState!.validate()) {
      if (_shareHolders.isEmpty) {
        anErrorOccurredDialog(context,
            error: "Please add at least one shareholder");
      } else {
        final userSignature = await showSignaturePad(context);

        if (userSignature != null) {
          final dir = await path_provider.getTemporaryDirectory();
          final targetPath = dir.absolute.path;

          final signature = convertUint8ListToFile(
              userSignature, targetPath + "/signature${generateNumber()}.jpg");
          try {
            context.read<LoadingCubit>().loading(message: "");

            await context
                .read<UserRepository>()
                .generateShareAgreement(getFormValues(), signature);
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
                                    "Please provide detailed information about the company, it's shareholding and shareholders to generate your Shareholder Agreement.",
                                title: "Generate Shareholder Agreement"),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.business,
                              title: "Company Details",
                            ),
                            _InputField(
                              node: companyNameFocusNode,
                              controller: companyNameController,
                              keyboardType: TextInputType.text,
                              helperText:
                                  "Please provide the legal name of the company?",
                              title: "Company Name",
                              nextFocusNode: countryFocusNode,
                            ),
                            20.h.height,
                            CountrySelectionFormField(
                              controller: countryController,
                              nextFocusNode: companyShareFocusNode,
                              focusNode: countryFocusNode,
                              helperText:
                                  "In which country is your business based?",
                              title: "Business Country",
                            ),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.monetization_on,
                              title: "Shares Details",
                            ),
                            DropdownTextFormField(
                                title: "Company Shares",
                                focusNode: companyShareFocusNode,
                                controller: companyShareController,
                                helperText:
                                    "How many shares does the company have?"),
                            20.h.height,
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  if (_shareHolders.isEmpty)
                                    SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          "To add shareholder to agreement click on the add shareholder button and follow the prompt",
                                          style: context
                                              .theme.textTheme.titleSmall,
                                        )),
                                  if (_shareHolders.isNotEmpty)
                                    for (var shareHolder in _shareHolders)
                                      Column(
                                        children: [
                                          _InputField(
                                            helperText: LocaleKeys.monthly.tr(),
                                            node: null,
                                            validator: emptyValidation,
                                            hintText:
                                                "Please provide the legal names shareholder",
                                            controller:
                                                shareHolder.nameController,
                                            title:
                                                "${_shareHolders.indexOf(shareHolder) + 1} : Share Holder Name",
                                          ),
                                          20.h.height,
                                          _InputField(
                                            helperText:
                                                "address of the share holder?",
                                            node: null,
                                            validator: emptyValidation,
                                            controller:
                                                shareHolder.addressController,
                                            title: "Share Holder Address",
                                          ),
                                          20.h.height,
                                          _InputField(
                                            keyboardType: TextInputType.number,
                                            helperText:
                                                "How many shares does shareholder own?",
                                            node: null,
                                            validator: emptyValidation,
                                            controller:
                                                shareHolder.shareController,
                                            title: "Share Holder Share",
                                          ),
                                          20.h.height,
                                          _InputField(
                                            helperText:
                                                "What is the price paid for these shares by shareholder?",
                                            node: null,
                                            hintText: "\$1",
                                            validator: emptyValidation,
                                            controller: shareHolder
                                                .sharePriceController,
                                            title: "Share Price",
                                          ),
                                          20.h.height,
                                        ],
                                      ),
                                  SizedBox(
                                      width: double.infinity,
                                      child: TextButton(
                                        onPressed: () async {
                                          final response =
                                              await showAddShareHolderDialog(
                                                  context,
                                                  maxOption: int.parse(
                                                      companyShareController
                                                          .text));
                                          if (response != null) {
                                            setState(() {
                                              _shareHolders.add(response);
                                            });
                                          }
                                        },
                                        child: const Text("Add ShareHolder"),
                                      ))
                                ],
                              ),
                            ),
                            20.h.height,
                            const SegmentHeader(
                              icon: Icons.document_scanner,
                              title: "Clause",
                            ),
                            NonCompeteTermWidget(
                              focusNode: nonCompeteControllerFocusNode,
                              controller: nonCompetePeriodController,
                            ),
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

class _InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String title;
  final FocusNode? nextFocusNode;
  final FocusNode? node;
  final String? helperText;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _InputField(
      {Key? key,
      required this.title,
      this.validator,
      required this.controller,
      this.node,
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
            validator: validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.required.tr();
                  }
                  return null;
                },
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

class NonCompeteTermWidget extends StatefulWidget {
  const NonCompeteTermWidget({
    Key? key,
    required this.controller,
    required this.focusNode,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  _NonCompeteTermWidgetState createState() => _NonCompeteTermWidgetState();
}

class _NonCompeteTermWidgetState extends State<NonCompeteTermWidget> {
  String _selectedTermType = 'No';

  final FocusNode endDateFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text("Add Non-Compete Clause?",
              style: Theme.of(context).textTheme.titleSmall!),
        ),
        5.h.height,
        DropdownButtonFormField<String>(
          focusNode: widget.focusNode,
          decoration: const InputDecoration(
            helperText:
                "Will shareholders be restricted from participating in businesses that directly compete with the corporation?",
            border: OutlineInputBorder(),
          ),
          value: _selectedTermType,
          onChanged: (String? newValue) {
            setState(() {
              _selectedTermType = newValue!;
            });
            if (_selectedTermType == 'Yes') {
              FocusScope.of(context).requestFocus(endDateFocusNode);
            }
          },
          items: ['No', 'Yes'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        if (_selectedTermType == 'Yes') ...[
          20.height,
          _InputField(
            node: endDateFocusNode,
            hintText: "two years",
            nextFocusNode: widget.focusNode,
            controller: widget.controller,
            title: "Period",
            helperText: "please specify the years.",
          )
        ]
      ],
    );
  }
}

class DropdownTextFormField extends StatefulWidget {
  const DropdownTextFormField(
      {Key? key,
      required this.controller,
      required this.focusNode,
      this.helperText,
      this.hintText,
      required this.title})
      : super(key: key);
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? helperText;
  final String? hintText;
  final String title;

  @override
  _DropdownTextFormFieldState createState() => _DropdownTextFormFieldState();
}

class _DropdownTextFormFieldState extends State<DropdownTextFormField>
    with ValidationMixin {
  final List<int> options = [100, 1000];
  int? selectedValue = 100;

  @override
  void initState() {
    super.initState();
    widget.controller.text = selectedValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(widget.title,
              style: Theme.of(context).textTheme.titleSmall!),
        ),
        5.h.height,
        DropdownButtonFormField<int>(
          value: selectedValue,
          validator: emptyValidationInt,
          onChanged: (newValue) {
            widget.controller.text = newValue.toString();

            setState(() {
              selectedValue = newValue!;
            });
            context.unFocus();
          },
          items: options.map((value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(value.toString()),
            );
          }).toList(),
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorMaxLines: 2,
            helperText: widget.helperText,
          ),
        ),
      ],
    );
  }
}
