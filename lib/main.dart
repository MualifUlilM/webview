import 'dart:async';
import 'dart:convert';

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
  String? url;
  bool isLoading = true;
  double? _webViewHeight;

  @override
  void initState() {
    super.initState();
    // add listener to detect orientation change
    loadUrlFromJsonAsset();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    // remove listener
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
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
      child: url == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : WillPopScope(
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
                          onWebViewCreated:
                              (WebViewController webViewController) {
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
                            // get body height webview
                            _controller.future
                                .then((c) => c.evaluateJavascript(
                                    'document.body.scrollHeight'))
                                .then((result) {
                              final double height = double.parse(result);
                              print('WebView height set to: $height');
                              _webViewHeight = height;
                              setState(() {
                                isLoading = false;
                              });
                            });
                            // setState(() {
                            //   isLoading = false;
                            // });
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

  loadUrlFromJsonAsset() async {
    final String jsonString =
        await DefaultAssetBundle.of(context).loadString('assets/assets.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    url = jsonMap['url'];
    setState(() {
      url = jsonMap['url'];
    });
  }
}
