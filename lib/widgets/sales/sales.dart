import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/models/sales.dart';
import 'package:kiosk/utils/.utils.dart';
import 'package:kiosk/widgets/lable/refund_sale_lable.dart';

class SalesWidget extends StatelessWidget {
  final Sales data;
  final VoidCallback? onTap;

  const SalesWidget({
    Key? key,
    this.onTap,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paymentMethod = data.payment['payment_method'];
    final backgroundColor = paymentMethod == 'card_payment'
        ? const Color.fromRGBO(247, 181, 0, 1)
        : paymentMethod == 'cash_payment'
            ? const Color.fromRGBO(0, 124, 255, 1)
            : paymentMethod == 'mobile_money_payment'
                ? const Color.fromRGBO(202, 94, 232, 1)
                : const Color.fromRGBO(0, 0, 188, 1);
    final type = paymentMethod == 'card_payment'
        ? 'CARD'
        : paymentMethod == 'cash_payment'
            ? 'CASH'
            : paymentMethod == 'mobile_money_payment'
                ? 'MOBILE'
                : 'KROON';
    final date = data.createdDate.substring(0, 10).replaceAll('-', '/');
    final transactionId = data.orderNumber;
    final amount = amountFormatter(data.orderTotal.toDouble());
    final textColor =
        type == 'KROON' ? const Color.fromRGBO(248, 193, 32, 1) : Colors.white;

    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 50.h,
            width: double.infinity,
            child: Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 40.w,
                  width: 40.w,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AutoSizeText(
                    type.toUpperCase(),
                    maxLines: 1,
                    minFontSize: 8,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        width: double.infinity,
                        child: AutoSizeText(
                          transactionId,
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        width: double.infinity,
                        child: AutoSizeText(
                          date,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AutoSizeText(getCurrency(context)),
                const SizedBox(width: 4),
                AutoSizeText(amount),
              ],
            ),
          ),
        ),
        if (data.isRefunded)
          const RefundLable(
            isSale: true,
          )
      ],
    );
  }
}
