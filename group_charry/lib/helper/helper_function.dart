import 'package:shared_preferences/shared_preferences.dart';
class HelperFunctions{

  //keys
  static String userLoggedInKey="LOGGEDINKEY";
  static String userNameKey="USERNAMEKEY";
  static String userEmailKey="USEREMAILKEY";

  //Saving data to shared preferences
  static Future<bool> saveUserLogInStatus(bool isUserLoggedIn)async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserLoggedIn);
  }
  static Future<bool> saveUserNameSf(String userName)async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userNameKey, userName);
  }
  static Future<bool> saveUserEmailSf(String email)async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userEmailKey, email);
  }


  //Getting data from shared pereferences

  static Future<bool?> getUserLoggedInStatus() async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }
  static Future<String?> getUserName() async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }
  static Future<String?> getUserEmail() async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }
}