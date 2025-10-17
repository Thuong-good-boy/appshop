import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/widget/support_widget.dart';

class AllOrders extends StatefulWidget {
  const AllOrders({super.key});

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  Set<String> _loadingItems = {};
  Stream? orderStream;

  ontheload() async {
    orderStream = await DatabaseMethods().getAllOrder();
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    // TODO: implement initState
    super.initState();
  }

  Widget allOrder() {
    return StreamBuilder(
      stream: orderStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  String docId = ds.id;
                  bool isThisItemLoading = _loadingItems.contains(docId);
                  return Container(
                    margin: EdgeInsets.only(bottom: 30.0),
                    child: Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                          right: 20.0,
                          top: 10.0,
                          bottom: 1.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                ds["Image"] + "&format=png",
                                width: 120.0,
                                height: 120.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name : " + ds["Name"],
                                    style: Appwidget.semiboldTextStyle(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "Email : " + ds["Email"],
                                    style: Appwidget.lightTextStyle(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    ds["Product"],
                                    style: Appwidget.semiboldTextStyle(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    ds["Price"],
                                    style: TextStyle(
                                      color: Color(0xFFfd6f3e),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 20.0),
                                  GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        if (isThisItemLoading) return;

                                        setState(() {
                                          _loadingItems.add(
                                            docId,
                                          ); // Báo là item NÀY bắt đầu load
                                        });
                                      });
                                      try {
                                        await DatabaseMethods().upDateStatus(
                                          ds.id,
                                        );
                                      } catch (e) {
                                        print("Lỗi update done $e");
                                      } finally {
                                        setState(() {
                                          _loadingItems.remove(
                                            docId,
                                          ); // Báo là item NÀY đã load xong
                                        });
                                      }
                                    },

                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 10.0),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 7.0,
                                      ),
                                      width: 120.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFfd6f3e),
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: isThisItemLoading
                                            ? CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : Text(
                                                "Done",
                                                style:
                                                    Appwidget.semiboldTextStyle(),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Tất cả đơn hàng ", style: Appwidget.boldTextStyle()),
        ),
      ),
      body: Container(
        child: Column(children: [Expanded(child: allOrder())]),
      ),
    );
  }
}
