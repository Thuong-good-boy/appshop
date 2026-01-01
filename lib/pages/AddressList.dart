import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopnew/Auth-Pages/Login.dart';
import 'package:shopnew/pages/Address.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';

class Addresslist extends StatefulWidget {
  const Addresslist({super.key});

  @override
  State<Addresslist> createState() => _AddresslistState();
}

class _AddresslistState extends State<Addresslist> {
  Stream? streamAddressList;
  List<DocumentSnapshot> addressItems = [];
  String? email;

  getontheload() async {
    email = await Share_pref().getUserEmail();
    if (email != null) {
      streamAddressList = DatabaseMethods().getListAddress(email!);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    }
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    getontheload();
    // TODO: implement initState

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Địa chỉ của ban."),
        backgroundColor: Color(0xfff2f2f2),
      ),
      backgroundColor: Color(0xfff2f2f2),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddressPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFfd6f3e),
      ),
      body: StreamBuilder(
        stream: streamAddressList,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
            return Center(child: Text("Danh sách địa chỉ trống"));
          }
          addressItems = snapshot.data.docs;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(15),
                  itemCount: addressItems.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = addressItems[index];
                    return Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${ds["Name"]} | ${ds["Phone"]}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async{
                                  bool? confirmDelete = await showDialog(context: context, builder: (context)=>AlertDialog(
                                      title: Text("Xác nhận xóa"),
                                      content: Text("Bạn có chắc muốn xóa địa chỉ này?"),
                                    actions: [
                                      TextButton(onPressed: ()=> Navigator.pop(context,false), child: Text("Hủy")),
                                      TextButton(onPressed: ()=>Navigator.pop(context,true), child: Text("Xóa",style: TextStyle(color: Colors.redAccent),))
                                    ],
                                  ));
                                  if(confirmDelete == true){
                                    await DatabaseMethods().deleteAddress(ds.id);
                                  }
                                },
                                child: Text(
                                  "xóa",
                                  style: TextStyle(
                                    color: Color(0xFFfd6f3e),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Addresslist(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Chọn",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "${ds["Line"]}, ${ds["Ward"]}, ${ds["District"]}, ${ds["City"]}",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
