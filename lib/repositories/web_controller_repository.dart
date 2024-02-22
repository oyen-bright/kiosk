import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyWebViewController {
  final InAppWebViewController? _webViewController;

  MyWebViewController(this._webViewController);

  InAppWebViewController? get webViewController => _webViewController;
}
