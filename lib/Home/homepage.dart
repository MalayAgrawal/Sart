import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var midSlider, linkList;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool closeMidSlider = false, loading = true;

  final ScrollController _controller = ScrollController();

  void getData() async {
    await Firebase.initializeApp();
    midSlider = await FirebaseFirestore.instance.collection("MidSlider").get();
    linkList = await FirebaseFirestore.instance.collection("AllLinks").get();
    setState(() {
      loading = false;
    });
    print("\n\n\n");
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
      if (closeMidSlider && _controller.offset < -110) {
        setState(() {
          closeMidSlider = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Color(0xffcecece),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              height: 125,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 30, bottom: 37),
                    child: Icon(
                      Icons.list,
                      size: (34),
                      color: Colors.grey[600],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 24, bottom: 43),
                    child: Image.asset("assets/images/LOGO.png"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 37, left: 26),
                    child: Container(
                      height: 30,
                      width: 180,
                      decoration: BoxDecoration(
                          color: Color(0xff8F8F8F),
                          borderRadius: BorderRadius.all(Radius.circular(57))),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),

//Slider

            loading
                ? Container()
                : AnimatedContainer(
                    height: closeMidSlider ? 1 : 370,
                    width:
                        closeMidSlider ? 1 : MediaQuery.of(context).size.width,
                    duration: Duration(milliseconds: 300),
                    child: CarouselSlider.builder(
                      options: CarouselOptions(
                        height: 600,
                        viewportFraction: 0.85,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                      ),
                      itemCount: midSlider.docs.length,
                      itemBuilder:
                          (BuildContext context, int index, int itemIndex) =>
                              GestureDetector(
                        onTap: () {
                          print(index);
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Image.network(
                              midSlider.docs[index]["img"],
                              fit: BoxFit.cover,
                            )),
                      ),
                    ),
                  ),

//list

            loading
                ? Container()
                : Expanded(
                    child: Container(
                        child: DraggableScrollbar.semicircle(
                      controller: _controller,
                      child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          controller: _controller,
                          itemCount: linkList.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Container(
                                    padding: EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                        color: Color(0xffF1F1F1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(33))),
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
                                            Icon(Icons.favorite_border),
                                            SizedBox(
                                              width: 20,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(33))),
                                          padding: EdgeInsets.all(18),
                                          child: FlutterLinkPreview(
                                            url: linkList.docs[index]["url"],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(33))),
                                          child: Image.network(
                                            linkList.docs[index]["img"],
                                          ),
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
                          }),
                    )),
                  )
          ],
        ),
      ),
    );
  }
}
