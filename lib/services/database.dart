import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shopnew/pages/Address.dart';

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }
  Future<DocumentSnapshot> getUserbyUid(String uid) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
  }
  Future addProduct(
    Map<String, dynamic> userInfoMap,
    String categoryname,
  ) async {
    return await FirebaseFirestore.instance
        .collection(categoryname)
        .add(userInfoMap);
  }

  Future addAllProducts(Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("Products")
        .add(userInfoMap);
  }
  Future <void> deleteAddress(String docId) async{
    await FirebaseFirestore.instance.collection("Address").doc(docId).delete();
}

  Stream<QuerySnapshot> getProducts(String category)  {
    return  FirebaseFirestore.instance.collection(category).snapshots();
  }
  Stream<QuerySnapshot> getListAddress(String email) {
    return FirebaseFirestore.instance.collection("Address").where("Email",isEqualTo: email).snapshots();
  }
  Stream<QuerySnapshot> getAddress (String email) {
   return  FirebaseFirestore.instance.collection("Address").where("Email",isEqualTo: email).limit(1).snapshots();

  }
  Stream<QuerySnapshot> getAllProducts() {
    return FirebaseFirestore.instance.collection("Products").snapshots();
  }

  Future<Stream<QuerySnapshot>> getOrder(String email) async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .where("Email", isEqualTo: email)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getAllOrder() async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .where("Status", isEqualTo: "Đang vận chuyển.")
        .snapshots();
  }

  Future orderDetails(Map<String, dynamic> orderInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .add(orderInfoMap);
  }

  Future<void> addProductToCart(String email, Map<String, dynamic> productInfoMap) async {
    String productId = productInfoMap["ProductId"];
    int quantityToAdd = productInfoMap["Count"] ?? 1;
    CollectionReference cartRef = FirebaseFirestore.instance
        .collection("Shoppings")
        .doc(email)
        .collection("Shopping");

    QuerySnapshot query = await cartRef
        .where("ProductId", isEqualTo: productId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      DocumentSnapshot doc = query.docs.first;
      await doc.reference.update({
        "Count": FieldValue.increment(quantityToAdd)
      });
    } else {
      await cartRef.add(productInfoMap);
    }
  }

  Stream<QuerySnapshot> getShopping(String email)  {
    return FirebaseFirestore.instance
        .collection("Shoppings")
        .doc(email).collection("Shopping")
        .snapshots();
  }
  Future<void> updateShopping(String email,String docId, Map<String, dynamic> data) async{
    return  FirebaseFirestore.instance
        .collection("Shoppings")
        .doc(email).collection("Shopping").doc(docId).update(data);
  }
  Future<void> deleteShopping(String email,String docId) async{
    return await FirebaseFirestore.instance.collection("Shoppings").doc(email).collection("Shopping").doc(docId).delete();
  }

  Future Address(Map<String,dynamic> addressInfoMap) async{
    return await FirebaseFirestore.instance.collection("Address").add(addressInfoMap);
  }
  upDateStatus(String id) async {
    return await FirebaseFirestore.instance.collection("Orders").doc(id).update(
      {"Status": "Đã giao"},
    );
  }

  Future<QuerySnapshot> search(String updatedname) async {
    return await FirebaseFirestore.instance
        .collection("Products")
        .where(
          "SearchKey",
          isEqualTo: updatedname.substring(0, 1).toUpperCase(),
        )
        .get();
  }
  Future<void> deleteOrder(String id) async {
    return await FirebaseFirestore.instance.collection("Orders").doc(id).delete();
  }



}
