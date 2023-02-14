import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
class DatabaseService{
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection=FirebaseFirestore.instance.collection("users");
  final CollectionReference groupsCollection=FirebaseFirestore.instance.collection("groups");
  //save user data
  Future saveUserData(String fullName,String email)async{
    return await userCollection.doc(uid).set({
      "fullName":fullName,
      "email":email,
      "groups":[],
      "profilePic":"",
      "uid":uid
    });
  }
  //get user data
Future getUserData(String email)async{
    QuerySnapshot snapshot=await userCollection.where("email",isEqualTo: email).get();
    return snapshot;
}
//get user groups
 getUserGroups()async{
    return userCollection.doc(uid).snapshots();

 }
 //creating a group
 Future createGroup(String userName,String id,String groupName)async{
    DocumentReference documentReference=await groupsCollection.add({
      "groupName":groupName,
      "groupIcon":"",
      "admin":"${id}_$userName",
      "members":[],
      "groupId":"",
      "recentMessage":"",
      "recentMessageSender":""
    });
    await documentReference.update({
      "members":FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId":documentReference.id
    });
    DocumentReference userDocumentReference=userCollection.doc((uid));
    return await userDocumentReference.update({
      "groups":FieldValue.arrayUnion(["${documentReference.id}_$groupName"])
    });
 }
 //getting the chat
  getChats(String groupId)async{
    return groupsCollection.doc(groupId).collection("messages").orderBy("time").snapshots();
  }
  Future getGroupAdmin(String groupId)async{
    DocumentReference d=groupsCollection.doc(groupId);
    DocumentSnapshot documentSnapshot=await d.get();
    return documentSnapshot['admin'];
  }
 //getting the members in a group
  getGroupMembers(String groupId)async{
    return groupsCollection.doc(groupId).snapshots();

  }
  //search groups
 searchByName(String groupName){
    return groupsCollection.where("groupName",isEqualTo: groupName).get();
 }
 //check if user is already in group
Future<bool> isUserJoined(String groupName,String groupId,String userName)async{
    DocumentReference documentReference=userCollection.doc(uid);
    DocumentSnapshot documentSnapshot=await documentReference.get();
    List<dynamic> groups=await documentSnapshot['groups'];
    if(groups.contains("${groupId}_$groupName")){
      return true;
    }else{
      return false;
    }
}
//group join or exit
Future toggleGroupExit(String groupId,String userName,String groupName)async{
    DocumentReference documentReference=userCollection.doc(uid);
    DocumentReference groupDoc=groupsCollection.doc(groupId);
    DocumentSnapshot documentSnapshot=await documentReference.get();
    List<dynamic> groups=await documentSnapshot['groups'];

    if(groups.contains("${groupId}_$groupName")){
      await documentReference.update({
        "groups":FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDoc.update({
        "members":FieldValue.arrayRemove(["${uid}_$userName"])
      });
    }


}
  Future toggleGroupJoin(String groupId,String userName,String groupName)async{
    DocumentReference documentReference=userCollection.doc(uid);
    DocumentReference groupDoc=groupsCollection.doc(groupId);
    await documentReference.update({
      "groups":FieldValue.arrayUnion(["${groupId}_$groupName"])
    });
    await groupDoc.update({
      "members":FieldValue.arrayUnion(["${uid}_$userName"])
    });
  }
  sendMessage(String groupId,Map<String,dynamic> chatMessageMap){
    groupsCollection.doc(groupId).collection("messages").add(chatMessageMap);
    groupsCollection.doc(groupId).update({
      "recentMessage":chatMessageMap['message'],
      "recentMessageSender":chatMessageMap["sender"],
      "recentMessageDate":chatMessageMap['time'].toString()
    });
  }
  clearMessages(String groupId)async{
    await groupsCollection.doc(groupId).collection("messages").get().then((snapshot)  {
      for(var ds in snapshot.docs){
        ds.reference.delete();
    }});
  }


}