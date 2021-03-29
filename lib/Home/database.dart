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
}
