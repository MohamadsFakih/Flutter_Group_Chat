import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_charry/helper/helper_function.dart';
import 'package:group_charry/services/databse_service.dart';
class AuthService{
  final FirebaseAuth firebaseAuth=FirebaseAuth.instance;

  //login
  Future loginUser(String email,String password)async{
    try{
      User user = (await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;

      if(user!=null){
        //call the databse service to update the user data
        return true;
      }
    }on FirebaseAuthException catch(e){
      return e.message;
    }
  }

  //register
  Future registerUser(String fullName,String email,String password)async{
    try{
      User user = (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;

      if(user!=null){
        //call the databse service to update the user data
        await DatabaseService(uid: user.uid).saveUserData(fullName, email);
        return true;
      }
    }on FirebaseAuthException catch(e){
      return e.message;
    }
  }


  //logout
  Future signOut() async{
    try{
      await HelperFunctions.saveUserLogInStatus(false);
      await HelperFunctions.saveUserNameSf("");
      await HelperFunctions.saveUserEmailSf("");
      await firebaseAuth.signOut();

    }catch(e){
      return null;
    }
  }
}