import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kiosk/extensions/title_case_extention.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

enum AgreementType { employee, shareHolder, saleServiceGoods, loan }

Future<File> generatePDF(
    Map<String, dynamic> data, String currency, Uint8List? signature,
    {required AgreementType type}) async {
  var myTheme = pw.ThemeData.withFont(
    base: pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf")),
    bold: pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf")),
    italic:
        pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Italic.ttf")),
    boldItalic: pw.Font.ttf(
        await rootBundle.load("assets/fonts/Roboto-BlackItalic.ttf")),
  );
  final pdf = pw.Document(theme: myTheme);

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
      return pw.Image(image, fit: pw.BoxFit.contain);
    }
    return null;
  }

  Future<pw.Image?> pdfImageFromUrlSig(pw.Document pdf, String url) async {
    final imageBytes = await fetchImageFromUrl(url);
    if (imageBytes != null) {
      final image = pw.MemoryImage(imageBytes);
      return pw.Image(
        image,
        fit: pw.BoxFit.contain,
      );
    }
    return null;
  }

  pw.Image? image;
  pw.Image? imageSignature;

  final imageFuture =
      (data["business_logo"] != null && data["business_logo"] != "")
          ? pdfImageFromUrl(pdf, data["business_logo"])
          : Future.value(null);

  final signatureFuture = (data["signature"] != null && data["signature"] != "")
      ? pdfImageFromUrlSig(pdf, data["signature"])
      : Future.value(null);

  final res = await Future.wait([imageFuture, signatureFuture]);

  image = res[0];
  imageSignature = res[1];

  final logo = pw.Container(
    height: 45,
    width: 45,
    child: image,
  );

  final signature = pw.Container(
    height: 20,
    width: 80,
    child: imageSignature,
  );

  pw.Widget displaySection(String title, String body) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 13,
            ),
          ),
          pw.Text(
            body,
          ),
          pw.SizedBox(height: 10),
        ]);
  }

  pw.Widget shareholder(int index, Map<String, dynamic> data) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 5),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20),
            child: pw.Text("And"),
          ),
          pw.SizedBox(height: 5),
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text("($index)"),
            pw.SizedBox(width: 4),
            pw.Expanded(
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                  pw.Text(
                      '''${data['name'].toString().titleCase}, residing at ${data['address']}(the "Shareholder").'''),
                ])),
          ]),
        ]);
  }

  pw.Widget shareholderInfo(Map<String, dynamic> data) {
    return pw.RichText(
      text: pw.TextSpan(
        text: 'Shareholder, ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        children: [
          pw.TextSpan(
            text: data['name'].toString().titleCase,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.TextSpan(
            text:
                ' holds ${data['share'].toString()} issued common shares of the Company..',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
          ),
        ],
      ),
    );
  }

  pw.Widget buildSharesInfo(String index, String title, String dats) {
    return pw.Padding(
        padding: const pw.EdgeInsets.only(left: 10),
        child:
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("($index)"),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.RichText(
              text: pw.TextSpan(
                text: title,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                children: [
                  pw.TextSpan(
                    text: dats,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ]));
  }

  pw.Widget shareHolderSignature(Map<String, dynamic> data) {
    return pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Shareholder:",
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 13,
            ),
          ),
          pw.Text(
            data["name"],
          ),
          pw.Text(
            data["share"].toString() + " common shares",
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            "Sign here : ___________",
          ),
        ]);
  }

  if (type == AgreementType.loan) {
    pw.Widget buildSharesInfo(String index, String title, String dats) {
      return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 10),
          child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(index),
                pw.SizedBox(width: 4),
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(
                      text: title,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      children: [
                        pw.TextSpan(
                          text: dats,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ),
              ]));
    }

    String percentageToString(String percentage) {
      final numericValue = percentage.split('%').first.trim();
      final numeric = int.tryParse(numericValue);
      if (numeric != null) {
        if (numeric >= 1 && numeric <= 15) {
          final numberWords = [
            'Zero',
            'One',
            'Two',
            'Three',
            'Four',
            'Five',
            'Six',
            'Seven',
            'Eight',
            'Nine',
            'Ten',
            'Eleven',
            'Twelve',
            'Thirteen',
            'Fourteen',
            'Fifteen'
          ];

          return '${numberWords[numeric]} percent';
        }
      }

      return percentage;
    }

    final loanerIsCompany = data["loaner_type"] == "Company";
    final borrowerIsCompany = data["borrower_type"] == "Company";

    final info = [
      {
        'title': "ACKNOWLEDGEMENT OF LOAN ",
        'data':
            "The Lender agrees to lend the Borrower the sum of ${data['amount']} on ${data['date_of_execution']}."
      },
      {
        'title': "REPAYMENT ",
        'data':
            "The Borrower shall repay the loan to the Lender in ${data['payment_frequency'].toString().toLowerCase()} instalment of ${data['amount_of_each_payment']}, the first of such installment commencing on , ${data['first_payment_date']} until the loan is paid in full."
      },
      if (data['interest_name'].toString().isNotEmpty)
        {
          'title': "INTEREST ",
          'data':
              "The loan will bear an annual interest rate of ${data['interest_name']} (${percentageToString(data['interest_name'])}). Interest shall be calculated annually on the basis of a 360 day year and actual days elapsed."
        },
      {
        'title': "DEFAULT BY BORROWER ",
        'data':
            "A default will be considered to have occurred if the Borrower fails to make any repayment by the due date. Upon default, the Lender has the right to demand immediate repayment of the entire outstanding loan and any interest accrued."
      },
      {
        'title': "WHOLE AGREEMENT ",
        'data':
            "This Agreement supersedes any prior agreement between the Lender and the Borrower whether written or oral and any such prior agreements are cancelled as at the commencement date but without prejudice to any rights which have already accrued to either of the parties."
      },
      if ((data['asset'].toString().trim().isNotEmpty && data['asset'] != null))
        {
          'title': "SECURITY ",
          'data':
              "As security for the repayment of the loan, the Borrower shall pledge its ${data['asset']} located at ${data['asset_location']}."
        },
      {
        'title': "GOVERNING LAW ",
        'data':
            "This Agreement shall be governed by and construed in accordance with the laws of ${data['lender_country']}."
      },
    ];

    pdf.addPage(
      pw.MultiPage(
        footer: (context) {
          return pw.SizedBox(
            width: double.infinity,
            child: pw.Text(
              "Generated by the Kroon Kiosk Mobile Application. All Rights Reserved - Blekie Technologies Limited ${DateTime.now().year}.",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          );
        },
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Stack(
            children: [
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      data["lender_name"].toString().toUpperCase(),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      "LOAN AGREEMENT",
                      style: const pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Positioned(child: logo, top: 0, left: 0)
            ],
          ),
          pw.Container(
            width: double.infinity,
            margin: const pw.EdgeInsets.only(bottom: 10, top: 15),
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                    '''THIS AGREEMENT is made on this ${data["formatted_date"]}.''',
                    style: const pw.TextStyle()),
                pw.Text("BETWEEN", style: const pw.TextStyle()),
                pw.SizedBox(height: 10),
                pw.RichText(
                  text: pw.TextSpan(
                    text: data["lender_name"] + ", ",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: [
                      pw.TextSpan(
                        text: (loanerIsCompany
                                ? "a company incorporated under the laws of the ${data["lender_country"]} with its registered office at"
                                : "an individual residing at") +
                            " ${data["lender_address"]} ('the Lender'),",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text("AND", style: const pw.TextStyle()),
                pw.SizedBox(height: 10),
                pw.RichText(
                  text: pw.TextSpan(
                    text: data["borrower_name"] + ", ",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: [
                      pw.TextSpan(
                        text: (borrowerIsCompany
                                ? "a company incorporated under the laws of the ${data["lender_country"]} with its registered office at"
                                : "residing at") +
                            " ${data["borrower_address"]} ('the Borrower').",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                for (int i = 0; i < info.length; i++)
                  buildSharesInfo("${i + 1}.", info[i]['title'].toString(),
                      info[i]['data'].toString()),
                pw.SizedBox(height: 10),
                pw.SizedBox(height: 10),
                pw.Wrap(spacing: 5, children: [
                  pw.SizedBox(
                    width: 150,
                    height: 100,
                    child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "The Lender:",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          pw.Text(
                            data["lender_name"],
                          ),
                          pw.Text(
                            "By: " + data["lender_name"],
                          ),
                          pw.Text(
                            "Title: Owner",
                          ),
                          pw.SizedBox(height: 10),
                          pw.Stack(children: [
                            pw.SizedBox(height: 25, width: double.infinity),
                            pw.Text(
                              "Sign here : ___________",
                            ),
                            if (imageSignature != null)
                              pw.Positioned(left: 70, child: signature)
                          ])
                        ]),
                  ),
                  pw.SizedBox(
                    width: 150,
                    height: 100,
                    child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "The Borrower:",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          pw.Text(
                            data["borrower_name"],
                          ),
                          pw.Text(
                            "",
                          ),
                          pw.Text(
                            "",
                          ),
                          pw.SizedBox(height: 10),
                          pw.Stack(children: [
                            pw.SizedBox(height: 25, width: double.infinity),
                            pw.Text(
                              "Sign here : ___________",
                            ),
                          ])
                        ]),
                  ),
                ])
              ],
            ),
          ),
        ],
      ),
    );
  }

  if (type == AgreementType.saleServiceGoods) {
    pw.Widget buildSharesInfo(String index, String title, String dats) {
      return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 10),
          child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(index),
                pw.SizedBox(width: 4),
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(
                      text: title,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      children: [
                        pw.TextSpan(
                          text: dats,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ),
              ]));
    }

    final isServices = data["type"] == "Services";
    final sellerIsCompany = data["seller_type"] == "Company";
    final buyerIsCompany = data["buyer_type"] == "Company";

    pdf.addPage(
      pw.MultiPage(
        footer: (context) {
          return pw.SizedBox(
            width: double.infinity,
            child: pw.Text(
              "Generated by the Kroon Kiosk Mobile Application. All Rights Reserved - Blekie Technologies Limited ${DateTime.now().year}.",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          );
        },
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Stack(
            children: [
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      data["seller_name"].toString().toUpperCase(),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      isServices
                          ? "SERVICES SUPPLY AGREEMENT"
                          : "SALE OF GOODS AGREEMENT",
                      style: const pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Positioned(child: logo, top: 0, left: 0)
            ],
          ),
          pw.Container(
            width: double.infinity,
            margin: const pw.EdgeInsets.only(bottom: 10, top: 15),
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                    '''THIS AGREEMENT is made on this ${data["formatted_date"]}.''',
                    style: const pw.TextStyle()),
                pw.Text("BETWEEN", style: const pw.TextStyle()),
                pw.SizedBox(height: 10),
                pw.RichText(
                  text: pw.TextSpan(
                    text: data["seller_name"] + ", ",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: [
                      pw.TextSpan(
                        text: (sellerIsCompany
                                ? "a company incorporated under the laws of the ${data["seller_country"]} and having its registered office at"
                                : "an individual residing at") +
                            "${data["seller_address"]} (hereinafter referred to as 'the Seller'),",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text("AND", style: const pw.TextStyle()),
                pw.SizedBox(height: 10),
                pw.RichText(
                  text: pw.TextSpan(
                    text: data["buyer_name"] + ", ",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: [
                      pw.TextSpan(
                        text: (buyerIsCompany
                                ? "a company incorporated under the laws of the ${data["buyer_country"]} and having its registered office at"
                                : "an individual residing at") +
                            "${data["buyer_address"]} (hereinafter referred to as 'the Buyer').",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                if (isServices) ...[
                  buildSharesInfo("1.", "SALE AND PURCHASE ",
                      "The Seller agrees to render services, and the Buyer agrees to pay for ${data['product_name']}. (Example ; The Seller agrees to render services, and the Buyer agrees to pay for Photography Services)."),
                  buildSharesInfo("2.", "PAYMENT, PRICE, AND TITLE ",
                      "The agreed-upon price for the services is ${data['price_of_good_and_service']}."),
                  pw.SizedBox(height: 10),
                  pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 25),
                      child: pw.Text(
                          "50% of the agreed price will be paid before the commencement of the service delivery and the remaining 50% to be paid at the completion of the services rendered.")),
                  pw.SizedBox(height: 10),
                  buildSharesInfo("3.", "WARRANTIES ",
                      "The Seller warrants that it is equipped and skilled to deliver the services."),
                  buildSharesInfo("4.", "ACKNOWLEDGEMENTS BY BUYER ",
                      "The Buyer acknowledges that it has had the opportunity to satisfy itself of the services to be rendered by the seller."),
                  buildSharesInfo("5.", "POSSESSION, DELIVERY, AND RISK ",
                      "Delivery of the services will be at  ${data['delivery_address']}."),
                  buildSharesInfo("6.", "DEFAULT: ",
                      "If the Buyer fails to pay the price on the due date, the Seller may terminate this Agreement and retain any amounts paid by the Buyer to date."),
                  buildSharesInfo("7.", "WHOLE AGREEMENT ",
                      "This Agreement contains the whole agreement between the Seller and the Buyer relating to the sale of services."),
                  buildSharesInfo("8.", "GOVERNING LAW: ",
                      "This Agreement shall be governed by and construed in accordance with the laws of  ${data['seller_country']}."),
                ],
                if (!isServices) ...[
                  buildSharesInfo("1.", "SALE AND PURCHASE ",
                      "The Seller agrees to sell, and the Buyer agrees to buy ${data['product_quantity']} of ${data['product_name']}."),
                  buildSharesInfo("2.", "PAYMENT, PRICE, AND TITLE ",
                      "The agreed-upon price for the goods is ${data['price_of_good_and_service']}. Payment will be made in full upon receipt of goods. Title to the goods passes to the Buyer upon receipt of payment in full."),
                  buildSharesInfo("3.", "WARRANTIES ",
                      "The Seller warrants that the goods are free from any lien or encumbrances and confirms that it has the full right to sell the goods."),
                  buildSharesInfo("4.", "ACKNOWLEDGEMENTS BY BUYER ",
                      "The Buyer acknowledges that it has had the opportunity to inspect the goods, and accepts the goods 'as is'"),
                  buildSharesInfo("5.", "POSSESSION, DELIVERY, AND RISK ",
                      "Delivery of the goods will be at ${data['delivery_address']}. Risk of loss or damage to the goods passes to the Buyer upon delivery."),
                  buildSharesInfo("6.", "DEFAULT: ",
                      "If the Buyer fails to pay the price on the due date, the Seller may terminate this Agreement and retain any amounts paid by the Buyer to date."),
                  buildSharesInfo("7.", "WHOLE AGREEMENT ",
                      "This Agreement contains the whole agreement between the Seller and the Buyer relating to the sale and purchase of the goods."),
                  buildSharesInfo("8.", "GOVERNING LAW: ",
                      "This Agreement shall be governed by and construed in accordance with the laws of  ${data['seller_country']}."),
                ],
                pw.SizedBox(height: 10),
                pw.SizedBox(height: 10),
                pw.Wrap(spacing: 5, children: [
                  pw.SizedBox(
                    width: 150,
                    height: 100,
                    child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "The Seller:",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          pw.Text(
                            data["seller_name"],
                          ),
                          pw.Text(
                            "By: " + data["seller_name"],
                          ),
                          pw.Text(
                            "Title: Owner",
                          ),
                          pw.SizedBox(height: 10),
                          pw.Stack(children: [
                            pw.SizedBox(height: 25, width: double.infinity),
                            pw.Text(
                              "Sign here : ___________",
                            ),
                            if (signature != null)
                              pw.Positioned(
                                left: 70,
                                child: signature,
                              )
                          ])
                        ]),
                  ),
                  pw.SizedBox(
                    width: 150,
                    height: 100,
                    child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "The Buyer:",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          pw.Text(
                            data["buyer_name"],
                          ),
                          pw.Text(
                            "",
                          ),
                          pw.Text(
                            "",
                          ),
                          pw.SizedBox(height: 10),
                          pw.Stack(children: [
                            pw.SizedBox(height: 25, width: double.infinity),
                            pw.Text(
                              "Sign here : ___________",
                            ),
                          ])
                        ]),
                  ),
                ])
              ],
            ),
          ),
        ],
      ),
    );
  }

  if (type == AgreementType.shareHolder) {
    final nonCompete = data["non_compete_period"].toString().isNotEmpty;

    int calculateTotalShares(List<dynamic> shareHolders) {
      int totalShares = 0;
      for (var shareHolder in shareHolders) {
        int shares = int.tryParse(shareHolder['share'] ?? '') ?? 0;
        totalShares += shares;
      }
      return totalShares;
    }

    int calculateTotalSharesPercent(String shareHolderShares) {
      final companyShares = int.tryParse(data["company_share"] ?? '0') ?? 0;
      final shareHolderShare = int.tryParse(shareHolderShares) ?? 0;

      final double percentage = (shareHolderShare / companyShares) * 100;
      final int roundedPercentage = percentage.round();

      return roundedPercentage;
    }

    pdf.addPage(
      pw.MultiPage(
        footer: (context) {
          return pw.SizedBox(
            width: double.infinity,
            child: pw.Text(
              "Generated by the Kroon Kiosk Mobile Application. All Rights Reserved - Blekie Technologies Limited ${DateTime.now().year}.",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          );
        },
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Stack(
            children: [
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      data["company_name"].toString().toUpperCase(),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      "SHAREHOLDER AGREEMENT",
                      style: const pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Positioned(child: logo, top: 0, left: 0)
            ],
          ),
          pw.Container(
            width: double.infinity,
            margin: const pw.EdgeInsets.only(bottom: 10, top: 15),
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                    "SHAREHOLDER'S AGREEMENT (${(data["share_holders"] as List).length} Shareholder)",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    '''THIS AGREEMENT is made on this ${data["formatted_date"]}.''',
                    style: const pw.TextStyle()),
                pw.Text("BETWEEN", style: const pw.TextStyle()),
                pw.SizedBox(height: 10),
                pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("(1)"),
                              pw.SizedBox(width: 4),
                              pw.Expanded(
                                child: pw.Text(
                                    '''${data["company_name"]}, a company incorporated and existing under the laws of ${data["company_country"]}(the "Company").'''),
                              ),
                            ]),
                        for (var x in (data["share_holders"] as List))
                          shareholder(
                              (data["share_holders"] as List).indexOf(x) + 2, x)
                      ],
                    )),
                pw.SizedBox(height: 10),
                pw.Text("WHEREAS", style: const pw.TextStyle()),
                pw.SizedBox(height: 10),
                pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("(A)"),
                              pw.SizedBox(width: 4),
                              pw.Expanded(
                                child: pw.Text(
                                    '''The Company is incorporated with an authorized share capital of ${data["company_share"]} common shares of which ${data["company_share"]} are issued and outstanding.'''),
                              ),
                            ]),
                        pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("(B)"),
                              pw.SizedBox(width: 4),
                              pw.Expanded(
                                child: pw.Text(
                                    '''The Shareholders are the registered and beneficial owners of ${calculateTotalShares(data["share_holders"])} common shares in the capital of the company'''),
                              ),
                            ]),
                      ],
                    )),
                pw.SizedBox(height: 10),
                pw.Text("IT IS AGREED as follows:",
                    style: const pw.TextStyle()),
                pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("(1)"),
                              pw.SizedBox(width: 4),
                              pw.Expanded(
                                  child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                    pw.RichText(
                                      text: pw.TextSpan(
                                        text: 'SHARE OWNERSHIP:',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold),
                                        children: [
                                          pw.TextSpan(
                                            text:
                                                'The Shareholders owns ${calculateTotalShares(data["share_holders"])} shares, representing ${calculateTotalSharesPercent(calculateTotalShares(data["share_holders"]).toString())}% of the total issued and outstanding shares of the Company.',
                                            style: pw.TextStyle(
                                                fontWeight:
                                                    pw.FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if ((data["share_holders"] as List).length >
                                        1) ...[
                                      pw.SizedBox(height: 5),
                                      for (var x
                                          in (data["share_holders"] as List))
                                        shareholderInfo(x),
                                      pw.SizedBox(height: 5),
                                    ]
                                  ])),
                            ]),
                      ],
                    )),
                buildSharesInfo("2", "DIVIDEND POLICY: ",
                    "Dividends will be distributed annually or by resolution of the board of directors of the company, at a rate agreed to by the board of the company in writing, should there be an income available."),
                buildSharesInfo("3", "MANAGEMENT AND VOTING: ",
                    "The Board of Directors shall consist of at least two members, one of whom shall be a Shareholder. Decisions shall be made by a simple majority vote."),
                buildSharesInfo("4", "TRANSFER OF SHARES: ",
                    "The Shareholder agrees that any sale or transfer of shares will be offered to the Company before being offered to a third party."),
                buildSharesInfo("5", "DISPUTE RESOLUTION: ",
                    " Any dispute arising out of this agreement will be resolved through mediation in ${data["company_country"]}."),
                buildSharesInfo("6", "CONFIDENTIALITY: ",
                    "The Shareholder agrees to keep all confidential information about the Company private and not disclose it to third parties."),
                if (nonCompete)
                  buildSharesInfo("7", "NON-COMPETE CLAUSE: ",
                      "The Shareholder agrees not to engage in any business activities that directly compete with the Company for a period of ${data["non_compete_period"].toString().toLowerCase()} after leaving the Company."),
                buildSharesInfo(nonCompete ? "8" : "7", "EXIT STRATEGY: ",
                    " Upon deciding to leave the Company, the Shareholder will sell his shares back to the Company or to an agreed third party."),
                buildSharesInfo(nonCompete ? "9" : "8", "GOVERNING LAW: ",
                    " This agreement is governed by the laws of  ${data["company_country"]}."),
                pw.SizedBox(height: 10),
                pw.Text(
                    '''The parties hereto have executed this Employment Agreement as of the day and year first above written.''',
                    style: const pw.TextStyle()),
                pw.SizedBox(height: 10),
                pw.Wrap(spacing: 5, children: [
                  pw.SizedBox(
                    width: 150,
                    height: 100,
                    child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "COMPANY:",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          pw.Text(
                            data["company_name"].toString().toUpperCase(),
                          ),
                          pw.Text(
                            "By: " + data["company_name"],
                          ),
                          pw.Text(
                            "Title: Owner",
                          ),
                          pw.SizedBox(height: 10),
                          pw.Stack(children: [
                            pw.SizedBox(height: 25, width: double.infinity),
                            pw.Text(
                              "Sign here : ___________",
                            ),
                            if (imageSignature != null)
                              pw.Positioned(left: 70, child: signature)
                          ])
                        ]),
                  ),
                  for (var x in (data["share_holders"] as List))
                    shareHolderSignature(x)
                ])
              ],
            ),
          ),
        ],
      ),
    );
  }

  if (type == AgreementType.employee) {
    pdf.addPage(
      pw.MultiPage(
        footer: (context) {
          return pw.SizedBox(
            width: double.infinity,
            child: pw.Text(
              "Generated by the Kroon Kiosk Mobile Application. All Rights Reserved - Blekie Technologies Limited ${DateTime.now().year}.",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          );
        },
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Stack(
            children: [
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      data["business_name"].toString().toUpperCase(),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      "EMPLOYMENT AGREEMENT",
                      style: const pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Positioned(child: logo, top: 0, left: 0)
            ],
          ),
          pw.Container(
            width: double.infinity,
            margin: const pw.EdgeInsets.only(bottom: 10, top: 15),
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                    '''THIS AGREEMENT is made and entered into this ${data["formatted_date"]} (the "Effective Date"), by and between ${data["business_name"].toString().toUpperCase()}, a business organized under the laws of ${data["business_country"]}, with its principal place business at ${data["business_address"]},(the "Company"), and ${data["employee_name"]}, residing at ${data["employee_address"]} (the "Employee").''',
                    style: const pw.TextStyle()),
                pw.SizedBox(height: 10),
                displaySection("SECTION 1 - EMPLOYMENT",
                    '''The Company hereby employs Employee, and the Employee hereby accepts such employment, upon the terms and conditions herein contained. The Employee will serve in the position of ${data["employee_position"]}.'''),
                displaySection("SECTION 2 - TERM OF EMPLOYMENT",
                    '''The term of employment of Employee by the Company under this Agreement shall be of ${data["employee_end_date"].toString().isEmpty ? "permanent" : "fixed"} nature,${data["employee_end_date"].toString().isEmpty ? "commencing on the Effective Date, and shall continue until terminated in accordance with this Agreement or at a fixed date." : "commencing on the Effective Date, and shall continue until terminated in accordance with this Agreement at ${data["employee_end_date"]}."} '''),
                displaySection("SECTION 3 - COMPENSATION",
                    '''As full compensation for all services provided the Employee shall receive a salary of ${(data["employee_salary"])} payable in ${data["payment_frequency"]} installment.'''),
                displaySection("SECTION 4 - DUTIES AND RESPONSIBILITIES",
                    '''The Employee shall devote his full working time, attention, and energies to the Company during his employment, and shall not, during the term of this Agreement, be engaged in any other business activity. The Employee's main duties will include  ${data["employee_responsibilities"]}.'''),
                displaySection("SECTION 5 - HOURS OF WORK",
                    '''The Employee's normal hours of work will be from ${data["weekly_hours"]}, Monday through Friday, including an hour of lunchtime.'''),
                displaySection("SECTION 6 - GOVERNING LAW",
                    '''This Agreement shall be governed by and construed in accordance with the laws of ${data["business_country"]}.'''),
                pw.Text(
                    '''The parties hereto have executed this Employment Agreement as of the day and year first above written.''',
                    style: const pw.TextStyle()),
                pw.SizedBox(height: 10),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "COMPANY:",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      pw.Text(
                        data["business_name"].toString().toUpperCase(),
                      ),
                      pw.Text(
                        "By: " + data["business_name"],
                      ),
                      pw.Text(
                        "Title: Owner",
                      ),
                      pw.SizedBox(height: 10),
                      pw.Stack(children: [
                        pw.SizedBox(height: 25, width: double.infinity),
                        pw.Text(
                          "Sign here : ___________",
                        ),
                        if (imageSignature != null)
                          pw.Positioned(left: 70, child: signature)
                      ])
                    ]),
                pw.SizedBox(height: 10),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "EMPLOYEE:",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      pw.Text(
                        data["employee_name"],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        "Sign here : ___________",
                      ),
                    ])
              ],
            ),
          ),
        ],
      ),
    );
  }

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/${data['business_name']}.pdf");
  await file.writeAsBytes(await pdf.save());

  return file;
}
