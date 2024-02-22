import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/repositories/user_repository.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/utils.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

//Todo: change design

class BuisnessInfoEdit extends StatefulWidget {
  final Map<String, dynamic> data;
  const BuisnessInfoEdit({Key? key, required this.data}) : super(key: key);

  @override
  State<BuisnessInfoEdit> createState() => _BuisnessInfoEditState();
}

class _BuisnessInfoEditState extends State<BuisnessInfoEdit> {
  final _formkey = GlobalKey<FormState>();
  late final TextEditingController businesName;
  late final TextEditingController businessContactNumber;
  late final TextEditingController businessAddress;
  late final TextEditingController businessRegistrationNumber;

  final contactFocusNode = FocusNode();
  final addressFocusNode = FocusNode();
  final businessRegistrationNumberFocusNode = FocusNode();

  @override
  void initState() {
    businessAddress = TextEditingController();
    businesName = TextEditingController();
    businessContactNumber = TextEditingController();
    businessRegistrationNumber = TextEditingController();

    businesName.text = Util.decodeString(widget.data["business_name"]);
    businessRegistrationNumber.text =
        widget.data["business_registration_number"];
    businessContactNumber.text = widget.data["business_contact_number"];
    businessAddress.text = widget.data["business_address"];
    super.initState();
  }

  @override
  void dispose() {
    businessRegistrationNumber.dispose();
    businesName.dispose();
    businessAddress.dispose();
    businessContactNumber.dispose();
    super.dispose();
  }

  onPressed() async {
    context.unFocus();
    if (_formkey.currentState!.validate()) {
      try {
        context.read<LoadingCubit>().loading(message: "Updating information");
        final response = await context
            .read<UserRepository>()
            .updateBusinessInformation(
                id: widget.data['id'],
                businessRegistrationNumber: businessRegistrationNumber.text,
                businessCategory: widget.data["business_category"],
                businessType: widget.data["business_type"],
                businessName: businesName.text,
                businessContact: businessContactNumber.text,
                businessAddress: businessAddress.text);
        context.read<LoadingCubit>().loaded();
        context.read<UserCubit>().getUserDetails();
        await successfulDialog(context, res: "");
        context.popView(count: 2);
      } catch (e) {
        context.read<LoadingCubit>().loaded();
        anErrorOccurredDialog(context, error: e.toString());
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
              body: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Form(
                    key: _formkey,
                    child: ListView(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 25.w),
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ScreenHeader(
                                  padding: 0,
                                  subTitle: LocaleKeys
                                      .edityourbuisnessinformationhereyoucanedityourbusinessnamebusinessaddressandyourbusinesscontactnumber
                                      .tr(),
                                  title:
                                      LocaleKeys.editBuisnessInformation.tr()),
                              20.h.height,
                              CustomWidget(
                                nextFocusNode: contactFocusNode,
                                controller: businesName,
                                title: LocaleKeys.businessName.tr(),
                              ),
                              20.h.height,
                              CustomWidget(
                                focusNode: contactFocusNode,
                                nextFocusNode: addressFocusNode,
                                controller: businessContactNumber,
                                title: LocaleKeys.businessContactNumber.tr(),
                              ),
                              20.h.height,
                              CustomWidget(
                                focusNode: addressFocusNode,
                                controller: businessAddress,
                                nextFocusNode:
                                    businessRegistrationNumberFocusNode,
                                title: LocaleKeys.businessAddress.tr(),
                              ),
                              20.h.height,
                              CustomWidget(
                                validate: false,
                                focusNode: businessRegistrationNumberFocusNode,
                                controller: businessRegistrationNumber,
                                title:
                                    LocaleKeys.businessRegistrationNumber.tr(),
                              ),
                            ],
                          ),
                        ),
                        20.h.height,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (() => onPressed()),
                            child: Text(
                              LocaleKeys.continuE.tr(),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            Visibility(
              child: const LoadingWidget(),
              visible: isLoading,
            )
          ]),
        );
      },
    );
  }
}

class CustomWidget extends StatelessWidget {
  final String title;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final bool validate;
  final TextEditingController controller;
  const CustomWidget(
      {Key? key,
      this.focusNode,
      this.validate = true,
      this.nextFocusNode,
      required this.controller,
      required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(title, style: Theme.of(context).textTheme.titleSmall!),
        ),
        5.h.height,
        TextFormField(
          onEditingComplete: nextFocusNode != null
              ? () {
                  FocusScope.of(context).requestFocus(nextFocusNode);
                }
              : null,
          validator: validate
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.required.tr();
                  }
                  return null;
                }
              : null,
          focusNode: focusNode,
          textAlignVertical: TextAlignVertical.center,
          controller: controller,
        ),
      ],
    );
  }
}
