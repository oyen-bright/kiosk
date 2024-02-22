import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:kiosk/utils/.utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<File> generatePDF(
  Map<String, dynamic> data,
  String currency,
) async {
  final pdf = pw.Document();

  Future<Uint8List?> fetchImageFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return null;
    }
  }

  Future<pw.Image?> pdfImageFromUrl(pw.Document pdf, String url) async {
    final imageBytes = await fetchImageFromUrl(url);
    if (imageBytes != null) {
      final image = pw.MemoryImage(imageBytes);
      return pw.Image(image, width: 100, height: 100);
    }
    return null;
  }

  pw.Image? image;
  if (data["business_logo"] != null && data["business_logo"] != "") {
    image = await pdfImageFromUrl(pdf, data["business_logo"]);
  }

  final logo = pw.Container(
    height: 50,
    width: 50,
    child: image,
  );

  // Add a page to the PDF
  pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                    pw.Expanded(
                      child: logo,
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            data["business_name"],
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            "Business Synopsis Report",
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                          pw.Text(
                            data["business_address"],
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          pw.Text(
                            data["business_owner_contact"],
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                          pw.Text(
                            data["business_owner_email"],
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                          pw.Text(
                            data["business_registration_number"] ?? " ",
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ])),
              pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),

              pw.Container(
                child: pw.Table.fromTextArray(
                  context: context,
                  border: const pw.TableBorder(
                    verticalInside:
                        pw.BorderSide(width: 0.5, color: PdfColors.grey),
                    horizontalInside:
                        pw.BorderSide(width: 0.5, color: PdfColors.grey),
                  ),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.center,
                  // cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),

                  headerDecoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(2),
                    color: PdfColors.grey300,
                  ),
                  cellHeight: 20,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                  },
                  headers: ["", ""],
                  data: [
                    [
                      'Business Name :',
                      data["business_name"],
                    ],
                    [
                      'Business Registration Number',
                      data["business_registration_number"],
                    ],
                    [
                      'Business Address',
                      data["business_address"],
                    ],
                    [
                      'Business Contact Number',
                      data["business_contact"],
                    ],
                    [
                      'Owner Name',
                      data["business_owner_name"],
                    ],
                    [
                      'Owner Contact Number',
                      data["business_owner_contact"],
                    ],
                    [
                      'Owner Email Address',
                      data["business_owner_email"],
                    ],
                  ],
                ),
              ),
              pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),

              pw.Text(
                  '${data["business_name"]} is a ${data["business_type"]} with the main focus of the business being in the ${data["business_type"]} industry. The business was established in ${data["year_of_operation"]}, and is currently employing ${data["number_of_employees"]} employees. This Business Synopsis Report is for the period of ${data["period_of_report"]} months with a further projection for a two year period.',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),

              pw.Container(
                child: pw.Table.fromTextArray(
                  context: context,
                  border: const pw.TableBorder(
                    verticalInside:
                        pw.BorderSide(width: 0.5, color: PdfColors.grey),
                    horizontalInside:
                        pw.BorderSide(width: 0.5, color: PdfColors.grey),
                  ),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.center,
                  headerDecoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(2),
                    color: PdfColors.grey300,
                  ),
                  cellHeight: 20,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                  },
                  headers: ["", ""],
                  data: [
                    [
                      'Total Sales for Period',
                      '${amountFormatter(data['total_sales_period']).toString()} ' +
                          currency,
                    ],
                    [
                      'Total Cost of Sales for Period',
                      '${amountFormatter(data['total_cost_of_sales_period']).toString()} ' +
                          currency,
                    ],
                    [
                      'Total Gross Profit for Period',
                      '${amountFormatter(data['total_gross_profits_for_period']).toString()} ' +
                          currency,
                    ],
                  ],
                ),
              ),

              pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
              pw.Text('Expenses',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Padding(padding: const pw.EdgeInsets.only(top: 5)),

              pw.Container(
                child: pw.Table.fromTextArray(
                  context: context,
                  border: const pw.TableBorder(
                    verticalInside:
                        pw.BorderSide(width: 0.5, color: PdfColors.grey),
                    horizontalInside:
                        pw.BorderSide(width: 0.5, color: PdfColors.grey),
                  ),
                  // headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.center,
                  headerDecoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(2),
                    color: PdfColors.grey300,
                  ),
                  cellHeight: 20,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                  },
                  headers: ["", ""],
                  data: [
                    for (var expenses in data["expenses"])
                      [
                        '${expenses["expenses"]} :',
                        '${amountFormatter(expenses['expenses_amount']).toString()} ' +
                            currency,
                      ],
                    [
                      'Total Expenses for Period :',
                      '${amountFormatter(data['total_of_all_above_expenses']).toString()} ' +
                          currency,
                    ],
                    [
                      'Net Profit/Loss :',
                      '${amountFormatter(data['net_profit_loss']).toString()} ' +
                          currency,
                    ],
                  ],
                ),
              ),

              // Add the best and worst sold items
            ]);
      }));

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw
            .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
          pw.Text('Transaction Breakdown',
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Padding(padding: const pw.EdgeInsets.only(top: 5)),
          pw.Container(
            child: pw.Table.fromTextArray(
              context: context,
              border: const pw.TableBorder(
                verticalInside:
                    pw.BorderSide(width: 0.5, color: PdfColors.grey),
                horizontalInside:
                    pw.BorderSide(width: 0.5, color: PdfColors.grey),
              ),
              // headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.center,
              headerDecoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(2),
                color: PdfColors.grey300,
              ),
              cellHeight: 20,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
              },
              headers: [
                'Transaction Type',
                'Value',
                '%',
              ],
              data: [
                [
                  "Cash :",
                  '${amountFormatter(data['cash_sales']).toString()} ' +
                      currency,
                  '${data['cash_sale_pecentage']} ' '%',
                ],
                [
                  'Card :',
                  '${amountFormatter(data['card_sales']).toString()} ' +
                      currency,
                  '${data['card_sale_pecentage']} ' '%',
                ],
                [
                  'Kroon :',
                  '${amountFormatter(data['kroon_sales']).toString()} ' +
                      currency,
                  '${data['kroon_sale_pecentage']} ' '%',
                ],
                [
                  'Mobile Money :',
                  '${amountFormatter(data['mobile_payment_sales']).toString()} ' +
                      currency,
                  '${data['mobile_money_sale_pecentage']} ' '%',
                ],
              ],
            ),
          ),
          pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
          pw.Text('Inventory Breakdown',
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Padding(padding: const pw.EdgeInsets.only(top: 5)),
          pw.Text(
              '${data["business_name"]} is a ${data["business_type"]} selling products and services of the following categories.',
              style: const pw.TextStyle(fontSize: 10)),
          pw.Padding(padding: const pw.EdgeInsets.only(top: 5)),
          for (var category in data["business_category"])
            pw.Text(category['category'],
                style:
                    pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.Padding(padding: const pw.EdgeInsets.only(top: 5)),
          pw.Container(
            child: pw.Table.fromTextArray(
              context: context,
              border: const pw.TableBorder(
                verticalInside:
                    pw.BorderSide(width: 0.5, color: PdfColors.grey),
                horizontalInside:
                    pw.BorderSide(width: 0.5, color: PdfColors.grey),
              ),
              // headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.center,
              headerDecoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(2),
                color: PdfColors.grey300,
              ),
              cellHeight: 20,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
              },
              headers: [
                " ",
                'Item Description',
                'Item Value',
                'Total Sales',
              ],
              data: [
                [
                  "Best Sold Item for Period :",
                  '${data['best_sold_item'][0]["product_name"]} ',
                  '${amountFormatter(data['best_sold_item_price']).toString()} ' +
                      currency,
                  '${amountFormatter(data['total_sold']).toString()} ' +
                      currency,
                ],
                [
                  "Worst Sold Item for Period :",
                  '${data['worst_sold_item'][0]["product_name"]} ',
                  '${amountFormatter(data['worst_sold_item_price']).toString()} ' +
                      currency,
                  '${amountFormatter(data['worst_total_sold']).toString()} ' +
                      currency,
                ],
                [
                  "Top Grossing Item for Period :",
                  '${data['best_sold_item'][0]["product_name"]} ',
                  '${amountFormatter(data['best_sold_item_price']).toString()} ' +
                      currency,
                  '${amountFormatter(data['total_sold']).toString()} ' +
                      currency,
                ],
              ],
            ),
          ),
          pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
          pw.Text('Projections for Business',
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Padding(padding: const pw.EdgeInsets.only(top: 5)),
          pw.Text(
              'Based on businesses with a similar trend as ${data["business_name"]} we project a 15% growth rate in terms of sales over the following two years assuming that expenses and remain reasonably consistent.',
              style: const pw.TextStyle(fontSize: 10)),
          pw.Padding(padding: const pw.EdgeInsets.only(top: 5)),
          pw.Container(
            child: pw.Table.fromTextArray(
              context: context,
              border: const pw.TableBorder(
                verticalInside:
                    pw.BorderSide(width: 0.5, color: PdfColors.grey),
                horizontalInside:
                    pw.BorderSide(width: 0.5, color: PdfColors.grey),
              ),
              // headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.center,
              headerDecoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(2),
                color: PdfColors.grey300,
              ),
              cellHeight: 20,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
              },
              headers: [
                " ",
                'Current',
                'Projection For A Year',
                'Projection For Two Years',
              ],
              data: [
                [
                  "Sales :",
                  '${amountFormatter(data['total_ordered_items_price']).toString()} ' +
                      currency,
                  '${amountFormatter(data['sale_one_year_percentage']).toString()} ' +
                      currency,
                  '${amountFormatter(data['sale_two_year_percentage']).toString()} ' +
                      currency,
                ],
                [
                  "Cost of Sales :",
                  '${amountFormatter(data['total_purchase']).toString()} ' +
                      currency,
                  '${amountFormatter(data['cost_of_sale_per_year']).toString()} ' +
                      currency,
                  '${amountFormatter(data['cost_of_sale_2_years']).toString()} ' +
                      currency,
                ],
                [
                  "Total Expenses :",
                  '${amountFormatter(data['total_of_all_above_expenses']).toString()} ' +
                      currency,
                  '${amountFormatter(data['expensive_for_a_year_per_year']).toString()} ' +
                      currency,
                  '${amountFormatter(data['expensive_for_two_year']).toString()} ' +
                      currency,
                ],
                [
                  "Net Profits/Loss :",
                  '${amountFormatter(data['net_profit']).toString()} ' +
                      currency,
                  '${amountFormatter(data['net_profit_a_year']).toString()} ' +
                      currency,
                  '${amountFormatter(data['net_profit_two_year']).toString()} ' +
                      currency,
                ],
              ],
            ),
          ),
        ]);
      },
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/${data['business_name']}.pdf");
  await file.writeAsBytes(await pdf.save());

  return file;
}
