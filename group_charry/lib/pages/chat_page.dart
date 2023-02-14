import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:group_charry/pages/group_info.dart';
import 'package:group_charry/services/databse_service.dart';
import 'package:group_charry/widgets/message_tile.dart';
import 'package:group_charry/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage({Key? key,
  required this.groupId,
    required this.groupName,
    required this.userName
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  String admin="";
  Stream<QuerySnapshot>? chats;
  TextEditingController messageCotroller=TextEditingController();
  @override
  void initState(){
    super.initState();
    getChatandAdmin();

  }
  getChatandAdmin(){
    DatabaseService().getChats(widget.groupId).then((val){
      setState((){
        chats=val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((value) {
      setState((){
        admin=value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: (){
                nextScreen(context,  GroupInfo(groupId: widget.groupId, adminName: admin, groupName: widget.groupName));
              },
              icon: const Icon(Icons.info)
          )
        ],
      ),
      body: Column(
        children: [
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
             padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey.withOpacity(.8),
              child: Row(
                children: [
                  Expanded(
                      child: TextFormField(
                        controller: messageCotroller,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Send a message...",
                          hintStyle: TextStyle(color: Colors.white,fontSize: 16),
                          border: InputBorder.none
                        ),

                  ),
                  ),
                  const SizedBox(width: 12,),
                  GestureDetector(
                    onTap: (){
                      senMessage();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Center(
                        child: Icon(Icons.send,color: Colors.white,),
                      ),
                    ),
                  )

                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  chatMessages(){
    return Expanded(
      child: StreamBuilder(
        stream: chats ,
        builder: (context,AsyncSnapshot snapshot){
          return snapshot.hasData?ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            itemCount: snapshot.data.docs.length,

              itemBuilder: (context,index){


                return MessageTile(mesaage: snapshot.data.docs[index]['message'], sender: snapshot.data.docs[index]['sender'],
                    sentByMe: widget.userName== snapshot.data.docs[index]['sender']);

              }
          ):Container();
        }
      ),

    );

  }

  void senMessage() {
    if(messageCotroller.text.isNotEmpty){
      Map<String,dynamic> chatMessageMap={
        "message":messageCotroller.text,
        "sender":widget.userName,
        "time":DateTime.now().millisecondsSinceEpoch
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState((){
        messageCotroller.clear();
      });
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent+50,
            duration: const Duration(milliseconds: 1),
            curve: Curves.fastOutSlowIn);
      });
    }{
    }
  }
}
