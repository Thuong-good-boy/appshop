import 'package:shared_preferences/shared_preferences.dart';

class Share_pref{
  static String userTdKey = "USERIDKEY";
  static String userNameKey ="USERNAMEKEY";
  static String userEmailKey="USEREMAILKEY";
  static String userImageKey="USERIMAGEKEY";
  Future<bool> saveUserId (String getUserId) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(userTdKey, getUserId);
  }
  Future<bool> saveUserName (String getUserName) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(userNameKey, getUserName);
  }
  Future<bool> saveUserEmail (String getUserEmail) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(userEmailKey, getUserEmail);
  }
  Future<bool> saveUserImage (String getUserImage) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(userImageKey, getUserImage);
  }
  Future<String?> getUserId()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userTdKey);
  }
  Future<String?> getUserName()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userNameKey);
  }
  Future<String?> getUserEmail()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userEmailKey);
  }
  Future<String?> getUserImage()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userEmailKey);
  }
}