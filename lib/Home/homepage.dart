import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sart/Home/database.dart';
import 'package:sart/Home/favoritePage.dart';

var midSlider, linkList;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool closeMidSlider = false,
      loading = true,
      sidemenu = false,
      activeWebView = false;
  double loadingbar = 0;
  String passedUrl = '';
  List<String> favo = [], favoName = [];
  final ScrollController _controller = ScrollController();
  InAppWebViewController _webViewController;
  void getData() async {
    await Firebase.initializeApp();
    midSlider = await FirebaseFirestore.instance.collection("MidSlider").get();
    linkList = await FirebaseFirestore.instance.collection("AllLinks").get();
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
    if (activeWebView) {
      setState(() {
        activeWebView = false;
      });
    }
  }

  @override
  void initState() {
    getData();
    super.initState();

    _controller.addListener(() {
      if (!closeMidSlider && _controller.offset > 20) {
        setState(() {
          closeMidSlider = true;
        });
      }
      if (closeMidSlider && _controller.offset < -50) {
        setState(() {
          closeMidSlider = false;
        });
      }
    });
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
              child: Column(
                children: [
                  header(),
                  SizedBox(
                    height: 5,
                  ),

//Slider
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        if (details.delta.dx > 5) {
                          setState(() {
                            sidemenu = true;
                          });
                        }
                        if (details.delta.dx < -5) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => favoPage()));
                        }
                      },
                      child: Stack(
                        children: [
                          Column(children: [
                            loading
                                ? Container()
                                : AnimatedContainer(
                                    height: closeMidSlider ? 1 : 370,
                                    width: closeMidSlider
                                        ? 1
                                        : MediaQuery.of(context).size.width,
                                    duration: Duration(milliseconds: 300),
                                    child: CarouselSlider.builder(
                                      options: CarouselOptions(
                                        height: 600,
                                        viewportFraction: 0.95,
                                        initialPage: 0,
                                        enableInfiniteScroll: true,
                                        reverse: false,
                                        autoPlay: true,
                                        autoPlayInterval:
                                            Duration(milliseconds: 2500),
                                        autoPlayAnimationDuration:
                                            Duration(milliseconds: 800),
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                        enlargeCenterPage: true,
                                        scrollDirection: Axis.horizontal,
                                      ),
                                      itemCount: midSlider.docs.length,
                                      itemBuilder: (BuildContext context,
                                              int index, int itemIndex) =>
                                          GestureDetector(
                                        onTap: () {
                                          passedUrl =
                                              midSlider.docs[index]['url'];
                                          print(passedUrl);
                                          setState(() {
                                            activeWebView = true;
                                          });
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: CachedNetworkImage(
                                              imageUrl: midSlider.docs[index]
                                                  ["img"],
                                              fit: BoxFit.contain,
                                            )),
                                      ),
                                    ),
                                  ),

//list
                            SizedBox(
                              height: 10,
                            ),
                            webList()
                          ]),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

// Side Menu
            sidemenu
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        sidemenu = false;
                      });
                    },
                    child: Container(
                      color: Colors.white.withOpacity(0.0),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                  )
                : Container(),
            sideMenu(),
//Web View
            webView()
          ],
        ),
      ),
    );
  }

  Widget webList() {
    return loading
        ? Container()
        : Expanded(
            child: Container(
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: _controller,
                    itemCount: linkList.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Container(
                              padding: EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                  color: Color(0xffF1F1F1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(33))),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        linkList.docs[index]["name"],
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Spacer(),
                                      favoIcon(linkList.docs[index]['url'],
                                          linkList.docs[index]['name']),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        print(linkList.docs[index]["url"]);
                                        passedUrl = linkList.docs[index]["url"];
                                        activeWebView = true;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(33))),
                                      padding: EdgeInsets.all(18),
                                      child: FlutterLinkPreview(
                                        url: linkList.docs[index]["url"],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        print(linkList.docs[index]["url"]);
                                        passedUrl = linkList.docs[index]["url"];
                                        activeWebView = true;
                                      });
                                    },
                                    child: CarouselSlider.builder(
                                        options: CarouselOptions(
                                          autoPlay: true,
                                          viewportFraction: 1,
                                          autoPlayInterval:
                                              Duration(seconds: 2),
                                          autoPlayAnimationDuration:
                                              Duration(milliseconds: 800),
                                          autoPlayCurve: Curves.decelerate,
                                          scrollDirection: Axis.horizontal,
                                        ),
                                        itemCount:
                                            linkList.docs[index]["img"].length,
                                        itemBuilder: (BuildContext context,
                                                int index1, int itemIndex) =>
                                            CachedNetworkImage(
                                                fit: BoxFit.contain,
                                                imageUrl: linkList.docs[index]
                                                    ["img"][index1])),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      );
                    })),
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
                                child: Image.asset("assets/images/LOGO.png"),
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

  Widget sideMenu() {
    return sidemenu
        ? BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 800),
              color: Color(0xfff1f1f1).withOpacity(0.82),
              width: MediaQuery.of(context).size.width - 120,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                  ),
                  SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 120,
                      height: MediaQuery.of(context).size.height - 250,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20, left: 20),
                            child: Container(
                              padding: EdgeInsets.only(
                                right: 10,
                                left: 10,
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              child: ExpansionTile(
                                title: Container(
                                  decoration: BoxDecoration(),
                                  child: Text(
                                    "M E N S",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: 150,
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      "S H I R T S",
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: 150,
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      "T - S H I R T S",
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : Container();
  }

  Widget favoIcon(favoUrl, favoNa) {
    favoUpdate() async {
      await MySharedPreferences.setListData('favo', favo);
      await MySharedPreferences.setListData('favoName', favoName);
      print(favo);
      print(favoName);
    }

    if (favo.contains(favoUrl)) {
      return GestureDetector(
          onTap: () {
            setState(() {
              favo.remove(favoUrl);
              favoName.remove(favoNa);
              favoUpdate();
            });
          },
          child: Icon(Icons.favorite, color: Colors.red));
    } else {
      return GestureDetector(
          onTap: () {
            setState(() {
              favo.add(favoUrl);
              favoName.add(favoNa);
              favoUpdate();
            });
          },
          child: Icon(Icons.favorite_border));
    }
  }

  Widget header() {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xffcecece),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20))),
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                sidemenu = true;
              });
            },
            child: Container(
              padding: EdgeInsets.only(left: 30, bottom: 33),
              child: Icon(
                Icons.list,
                size: (34),
                color: Colors.grey[600],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 24, bottom: 39),
            child: Image.asset("assets/images/LOGO.png"),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 33, left: 26),
            child: Container(
              height: 30,
              width: 180,
              decoration: BoxDecoration(
                  color: Color(0xffAEAEAE),
                  borderRadius: BorderRadius.all(Radius.circular(57))),
            ),
          ),
        ],
      ),
    );
  }
}
