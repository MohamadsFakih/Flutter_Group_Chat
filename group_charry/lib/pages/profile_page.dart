import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_charry/pages/home_page.dart';

import '../helper/helper_function.dart';
import '../services/auth_service.dart';
import '../widgets/widgets.dart';
import 'auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  final String userName,email;
  const ProfilePage({Key? key,
  required this.userName,
    required this.email
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  AuthService authService=AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Profile",style: TextStyle(fontSize: 27,fontWeight: FontWeight.bold,color: Colors.white),),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: [
            const Icon(Icons.account_circle,size: 150,color: Colors.grey),
            const SizedBox(height: 15,),
            Text(widget.userName,textAlign: TextAlign.center,style: const TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height: 30,),
            const Divider(height: 2,),
            ListTile(
              onTap: (){
                nextScreenReplace(context, HomePage());
              },

              contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: (){


              },
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.person),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: (){
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        title: Text("Logout"),
                        content: Text("Are you sure you want to logout?"),
                        actions: [
                          IconButton(onPressed: (){
                            Navigator.pop(context);
                          }, icon: const Icon(Icons.cancel,color: Colors.red,)),
                          IconButton(onPressed: (){
                            authService.signOut().whenComplete(() {
                              nextScreenReplace(context, const LoginPage());
                            });
                          }, icon: const Icon(Icons.done,color: Colors.green,)),
                        ],
                      );
                    }
                );

              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "LogOut",
                style: TextStyle(color: Colors.black),
              ),
            ),


          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.account_circle,size: 200,color: Colors.grey,),
            const SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Name",style: TextStyle(fontSize: 17),),
                 Text(widget.userName,  style:const  TextStyle(fontSize: 17),),
              ],
            ),
            const Divider(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Email",style: TextStyle(fontSize: 17),),
                Text(widget.email,  style:const  TextStyle(fontSize: 17),),
              ],
            ),

          ],
        ),


      )

    );
  }
}
