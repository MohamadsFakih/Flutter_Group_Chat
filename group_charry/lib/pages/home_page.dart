import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_charry/pages/auth/login_page.dart';
import 'package:group_charry/services/auth_service.dart';
import 'package:group_charry/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService=AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            authService.signOut();
            nextScreen(context, LoginPage());
          },
          child: Text("LOGOUT"),

        ),
      ),
    );
  }
}
