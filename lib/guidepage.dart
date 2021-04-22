import 'package:flutter/material.dart';
import 'package:sart/Home/database.dart';
import 'package:sart/Home/homepage.dart';

class GuidePage extends StatefulWidget {
  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  bool whitepage = true, a;

  checkForFir() async {
    a = await MySharedPreferences.getForFirstTimeLogin('var');
    print("\n\n\n");
    print(a);
    if (a == false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else if (a == null) {
      setState(() {
        whitepage = false;
      });
    } else {
      MySharedPreferences.setForFirstTimeLogin('var', false);
      setState(() {
        whitepage = false;
      });
    }
  }

  void initState() {
    checkForFir();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: whitepage
          ? Container()
          : PageView(
              children: [
                Stack(
                  children: [
                    Center(
                        child: Image.asset(
                      "assets/images/guide0.png",
                    )),
                    Positioned(
                        bottom: 30,
                        right: 30,
                        child: a
                            ? Container()
                            : Text(
                                "Swipe Left to\n Agree and Continue",
                                style: TextStyle(color: Colors.grey),
                              ))
                  ],
                ),
                Stack(
                  children: [
                    Center(
                        child: Image.asset(
                      "assets/images/guide1.png",
                    )),
                    Positioned(
                        bottom: 30,
                        right: 30,
                        child: Text(
                          "Swipe Left",
                          style: TextStyle(color: Colors.grey),
                        ))
                  ],
                ),
                Stack(
                  children: [
                    Center(child: Image.asset("assets/images/guide2.png")),
                    Positioned(
                        bottom: 50,
                        right: 50,
                        child: GestureDetector(
                          onTap: () {
                            MySharedPreferences.setForFirstTimeLogin(
                                "var", false);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                top: 10, bottom: 10, left: 20, right: 10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: Row(
                              children: [
                                Text(
                                  "Dive In",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.navigate_next,
                                  color: Colors.grey[600],
                                )
                              ],
                            ),
                          ),
                        ))
                  ],
                ),
              ],
            ),
    );
  }
}
