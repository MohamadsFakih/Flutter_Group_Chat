import 'package:flutter/material.dart';
import 'package:group_charry/helper/helper_function.dart';
import 'package:group_charry/pages/chat_page.dart';
import 'package:group_charry/services/databse_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_charry/widgets/widgets.dart';
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController=TextEditingController();
  bool isloading=false;
  QuerySnapshot? searchSnapshot;
  bool hasSearched=false;
  bool isJoined=false;
  String userName="";
  User? user;
  @override
  void initState(){
    super.initState();
    getCurrentUserInfo();
  }
  getCurrentUserInfo()async{
    await HelperFunctions.getUserName().then((value) {
      setState((){
        userName=value!;
      });
    });
    user=FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Search",style: TextStyle(fontSize: 27,fontWeight: FontWeight.bold,color: Colors.white),),
      ),
      body:  Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Searh Groups...",
                        hintStyle: TextStyle(color: Colors.white,fontSize: 16)
                      ),
                    )
                ),
                GestureDetector(
                  onTap: (){
                    initiateSearch();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(Icons.search,color: Colors.white,),
                  ),
                )
              ],
            ),
          ),
          isloading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),):groupList(),
        ],
      ),
    );
  }
  initiateSearch()async{
    if(searchController.text.isNotEmpty){
      setState((){
        isloading=true;
      });
      await DatabaseService().searchByName(searchController.text).then((snapshot){
        setState((){
          searchSnapshot=snapshot;
          isloading=false;
          hasSearched=true;
        });
      });
    }
  }
  groupList(){
    return hasSearched? ListView.builder(
        shrinkWrap: true,
        itemCount: searchSnapshot!.docs.length,
        itemBuilder: (context,index){
          return groupTile(userName, searchSnapshot!.docs[index]['groupId'],  searchSnapshot!.docs[index]['groupName'],  searchSnapshot!.docs[index]['admin']);
        }
    ):Container();
  }
  Widget groupTile(String userName,String groupId,String groupName,String admin){
    //check if user is already in the group
    joined(userName,groupId,groupName,admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(groupName.substring(0,1).toUpperCase(),style: const TextStyle(color: Colors.white),
        ),

      ),
      title: Text(groupName,style: const TextStyle(fontWeight:FontWeight.w600),),
      trailing: InkWell(
        onTap: ()async{
            await DatabaseService(uid: user!.uid).toggleGroupJoin(groupId, userName, groupName).whenComplete(() {
              showSnackBar(context, Colors.green, "Successfully joined $groupName");
              Future.delayed(const Duration(seconds: 2),(){
                nextScreen(context, ChatPage(groupId: groupId, groupName: groupName, userName: userName));
              });
            });


              if(!isJoined){
                setState((){
                  isJoined = !isJoined;

                  });

              }

        },
        child: isJoined?Container(
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(10),
           color: Colors.black,
           border: Border.all(color: Colors.white,width: 1),
         ) ,
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: const Text(
            "Joined",
            style: TextStyle(color: Colors.white),
          ),
        ):Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: Text("Join",style:TextStyle(color: Colors.white),),
        ),
      ),
    );
  }

  void joined(String userName, String groupId, String groupName, String admin)async {
    await DatabaseService(uid: user!.uid).isUserJoined(groupName, groupId, userName).then((value) {
      setState((){
        isJoined=value;
      });
    });
  }
}

