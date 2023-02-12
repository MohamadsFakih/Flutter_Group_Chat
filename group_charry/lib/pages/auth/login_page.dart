import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:group_charry/pages/auth/register_page.dart';
import 'package:group_charry/services/auth_service.dart';
import 'package:group_charry/services/databse_service.dart';
import 'package:group_charry/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../helper/helper_function.dart';
import '../home_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthService authService= AuthService();
  final formkey=GlobalKey<FormState>();
  String email="";
  String password="";
  bool isloading=false;
  void login()async {
    if(formkey.currentState!.validate()){
      setState((){
        isloading=true;
      });
      await authService.loginUser( email, password).then((value)async {
        if(value==true){
          QuerySnapshot snapshot=
          await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getUserData(email);
          //save the values to shared preferences
          await HelperFunctions.saveUserLogInStatus(true);
          await HelperFunctions.saveUserEmailSf(email);
          await HelperFunctions.saveUserNameSf(snapshot.docs[0]['fullName']);

          nextScreen(context, HomePage());
        }else{
          showSnackBar(context, Colors.red, value);
          setState((){
            isloading=false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading?Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),)
          :
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 80),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:  <Widget>[
                const Text("Groups",style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold),),
               const SizedBox(height: 10,),
                const Text("Fun engaging groups for everyone!",
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400),),
                const Image(image: AssetImage("images/groupHug.png")),
                const SizedBox(height: 40,),
                TextFormField(
                  decoration: textInputDecoation.copyWith(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email,color: Theme.of(context).primaryColor,),
                  ),
                  onChanged: (val){
                    setState((){
                      email=val;
                    });
                  },
                  //check the valdiation
                  
                  validator: (val){
                    return RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(val!)
                        ? null
                        : "Please enter a valid email";
                  },
                ),
            const SizedBox(height: 15,),
            TextFormField(
              obscureText: true,
              decoration: textInputDecoation.copyWith(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock,color: Theme.of(context).primaryColor,),
              ),
              validator: (val){
                if(val!.length<6){
                  return "Password must be atleast 6 characters";
                }else{
                  return null;
                }
              },
              onChanged: (val){
                setState((){
                  password=val;
                });
              },
            
            ),
               const SizedBox(height: 20,),
                 SizedBox(
                  width: double.infinity,
                  child:  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: Text("Sign In",style: TextStyle(
                      color: Colors.white,fontSize: 16
                    ),),
                    onPressed: (){
                      login();
                    },
                  ),
                ),
                const SizedBox(height: 10,),
                  Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(color: Colors.black,fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                          text: "Register here",
                          style: const TextStyle(color:  Colors.black,decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()..onTap=(){
                            nextScreen(context, RegisterPage());
                          }
                        )
                      ]
                    )
                  )
                
                
              ],
            ),
          ),
        ),
      )
    );

  }




}
