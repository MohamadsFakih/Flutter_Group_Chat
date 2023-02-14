import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_charry/helper/helper_function.dart';
import 'package:group_charry/pages/auth/login_page.dart';
import 'package:group_charry/pages/profile_page.dart';
import 'package:group_charry/pages/search_page.dart';
import 'package:group_charry/services/auth_service.dart';
import 'package:group_charry/services/databse_service.dart';
import 'package:group_charry/widgets/group_tile.dart';
import 'package:group_charry/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName="";
  String email="";
  AuthService authService=AuthService();
  Stream? groups;
  bool isloading=false;
  String groupName="";


  @override
  void initState(){
    super.initState();
    getttingUserData();
  }
  //get the name or id of the group field in fireabse
  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }
  String getName(String res){
    return res.substring(res.indexOf("_")+1);
  }

  getttingUserData()async{
    await HelperFunctions.getUserEmail().then((value) {
      setState((){
        email=value!;
      });
    });
    await HelperFunctions.getUserName().then((value) {
      setState((){
        userName=value!;
      });
    });
    //getting the list of snapshots in out stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getUserGroups().then((snapshot){
      groups=snapshot;

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            nextScreen(context, const SearchPage());
          },
              icon: Icon(Icons.search))
        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Groups",style: TextStyle(fontSize: 27,fontWeight: FontWeight.bold,color: Colors.white),),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: [
            const Icon(Icons.account_circle,size: 150,color: Colors.grey),
            const SizedBox(height: 15,),
            Text(userName,textAlign: TextAlign.center,style: const TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height: 30,),
            const Divider(height: 2,),
            ListTile(
              onTap: (){
              },
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: (){

                nextScreenReplace(context, ProfilePage(userName: userName,email: email,));
              },
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
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add,color: Colors.white,size: 30,),
      ),
    );
  }
  groupList(){
    return StreamBuilder(
      stream: groups,
        builder: (context,AsyncSnapshot snapshot){
          if(snapshot.hasData){
            if(snapshot.data['groups']!=null){
                if(snapshot.data['groups'].length!=0){
                  return ListView.builder(
                      itemCount: snapshot.data['groups'].length,
                    itemBuilder: (context,index){
                        int reverseIndex=snapshot.data['groups'].length-index-1;

                        return GroupTile(groupName:getName(snapshot.data['groups'][reverseIndex]),
                            groupId: getId(snapshot.data['groups'][reverseIndex]),
                            userName:snapshot.data["fullName"],lastMessage: "hello",
                        lastSender: "mido",);
                    },
                  );
                }else{
                  return noGroupsWidget();
                }
            }else{
              return noGroupsWidget();
            }

          }else{
            return  Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),);
          }
        },
    );
  }

  void popUpDialog(BuildContext context) {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (context){
      return StatefulBuilder(
        builder: ((context,setState){
          return AlertDialog(
            title: const Text("Create a group",textAlign: TextAlign.left,),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isloading==true?Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),):
                TextField(
                  onChanged: (val){
                    setState((){
                      groupName=val;

                    });
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(30)
                    ),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(30)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(30)
                    ),
                  ),

                )
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
                child: Text("CANCEL"),

              ),
              ElevatedButton(
                onPressed: (){
                  if(groupName!=""){
                    setState((){
                      isloading=true;
                    });

                    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).createGroup(userName, FirebaseAuth.instance.currentUser!.uid, groupName).whenComplete(() {
                      isloading=false;
                    });
                    Navigator.of(context).pop();
                    showSnackBar(context, Colors.green, "Group created successfully!");
                  }
                },
                style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
                child: Text("CREATE"),

              ),
            ],
          );
        })

      );
        }
    );
  }

  noGroupsWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.add_circle,color: Colors.grey,size: 75,),
            const SizedBox(height: 20,),
            const Text("You are not in a group, tap the add button to create a group or search for an existing one using the search bar",textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
  }
}
