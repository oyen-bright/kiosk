import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kiosk/cubits/.cubits.dart';
import 'package:kiosk/utils/convert_color.dart';
import 'package:kiosk/widgets/.widgets.dart';

class KioskWebView extends StatefulWidget {
  final String url;
  final String title;
  final String? subtitle;

  const KioskWebView(
      {Key? key, required this.url, required this.title, this.subtitle})
      : super(key: key);

  @override
  _KioskWebViewState createState() => _KioskWebViewState();
}

class _KioskWebViewState extends State<KioskWebView> {
  // late InAppWebViewController _webViewController;
  bool _isLoading = true;

  Color? _appBarColor;
  @override
  Widget build(BuildContext context) {
    // final token = context.read<UserServices>().getToken();
    return Scaffold(
      backgroundColor: _appBarColor,
      body: Stack(
        children: [
          SafeArea(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse(widget.url),
                // headers: {
                //   'KOK-Authentication-Token':
                //       dotenv.env["KOK-Authentication-Token"]!,
                //   "Authorization": "Bearer $token['access']",
                // },
              ),
              onScrollChanged:
                  (InAppWebViewController controller, int x, int y) {
                final showNavBar =
                    context.read<ShowBottomNavCubit>().state.showNav;
                if (y > 0 && showNavBar) {
                  context
                      .read<ShowBottomNavCubit>()
                      .toggleShowBottomNav(showNav: false, fromm: "WebView");
                } else if (y <= 0 && !showNavBar) {
                  context
                      .read<ShowBottomNavCubit>()
                      .toggleShowBottomNav(showNav: true, fromm: "WebView");
                }
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    supportZoom: false,
                    disableContextMenu: true,
                    javaScriptEnabled: true,
                    transparentBackground: true),
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                // _webViewController = controller;
              },
              onLoadStart: (InAppWebViewController controller, url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onLoadStop: (InAppWebViewController controller, url) {
                setState(() {
                  _isLoading = false;
                });
                controller
                    .evaluateJavascript(
                        source:
                            "window.getComputedStyle(document.body, null).getPropertyValue('background-color');")
                    .then((value) {
                  if (value != null && value.isNotEmpty) {
                    setState(() {
                      _appBarColor = parseColor(value);
                    });
                  }
                });
                controller.getTitle().then((title) {
                  // setState(() {
                  //   _title = title;
                  // });
                });
              },
            ),
          ),
          Visibility(
            child: const LoadingWidget(),
            visible: _isLoading,
          )
        ],
      ),
      bottomNavigationBar: null,
    );
  }
}
