import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/user/users_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/cart_product.dart';
import 'package:kiosk/settings.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/utils/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class SaleSuccess extends StatefulWidget {
  final String orderId;
  final String customerToPay;
  final List<ProductCart> cartItem;

  const SaleSuccess({
    Key? key,
    this.orderId = "",
    required this.customerToPay,
    required this.cartItem,
  }) : super(key: key);

  @override
  State<SaleSuccess> createState() => _SaleSuccessState();
}

class _SaleSuccessState extends State<SaleSuccess> {
  Future<bool?> _bindingPrinter() async {
    final result = await SunmiPrinter.bindingPrinter();
    return result;
  }

  bool printerBounded = false;
  late final int paperSize;
  late final String serialNumber;
  late final String printerVersion;

  @override
  void initState() {
    super.initState();

    if (AppSettings.isSunmiDevice) {
      _bindingPrinter().then((bool? isBind) async {
        SunmiPrinter.paperSize().then((int size) {
          paperSize = size;
        });

        SunmiPrinter.printerVersion().then((String version) {
          printerVersion = version;
        });

        SunmiPrinter.serialNumber().then((String serial) {
          serialNumber = serial;
        });

        printerBounded = isBind!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
            decoration: BoxDecoration(
                color: context.theme.canvasColor,
                image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/SuccessBg.png"))),
            child: SafeArea(
                child: FittedBox(
                    child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildCheckImage(),
                  _buildSaleCompleteText(context),
                  _buildSaleSuccessText(context),
                  40.h.height,
                  widget.orderId == "Offline Sale"
                      ? Container()
                      : _buildGenerateInvoiceButton(context),
                  _buildContinueButton(context)
                ],
              ),
            )))));
  }

  Widget _buildCheckImage() {
    return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 50.w,
        ),
        child: Image.asset(
          "assets/images/Check.png",
        ));
  }

  Widget _buildSaleCompleteText(BuildContext context) {
    return Text(
      LocaleKeys.sALECOMPLETE.tr(),
      style: context.theme.textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSaleSuccessText(BuildContext context) {
    return Text(
      LocaleKeys.youHaveSuccessfullyCompletedASale.tr(),
      style: context.theme.textTheme.titleMedium!
          .copyWith(fontWeight: FontWeight.normal),
    );
  }

  Widget _buildGenerateInvoiceButton(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 55.h,
      margin: EdgeInsets.symmetric(horizontal: 25.w, vertical: 5.h),
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        onPressed: () async {
          String qrData = AppSettings.base + "invoice/${widget.orderId}/";

          if (AppSettings.isSunmiDevice && printerBounded) {
            await Util.sunmiPrinterPrintInvoice(
                currentUser: context.read<UserCubit>().state.currentUser!,
                customerToPay: widget.customerToPay.toString(),
                cartItem: widget.cartItem,
                orderId: widget.orderId);
          } else {
            showDialog(
                context: context,
                builder: ((context) => AlertDialog(
                      title: Text(LocaleKeys.scanQRCodeToViewInvoice.tr(),
                          textAlign: TextAlign.center,
                          style:
                              context.theme.textTheme.titleSmall!.copyWith()),
                      content: Container(
                        alignment: Alignment.center,
                        width: 250.w,
                        height: 250.w,
                        color: context.theme.canvasColor,
                        child: QrImage(
                            foregroundColor: context.theme.colorScheme.primary,
                            backgroundColor: context.theme.canvasColor,
                            data: qrData,
                            version: 3,
                            size: 250.w),
                      ),
                    )));
          }
        },
        child: Text(
          LocaleKeys.generateInvoice.tr().toUpperCase(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 55.h,
      margin: EdgeInsets.symmetric(horizontal: 25.w),
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      child: ElevatedButton(
        onPressed: () {
          context.popView();
        },
        child: Text(
          LocaleKeys.continuE.tr().toUpperCase(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
