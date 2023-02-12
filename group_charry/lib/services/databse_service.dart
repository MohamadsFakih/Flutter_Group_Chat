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

}