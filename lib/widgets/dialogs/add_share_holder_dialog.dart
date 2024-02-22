import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/extensions/navigation_extention.dart';
import 'package:kiosk/mixins/validation_mixin.dart';
import 'package:kiosk/models/.models.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

Future<ShareHOlder?> showAddShareHolderDialog(BuildContext context,
    {required int maxOption}) async {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _shareController = TextEditingController();
  final _sharePrideController = TextEditingController();
  final _addressFocusNode = FocusNode();
  final _sharesFocusNode = FocusNode();
  final _sharesPriceFocusNode = FocusNode();

  return await showDialog(
    context: context,
    builder: (BuildContext contextA) {
      return AlertDialog(
        scrollable: true,
        title: const Text("Add ShareHolder"),
        content: _Body(
            maxOption: maxOption,
            formKey: _formKey,
            sharePrideController: _sharePrideController,
            sharesPriceFocusNode: _sharesPriceFocusNode,
            addressFocusNode: _addressFocusNode,
            nameController: _nameController,
            sharesFocusNode: _sharesFocusNode,
            addressController: _addressController,
            shareController: _shareController),
        actions: [
          TextButton(
            onPressed: () {
              contextA.popView();
            },
            child: Text(LocaleKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                contextA.popView(
                  value: ShareHOlder(
                    TextEditingController(text: _nameController.text),
                    TextEditingController(text: _addressController.text),
                    TextEditingController(text: _shareController.text),
                    TextEditingController(text: _sharePrideController.text),
                  ),
                );
                _nameController.clear();
                _addressController.clear();
                _shareController.clear();
                _sharePrideController.clear();
              }
            },
            child: Text(LocaleKeys.add.tr()),
          ),
        ],
      );
    },
  );
}

class DropdownTextFormField extends StatefulWidget {
  final int maxOption;
  final FocusNode nextFocusNode;
  final FocusNode focusNode;
  final TextEditingController controller;

  const DropdownTextFormField(
      {Key? key,
      required this.maxOption,
      required this.nextFocusNode,
      required this.focusNode,
      required this.controller})
      : super(key: key);

  @override
  _DropdownTextFormFieldState createState() => _DropdownTextFormFieldState();
}

class _DropdownTextFormFieldState extends State<DropdownTextFormField>
    with ValidationMixin {
  late List<int> options;
  late int incrementValue;
  late int selectedValue;

  @override
  void initState() {
    super.initState();
    incrementValue = widget.maxOption == 100 ? 5 : 50;
    options = List<int>.generate((widget.maxOption / incrementValue).floor(),
        (index) => (index + 1) * incrementValue);
    selectedValue = options[0];
    widget.controller.text = selectedValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      focusNode: widget.focusNode,
      value: selectedValue,
      onChanged: (newValue) {
        widget.controller.text = newValue.toString();
        setState(() {
          selectedValue = newValue!;
        });

        FocusScope.of(context).requestFocus(widget.nextFocusNode);
      },
      validator: emptyValidationInt,
      items: options.map((value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
      decoration: const InputDecoration(
          helperText: "How many shares does this shareholder own ?"),
    );
  }
}

class _Body extends StatelessWidget with ValidationMixin {
  const _Body({
    Key? key,
    required GlobalKey<FormState> formKey,
    required FocusNode addressFocusNode,
    required TextEditingController nameController,
    required FocusNode sharesFocusNode,
    required FocusNode sharesPriceFocusNode,
    required TextEditingController addressController,
    required TextEditingController sharePrideController,
    required TextEditingController shareController,
    required int maxOption,
  })  : _formKey = formKey,
        _addressFocusNode = addressFocusNode,
        _nameController = nameController,
        _sharesFocusNode = sharesFocusNode,
        _addressController = addressController,
        _shareController = shareController,
        _sharesPriceFocusNode = sharesPriceFocusNode,
        _maxOption = maxOption,
        _sharePrideController = sharePrideController,
        super(key: key);

  final GlobalKey<FormState> _formKey;
  final FocusNode _addressFocusNode;
  final TextEditingController _nameController;
  final FocusNode _sharesFocusNode;
  final FocusNode _sharesPriceFocusNode;
  final TextEditingController _addressController;
  final TextEditingController _shareController;
  final TextEditingController _sharePrideController;
  final int _maxOption;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(_addressFocusNode),
            controller: _nameController,
            validator: emptyValidation,
            decoration: const InputDecoration(
                labelText: "ShareHolder Name",
                helperText: "Please provide the legal names of shareholder"),
          ),
          10.h.height,
          TextFormField(
            validator: emptyValidation,
            focusNode: _addressFocusNode,
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(_sharesFocusNode),
            controller: _addressController,
            decoration: const InputDecoration(
                labelText: "ShareHolder Address",
                helperText: "Please provide the legal address of shareholder"),
          ),
          10.h.height,
          DropdownTextFormField(
            controller: _shareController,
            focusNode: _sharesFocusNode,
            nextFocusNode: _sharesPriceFocusNode,
            maxOption: _maxOption,
          ),
          // TextFormField(
          //   validator: emptyValidation,
          //   focusNode: _sharesFocusNode,
          //   controller: _shareController,
          //   onEditingComplete: () =>
          //       FocusScope.of(context).requestFocus(_sharesPriceFocusNode),
          //   decoration: const InputDecoration(
          //     hintText: "100 - 1000",
          //     helperText: "How many shares does this shareholder own ?",
          //   ),
          //   keyboardType: TextInputType.number,
          // ),
          10.h.height,
          TextFormField(
            validator: emptyValidation,
            focusNode: _sharesPriceFocusNode,
            controller: _sharePrideController,
            decoration: const InputDecoration(
              hintText: "200",
              helperText:
                  "What is the price paid for these shares by each shareholder?",
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
