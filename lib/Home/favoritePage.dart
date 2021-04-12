import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sart/Home/database.dart';

class favoPage extends StatefulWidget {
  @override
  _favoPageState createState() => _favoPageState();
}

class _favoPageState extends State<favoPage> {
  List favo = [], favoName = [];
  double loadingbar = 0;
  String passedUrl = '';
  bool loading = true, activeWebView = false;
  InAppWebViewController _webViewController;
  getData() async {
    favo = await MySharedPreferences.getListData("favo");
    favoName = await MySharedPreferences.getListData("favoName");
    if (favo == null || favoName == null) {
      await MySharedPreferences.setListData("favo", []);
      await MySharedPreferences.setListData("favoName", []);
      favo = await MySharedPreferences.getListData("favo");
      favoName = await MySharedPreferences.getListData("favoName");
    }
    setState(() {
      loading = false;
    });
  }

  Future<bool> backButtonControl() {
    setState(() {
      if (activeWebView)
        activeWebView = false;
      else
        Navigator.pop(context);
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        backButtonControl();
      },
      child: Scaffold(
          body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Column(children: [
              Container(
                decoration: BoxDecoration(
                    color: Color(0xffcecece),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                height: 110,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 69, right: 110, left: 110, bottom: 20),
                  child: SvgPicture.asset(
                    "assets/images/Sart 2.svg",
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Expanded(
                  child: loading
                      ? Container()
                      : GestureDetector(
                          onHorizontalDragUpdate: (details) => {
                            if (details.delta.dx > 5)
                              {
                                Navigator.pop(context),
                              }
                          },
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: favo.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      right: 10, left: 10, bottom: 15),
                                  child: GestureDetector(
                                    onTap: () {
                                      passedUrl = favo[index];
                                      print(passedUrl);
                                      setState(() {
                                        activeWebView = true;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Color(0xffF1F1F1),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(33))),
                                      padding: EdgeInsets.all(18),
                                      child: Column(
                                        children: [
                                          Text(favoName[index]),
                                          FlutterLinkPreview(url: favo[index]),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        )),
            ]),
          ),
          webView()
        ],
      )),
    );
  }

  Widget webView() {
    return activeWebView
        ? Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse(passedUrl)),
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      loadingbar = progress / 100;
                    });
                  },
                ),
              ),
              Positioned(
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xffcecece),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25))),
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _webViewController.goBack();
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.undo,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _webViewController.reload();
                              },
                              child: Container(
                                padding: EdgeInsets.all(20),
                                child: SvgPicture.asset(
                                  "assets/images/Sart 2.svg",
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _webViewController.goForward();
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.redo,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        LinearProgressIndicator(
                          value: loadingbar,
                        ),
                      ],
                    ),
                  )),
            ],
          )
        : Container();
  }
}
