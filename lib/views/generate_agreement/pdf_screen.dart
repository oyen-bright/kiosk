import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:kiosk/extensions/navigation_extention.dart';
import 'package:kiosk/extensions/snackbar_extention.dart';
import 'package:kiosk/extensions/theme_extention.dart';
import 'package:kiosk/utils/get_currency.dart';
import 'package:kiosk/views/generate_agreement/generate_pdf.dart';
import 'package:kiosk/widgets/.widgets.dart';

class PdfViewScreen extends StatefulWidget {
  const PdfViewScreen({
    required this.data,
    required this.id,
    Key? key,
    required this.type,
  }) : super(key: key);

  final String id;
  final AgreementType type;
  final Map<String, dynamic> data;

  @override
  _PdfViewScreenState createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  String? filePath;
  File? pdfFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Your initialization code here
      getPdfData();
    });
  }

  void sharePdfFile(File pdfFile) async {
    // List<int> pdfBytes = await pdfFile.readAsBytes();
    await FlutterShare.shareFile(
      title: 'Share PDF file',
      filePath: pdfFile.path,
      // bytesOfFile: pdfBytes,
      fileType: 'application/pdf',
    );
  }

  getPdfData() async {
    try {
      final file = await generatePDF(widget.data, getCurrency(context), null,
          type: widget.type);

      setState(() {
        pdfFile = file;
        filePath = file.path;
      });
    } catch (e) {
      context.snackBar(e.toString());
      context.popView();
    }
  }

  late PDFViewController pdfViewController;
  int totalPages = 0;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (filePath == null) {
      return LoadingWidget(
        backgroundColor: context.theme.scaffoldBackgroundColor,
      );
    }

    return Scaffold(
      appBar: customAppBar(context,
          title: widget.id,
          subTitle: widget.type.name,
          showBackArrow: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.share,
                color: context.theme.colorScheme.primary,
              ),
              onPressed: () async {
                sharePdfFile(pdfFile!);
              },
            ),
          ]),
      body: Stack(
        children: [
          PDFView(
            filePath: filePath,
            onViewCreated: (PDFViewController vc) {
              setState(() {
                pdfViewController = vc;
              });
            },
            onRender: (int? pages) {
              setState(() {
                totalPages = pages!;
              });
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                currentPage = page!;
              });
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                color: context.theme.scaffoldBackgroundColor,
                margin: EdgeInsets.symmetric(vertical: 10.h),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Page ${currentPage + 1} of $totalPages",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
