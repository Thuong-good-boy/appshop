import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{
  Future addUserDetails(Map<String,dynamic> userInfoMap, String id) async{
        return await  FirebaseFirestore.instance.collection("users").doc(id).set(userInfoMap);
  }
  Future addProduct(Map<String,dynamic> userInfoMap, String categoryname) async{
    return await  FirebaseFirestore.instance.collection(categoryname).add(userInfoMap);
  }
  Future<Stream<QuerySnapshot>>getProducts (String category) async {
        return  await FirebaseFirestore.instance.collection(category).snapshots();
  }
  Future<Stream<QuerySnapshot>>getOrder (String email) async {
    return  await FirebaseFirestore.instance.collection("Orders").where("Email",isEqualTo: email).snapshots();
  }
  Future orderDetails(Map<String,dynamic> userInfoMap) async{
    return await  FirebaseFirestore.instance.collection("Orders").add(userInfoMap);
  }
}