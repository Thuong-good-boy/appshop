import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopnew/pages/ProductDeTail.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/widget/support_widget.dart';
class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? email;
  getthesharedpref()async{
    email= await Share_pref().getUserEmail();
    setState(() {

    });
  }
  Stream? orderStream;
  getontheload() async{
    await  getthesharedpref();
    orderStream = await DatabaseMethods().getOrder(email!);
    setState(() {

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getontheload();
  }
  Widget allOrder(){
    return StreamBuilder(
        stream: orderStream,
        builder: (context, AsyncSnapshot snapshot){
          return snapshot.hasData?
          ListView.builder(
              padding:  EdgeInsets.zero,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context,index){
                DocumentSnapshot ds=  snapshot.data.docs[index];
                return Container(
                   margin: EdgeInsets.only(bottom: 30.0),
                  child: Material(

                    elevation: 3.0,
                    borderRadius:  BorderRadius.circular(10),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(right: 20.0,top: 10.0,bottom: 1.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:  BorderRadius.circular(10)
                      ),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(ds["ProductImage"],width: 120.0, height: 120.0,fit:BoxFit.cover,)),
                            SizedBox(width: 10.0,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ds["Product"],style: Appwidget.semiboldTextStyle(),maxLines: 2, overflow: TextOverflow.ellipsis,),
                                  Text(ds["Price"],style: TextStyle(color: Color(0xFFfd6f3e), fontWeight: FontWeight.bold,fontSize: 22.0),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                  Text(ds["Status"],style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,fontSize: 18.0),maxLines: 2,overflow: TextOverflow.ellipsis,)

                                ],
                              ),
                            )
                          ],
                        
                        ),
                      
                    ),

                  ),
                );
              })
          : Container();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      appBar: AppBar(
        backgroundColor: Color(0xfff2f2f2),
        title: Text("Lịch sử mua hàng", style: Appwidget.semiboldTextStyle(),),
      ),
      body: Container(
        margin:  EdgeInsets.only(right: 20.0,left: 20.0),
        child: Column(
          children: [
            Expanded(child: allOrder()),

          ],
        ),
      ),
    );
  }
}
