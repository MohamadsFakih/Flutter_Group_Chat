import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_charry/pages/home_page.dart';
import 'package:group_charry/services/databse_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/widgets.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;

  const GroupInfo({Key? key,
    required this.groupId,required this.adminName,required this.groupName
  }) : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  @override
  void initState(){
    super.initState();
    getMembers();
  }
  //get the members to list in the group info
  getMembers(){
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getGroupMembers(widget.groupId).then((val){
      setState((){
        members=val;
      });
    });
  }
  String getName(String res){
    return res.substring(res.indexOf("_")+1);
  }
  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Group Info"),
        actions: [
          IconButton(
              onPressed: (){
                FirebaseAuth.instance.currentUser!.uid==getId(widget.adminName)?
                showDialog(
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        title: Text("Clear Chat"),
                        content: Text("Are you sure you want to clear the chat?"),
                        actions: [
                          IconButton(onPressed: (){
                            Navigator.pop(context);
                          }, icon: const Icon(Icons.cancel,color: Colors.red,)),
                          IconButton(onPressed: (){
                            DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).clearMessages(widget.groupId).whenComplete(() {
                              showSnackBar(context, Colors.green, "Cleared Chat");
                            });

                          }, icon: const Icon(Icons.done,color: Colors.green,)),
                        ],
                      );
                    }
                ): showSnackBar(context, Colors.red, "Only the group admin can clear the chat");
              }
              , icon: Icon(Icons.remove)
          ),
          IconButton(
              onPressed: (){
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context){
                      return AlertDialog(
                          title: Text("Leave Group"),
                        content: Text("Are you sure you want to leave the group?"),
                        actions: [
                          IconButton(onPressed: (){
                            Navigator.pop(context);
                          }, icon: const Icon(Icons.cancel,color: Colors.red,)),
                          IconButton(onPressed: (){
                            DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).toggleGroupExit(widget.groupId, getName(widget.adminName), widget.groupName).whenComplete(() {
                              nextScreenReplace(context, const HomePage());
                            });
                          }, icon: const Icon(Icons.done,color: Colors.green,)),
                        ],
                      );
                    }
                );
              }
              , icon: Icon(Icons.exit_to_app)
          ),


        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).primaryColor.withOpacity(.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.groupName.substring(0,1).toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w500,color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Group: ${widget.groupName}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5,),
                      Text("Admin: ${getName(widget.adminName)}")
                    ],
                  )
                ],
              ),
            ),
            memberList()
          ],
        ),
      ),
    );
  }
  memberList(){
    return StreamBuilder(
      stream: members,
        builder: (context,AsyncSnapshot snapshot){
          if(snapshot.hasData){
            if(snapshot.data['members']!=null){
              if(snapshot.data['members'].length!=0){
                return ListView.builder(
                  itemCount: snapshot.data['members'].length,
                    shrinkWrap: true,
                    itemBuilder: (context,index){
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(getName(snapshot.data['members'][index]).substring(0,1).toUpperCase(),
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                            ),
                            title: Text(getName(snapshot.data['members'][index])),
                            subtitle: Text(getId(snapshot.data['members'][index])),
                          ),
                      );
                    }
                );
              }else{
                return const Center(
                  child: Text("No Members"),
                );
              }

            }else{
              return const Center(
                child: Text("No Members"),
              );
            }
          }else{
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
        }
    );
  }
}
