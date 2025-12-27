import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebviewPaymentWave extends StatefulWidget {
  final String url;
  final String client;
  const WebviewPaymentWave({Key? key, required this.url, required this.client}) : super(key: key);

  @override
  State<WebviewPaymentWave> createState() => _WebviewPaymentWave();
}

class _WebviewPaymentWave extends State<WebviewPaymentWave> {
  // A T T R I B U T E S :
  late WebViewController controller;

  // M E T H O D S :
  @override
  void initState() {
    super.initState();

    /*PlatformWebViewControllerCreationParams params = const PlatformWebViewControllerCreationParams();
    params = WebKitWebViewControllerCreationParams
        .fromPlatformWebViewControllerCreationParams(
      params,
    );*/


    //controller = WebViewController.fromPlatformCreationParams(params)
    controller = WebViewController()
    ..platform
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(widget.url),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          }
      );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Paiement ${widget.client}'),
      ),
      body: Center(
        // Ensure the WebView has enough horizontal space (e.g., min 1024px)
        child: Container(
          constraints: const BoxConstraints(minWidth: 1024),
          width: MediaQuery.of(context).size.width > 1024
              ? MediaQuery.of(context).size.width
              : 1024,
          height: MediaQuery.of(context).size.height,
          child: WebViewWidget(controller: controller),
        ),
      )
    );
  }
}