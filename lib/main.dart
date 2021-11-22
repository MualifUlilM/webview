import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SINTAS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  String url = "http://siedik.demakkab.go.id/vlama/index.php/auth_desa/";
  bool isLoading = true;
  double? _webViewHeight;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    // add listener to detect orientation change
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    // remove listener
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // on portrait / landscape or other change, recalculate height
    _setWebViewHeight();
  }

  @override
  Widget build(BuildContext context) {
    if (_webViewHeight == null) {
      final initalWebViewHeight = MediaQuery.of(context).size.height;
      print('WebView inital height set to: $initalWebViewHeight');
      _webViewHeight = initalWebViewHeight;
    }
    return Scaffold(
        body: SafeArea(
      child: WillPopScope(
          onWillPop: () async {
            final bool canGoBack =
                await _controller.future.then((c) => c.canGoBack());
            if (canGoBack) {
              _controller.future.then((c) => c.goBack());
              return Future<bool>.value(false);
            }
            return Future<bool>.value(true);
          },
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  await _controller.future.then((c) => c.reload());
                },
                child: SingleChildScrollView(
                  child: Container(
                    height: _webViewHeight,
                    child: WebView(
                      initialUrl: url,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                      onPageStarted: (String url) {
                        setState(() {
                          isLoading = true;
                        });
                      },
                      onProgress: (progress) {
                        print(progress);
                      },
                      onPageFinished: (url) {
                        setState(() {
                          isLoading = false;
                        });
                        print(url);
                        print(isLoading);
                      },
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  // color black with opacity 0.5
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          )),
    ));
  }

  void _setWebViewHeight() {
    // we don't updage if WebView is not ready yet
    // or page load is in progress
    if (_webViewController == null || isLoading) {
      return;
    }
    // execute JavaScript code in the loaded page
    // to get body height
    _webViewController!
        // ignore: deprecated_member_use
        .evaluateJavascript('document.body.clientHeight')
        .then((documentBodyHeight) {
      // set height
      setState(() {
        print('WebView height set to: $documentBodyHeight');
        _webViewHeight = double.parse(documentBodyHeight);
      });
    });
  }
}
