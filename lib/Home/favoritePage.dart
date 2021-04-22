import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sart/Home/database.dart';
import 'package:share/share.dart';

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

  shareLink() async {
    var url = await _webViewController.getUrl();
    Share.share(
        url.toString() + " Join us at SART to shop more products like this");
  }

  Future<bool> backButtonControl() {
    setState(() {
      if (activeWebView)
        activeWebView = false;
      else
        Navigator.pop(context);
    });
  }

  Future<void> urlLauncher() async {
    await launchUrl(
      passedUrl,
      option: new CustomTabsOption(
        toolbarColor: Colors.white60,
        enableDefaultShare: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
        animation: new CustomTabsAnimation.slideIn(),
        extraCustomTabs: <String>[
          'org.mozilla.firefox',
          'com.microsoft.emmx',
        ],
      ),
    );
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
          body: Container(
        color: Colors.white,
        child: Column(children: [
          Container(
            decoration: BoxDecoration(
                color: Color(0xffeaeced),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25))),
            height: 110,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding:
                  EdgeInsets.only(top: 72, right: 110, left: 110, bottom: 20),
              child: SvgPicture.asset(
                "assets/images/Sart 2.svg",
                color: Colors.grey[600],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 30,
                  width: 60,
                  child: Text(
                    "All",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 30,
                width: 60,
                child: Text(
                  "Favo",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              )
            ],
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
                                  urlLauncher();
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
      )),
    );
  }
}
