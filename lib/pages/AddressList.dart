import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import 'package:shopnew/Auth-Pages/Login.dart';
import 'package:shopnew/pages/Address.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/services/theme_provider.dart'; // 2. Import ThemeProvider

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
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    Color bgColor = isDark ? Color(0xFF121212) : Color(0xfff2f2f2);
    Color cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Địa chỉ của bạn",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddressPage()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFFfd6f3e),
      ),
      body: StreamBuilder(
        stream: streamAddressList,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.docs.isEmpty) {
            return Center(
                child: Text("Danh sách địa chỉ trống",
                    style: TextStyle(color: textColor)));
          }

          addressItems = snapshot.data.docs;
          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: addressItems.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = addressItems[index];
              return Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 3),
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
                          ds["Name"],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          ds["Phone"],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    Text(
                      "${ds["Line"]}, ${ds["Ward"]}, ${ds["District"]}, ${ds["City"]}",
                      style: TextStyle(
                        fontSize: 15,
                        color: subTextColor,
                        height: 1.4,
                      ),
                    ),

                    Divider(color: Colors.grey.withOpacity(0.3)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            bool? confirmDelete = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: isDark ? Color(0xFF2C2C2C) : Colors.white,
                                  title: Text("Xác nhận xóa", style: TextStyle(color: textColor)),
                                  content: Text("Bạn có chắc muốn xóa địa chỉ này?", style: TextStyle(color: subTextColor)),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text("Hủy")),
                                    TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text("Xóa", style: TextStyle(color: Colors.redAccent)))
                                  ],
                                ));
                            if (confirmDelete == true) {
                              await DatabaseMethods().deleteAddress(ds.id);
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              SizedBox(width: 5),
                              Text("Xóa", style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, {
                              "Name": ds["Name"],
                              "Phone": ds["Phone"],
                              "Address": "${ds["Line"]}, ${ds["Ward"]}, ${ds["District"]}, ${ds["City"]}"
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.green)
                            ),
                            child: Text(
                              "Chọn dùng",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}