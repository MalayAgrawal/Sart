import 'dart:async';
import 'dart:ui';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:sart/guidepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sart/Home/database.dart';
import 'package:sart/Home/favoritePage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

var filterData, slider, allLinks;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool closeMidSlider = false,
      loading = true,
      sidemenu = false,
      activeFilter = false,
      activeSearchBar = false;
  Map<String, dynamic> resultsMap;
  int findex = 2;
  double loadingbar = 0;
  String passedUrl = '';
  List<String> favo = [], favoName = [];
  List filterList;
  final ScrollController _controller = ScrollController();
  TextEditingController textController = new TextEditingController();

  void getFilterData(a) async {
    setState(() {
      closeMidSlider = true;
      sidemenu = false;
      loading = true;
      filterList = [];
    });
    print("\n\n\n\n" + a);
    filterData =
        await FirebaseFirestore.instance.collection("Filter").doc(a).get();
    resultsMap = filterData.data();
    resultsMap.remove('itemID');
    filterList = resultsMap.entries.map((e) => e.value).toList();
    filterList.shuffle();
    setState(() {
      loading = false;
      activeFilter = true;
    });
  }

  onSearchTextChanged(String text) {
    print(allLinks);
    setState(() {});
  }

  void getData() async {
    await Firebase.initializeApp();
    allLinks = await FirebaseFirestore.instance
        .collection("AllLinks1")
        .doc("AllLinks")
        .get();
    allLinks = allLinks.data();
    allLinks.remove('itemID');
    allLinks = allLinks.entries.map((e) => e.value).toList();
    allLinks.shuffle();
    slider = await FirebaseFirestore.instance
        .collection("Slider")
        .doc("All_links")
        .get();
    slider = slider.data();
    slider.remove('itemID');
    slider = slider.entries.map((e) => e.value).toList();
    slider.shuffle();
    favo = await MySharedPreferences.getListData("favo");
    favoName = await MySharedPreferences.getListData("favoName");
    if (favo == null || favoName == null) {
      await MySharedPreferences.setListData("favo", []);
      await MySharedPreferences.setListData("favoName", []);
      favo = await MySharedPreferences.getListData("favo");
      favoName = await MySharedPreferences.getListData("favoName");
    }
    if (allLinks != null && slider != null) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<bool> backButtonControl() async {
    if (activeSearchBar) {
      setState(() {
        activeSearchBar = false;
      });
    } else if (activeFilter) {
      setState(() {
        activeFilter = false;
      });
    } else {}
  }

  @override
  void initState() {
    getData();

    Timer.periodic(Duration(seconds: 5), (Timer t) {
      setState(() {
        if (findex == 2)
          findex = 3;
        else
          findex = 2;
      });
    });

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
                  loading
                      ? Expanded(
                          child: Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey[400]))))
                      : Expanded(
                          child: GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              if (!activeFilter && !activeSearchBar) {
                                if (details.delta.dx > 5) {
                                  setState(() {
                                    sidemenu = true;
                                  });
                                }
                              }

                              if (activeFilter) {
                                if (details.delta.dx > 5) {
                                  setState(() {
                                    activeFilter = false;
                                    closeMidSlider = false;
                                  });
                                }
                              }

                              if (details.delta.dx < -5) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => favoPage()));
                              }
                            },
                            child: Column(children: [
                              AnimatedContainer(
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
                                  itemCount: slider.length,
                                  itemBuilder: (BuildContext context, int index,
                                          int itemIndex) =>
                                      GestureDetector(
                                    onTap: () {
                                      passedUrl = slider[index][0];
                                      urlLauncher();
                                    },
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: CachedNetworkImage(
                                          imageUrl: slider[index][1],
                                          fit: BoxFit.contain,
                                        )),
                                  ),
                                ),
                              ),

//list
                              closeMidSlider
                                  ? SizedBox()
                                  : SizedBox(
                                      height: 10,
                                    ),
                              activeSearchBar
                                  ? searchList()
                                  : activeFilter
                                      ? filterPage()
                                      : webList()
                            ]),
                          ),
                        )
                ],
              ),
            ),

// Side Menu
            sidemenu
                ? GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx < -5) {
                        setState(() {
                          sidemenu = false;
                        });
                      }
                    },
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
          ],
        ),
      ),
    );
  }

  Widget searchList() {
    return Expanded(
      child: Container(
          child: ListView.builder(
              physics: BouncingScrollPhysics(),
              controller: _controller,
              itemCount: allLinks.length,
              itemBuilder: (BuildContext context, int index) {
                return allLinks[index][0]
                        .toLowerCase()
                        .contains(textController.text.toLowerCase())
                    ? Column(
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
                                  Text(
                                    allLinks[index][0],
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      print(allLinks[index][1]);
                                      passedUrl = allLinks[index][1];
                                      urlLauncher();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(33))),
                                      padding: EdgeInsets.all(18),
                                      child: FlutterLinkPreview(
                                        showMultimedia: false,
                                        useMultithread: true,
                                        cache: Duration(microseconds: 10),
                                        url: allLinks[index][1],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      )
                    : Container();
              })),
    );
  }

  Widget filterPage() {
    return Expanded(
      child: Container(
          child: ListView.builder(
              physics: BouncingScrollPhysics(),
              controller: _controller,
              itemCount: filterList.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Color(0xffF1F1F1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(33))),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              filterList[index][0],
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            index.isEven
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          print(filterList[index][1]);
                                          passedUrl = filterList[index][1];
                                          urlLauncher();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(33))),
                                          padding: EdgeInsets.all(10),
                                          width: (MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2) -
                                              20,
                                          child: FlutterLinkPreview(
                                            url: filterList[index][1],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          print(filterList[index][1]);
                                          passedUrl = filterList[index][1];
                                          urlLauncher();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 5.0, bottom: 3),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 2,
                                                    blurRadius: 7,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2) -
                                                  20,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Image.network(
                                                    filterList[index][findex]),
                                              )),
                                        ),
                                      )
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          print(filterList[index][1]);
                                          passedUrl = filterList[index][1];
                                          urlLauncher();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5.0, bottom: 3),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 2,
                                                    blurRadius: 7,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2) -
                                                  20,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Image.network(
                                                    filterList[index][findex]),
                                              )),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          print(filterList[index][1]);
                                          passedUrl = filterList[index][1];
                                          urlLauncher();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(33))),
                                          padding: EdgeInsets.all(10),
                                          width: (MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2) -
                                              20,
                                          child: FlutterLinkPreview(
                                            url: filterList[index][1],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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

  Widget webList() {
    return loading
        ? Container()
        : Expanded(
            child: Container(
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: _controller,
                    itemCount: allLinks.length,
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
                                        allLinks[index][0],
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Spacer(),
                                      favoIcon(allLinks[index][1],
                                          allLinks[index][0]),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      print(allLinks[index][1]);
                                      passedUrl = allLinks[index][1];
                                      urlLauncher();
                                    },
                                    child: CarouselSlider.builder(
                                        options: CarouselOptions(
                                          enlargeCenterPage: true,
                                          autoPlay: true,
                                          viewportFraction: 0.95,
                                          autoPlayInterval:
                                              Duration(seconds: 2),
                                          autoPlayAnimationDuration:
                                              Duration(milliseconds: 800),
                                          autoPlayCurve: Curves.decelerate,
                                          scrollDirection: Axis.horizontal,
                                        ),
                                        itemCount: 5,
                                        itemBuilder: (BuildContext context,
                                                int index1, int itemIndex) =>
                                            CachedNetworkImage(
                                                fit: BoxFit.contain,
                                                imageUrl: allLinks[index]
                                                    [index1 + 2])),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      print(allLinks[index][1]);
                                      passedUrl = allLinks[index][1];
                                      urlLauncher();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(33))),
                                      padding: EdgeInsets.all(18),
                                      child: FlutterLinkPreview(
                                        cache: const Duration(days: 3),
                                        url: allLinks[index][1],
                                      ),
                                    ),
                                  ),
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

  Widget sideMenu() {
    return sidemenu
        ? BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 800),
              color: Color(0xffeaeced).withOpacity(0.82),
              width: MediaQuery.of(context).size.width - 120,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 120,
                    height: MediaQuery.of(context).size.height - 250,
                    child: SingleChildScrollView(
                      child: Column(
//Filter Options
                        children: [
//Mens Section
                          SizedBox(
                            height: 20,
                          ),
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
                                title: Text(
                                  "M E N S",
                                  style: TextStyle(fontSize: 18),
                                ),
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      getFilterData('M-T-Shirt');
                                    },
                                    child: Container(
                                      width: 150,
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "T-Shirts",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      getFilterData('M-Shirts');
                                    },
                                    child: Container(
                                      width: 150,
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Shirts",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      getFilterData('M-Hoodies-Jackets');
                                    },
                                    child: Container(
                                      width: 150,
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Hoodies & Jackets",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      getFilterData('M-Bottomwear');
                                    },
                                    child: Container(
                                      width: 150,
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Bottomwear",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
//Womens Section

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
                                title: Text(
                                  "W O M E N",
                                  style: TextStyle(fontSize: 18),
                                ),
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      getFilterData('W-CropTops-T-Shirts');
                                    },
                                    child: Container(
                                      width: 150,
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "CropTops & \nT-Shirts",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      getFilterData('W-Hoodies-Jackets');
                                    },
                                    child: Container(
                                      width: 150,
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Hoodies & Jackets",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      getFilterData('W-BottomWear');
                                    },
                                    child: Container(
                                      width: 150,
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Bottomwear",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),

//Acsseries
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
                                title: Text(
                                  "ACCESSORIES",
                                  style: TextStyle(fontSize: 18),
                                ),
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      getFilterData('Toe Wear');
                                    },
                                    child: Container(
                                      width: 150,
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Toe Wear",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      getFilterData('Gifts');
                                    },
                                    child: Container(
                                      width: 150,
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Gift's",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      getFilterData('Random Stuff');
                                    },
                                    child: Container(
                                      width: 150,
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Random Stuff",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Column(children: [
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            goToGuide();
                          },
                          child: Container(
                              height: 50,
                              width: 200,
                              padding: EdgeInsets.only(
                                right: 10,
                                left: 10,
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              child: Center(
                                  child: Text(
                                "About Us",
                                style: TextStyle(fontSize: 18),
                              ))),
                        ),
                        SizedBox(
                          height: 14,
                        ),
                        GestureDetector(
                          onTap: () => openEmail('malay@gmail.com'),
                          child: Container(
                              height: 50,
                              width: 200,
                              padding: EdgeInsets.only(
                                right: 10,
                                left: 10,
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              child: Center(
                                  child: Text(
                                "Contact Us",
                                style: TextStyle(fontSize: 18),
                              ))),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  goToGuide() async {
    await MySharedPreferences.setForFirstTimeLogin('var', true);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GuidePage()));
  }

  openEmail(email) async {
    await launch('mailto:sart.vriksh.dev@gmail.com');
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

  Future<void> urlLauncher() async {
    await launchUrl(
      passedUrl,
      option: new CustomTabsOption(
        toolbarColor: Colors.white60,
        enableDefaultShare: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
        animation: new CustomTabsAnimation.fade(),
        extraCustomTabs: <String>[
          'org.mozilla.firefox',
          'com.microsoft.emmx',
        ],
      ),
    );
  }

  Widget header() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Color(0xffeaeced),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25))),
          height: activeSearchBar ? 130 : 110,
          width: MediaQuery.of(context).size.width,
          child: activeSearchBar
              ? Padding(
                  padding: const EdgeInsets.only(
                      top: 70, bottom: 20, left: 70, right: 70),
                  child: Container(
                    padding: EdgeInsets.only(right: 25, left: 25, bottom: 2),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        )),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      controller: textController,
                      onChanged: onSearchTextChanged,
                    ),
                  ),
                )
              : Row(
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
                          Icons.menu,
                          size: (30),
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 24, bottom: 41),
                      child: SvgPicture.asset(
                        "assets/images/Sart 2.svg",
                        color: Colors.grey[700],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 33, left: 26),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            activeSearchBar = true;
                            closeMidSlider = true;
                          });
                        },
                        child: Container(
                          height: 30,
                          width: 180,
                          decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(57))),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Search...",
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 30,
              width: 60,
              child: Text(
                "All",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => favoPage()));
              },
              child: Container(
                alignment: Alignment.center,
                height: 30,
                width: 60,
                child: Text(
                  "Favo",
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
