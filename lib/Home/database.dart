import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  static setListData(String key, List<String> value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setStringList(key, value);
  }

  static Future<List<String>> getListData(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getStringList(key);
  }

  static setForFirstTimeLogin(String key, bool value) async {
    SharedPreferences firCheck = await SharedPreferences.getInstance();
    firCheck.setBool(key, value);
  }

  static Future<bool> getForFirstTimeLogin(String key) async {
    SharedPreferences firCheck = await SharedPreferences.getInstance();
    return firCheck.getBool(key);
  }
}
