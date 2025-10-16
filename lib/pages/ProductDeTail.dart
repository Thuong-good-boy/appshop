import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopnew/services/constant.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/widget/support_widget.dart';
import 'package:http/http.dart' as http;
class ProductDeTail extends StatefulWidget {
  String name, image,detail, price;
  ProductDeTail({required this.name,required this.image,required this.detail, required this.price});

  @override
  State<ProductDeTail> createState() => _ProductDeTailState();
}

class _ProductDeTailState extends State<ProductDeTail> {
  bool _isLoading= false;
String? name, email,image;
getthesharedpref()async{
  name= await Share_pref().getUserName();
  email = await Share_pref().getUserEmail();
  image= await Share_pref().getUserImage();
}
ontheload()async{
  await getthesharedpref();
  setState(() {

  });
}
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    ontheload();
  }
  Map<String,dynamic>? paymentIntent;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body:
      SingleChildScrollView(

        child: Container(
          margin: EdgeInsets.only(top: 50.0,),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                    children:[
                      Center(child: Image.network(widget.image,height: 400,)),
                      GestureDetector(
                      onTap:() {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 20.0),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(border: Border.all(),borderRadius: BorderRadius.circular(30)),
                        child: Icon(Icons.arrow_back_ios_new_outlined),
                      ),
                    ),

                    ]),
                   Container(
                     padding: EdgeInsets.only(bottom:  30.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:  BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)) ),
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      margin: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.name,style: Appwidget.boldTextStyle(),maxLines: 3,overflow: TextOverflow.ellipsis,),
                          Text(widget.price,style: TextStyle(color: Color(0xFFfd6f3e),fontSize: 22.0,fontWeight: FontWeight.bold),),
                          SizedBox(height: 20.0,),
                          Text("Chi tiết",style: Appwidget.semiboldTextStyle(),),
                          SizedBox(height: 10.0,),
                          Text(widget.detail),
                          SizedBox(height: 120.0,),
                          GestureDetector(
                            onTap: () async{
                              if(_isLoading) return;
                              setState(() {
                                _isLoading =true;
                              });
                              try{
                                await makepayment(widget.price);
                              }catch(e){
                                print("có lỗi  $e");
                              }finally{
                                setState(() {
                                  _isLoading=false;
                                });
                              }

                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0),color: Color(0xFFfd6f3e) ),
                              child: Center(
                                  child: _isLoading ? CircularProgressIndicator(
                                    color: Colors.white,
                                  ) :Text("Mua ngay",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 22.0),)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

        
              ]),
        ),
      ),
    );
  }
  // {
  // "id": "pi_3OwK9JHYKhtkYp1T1s3WZBzM",
  // "object": "payment_intent",
  // "amount": 50000,
  // "currency": "vnd",
  // "client_secret": "pi_3OwK9JHYKhtkYp1T1s3WZBzM_secret_MiEc...",
  // "status": "requires_payment_method"
  // }
  Future<void> makepayment(String amount) async{
    try{
      paymentIntent = await createPaymentIntent(amount, 'vnd');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent?["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "ShopNew"
      )).then((value)=>{

      });
      displayPaymentSheet();
    }catch(e,s){
      print("exception $e$s");
    }
  }
  displayPaymentSheet() async {
    Map<String,dynamic> orderInfoMap={
      "Product": widget.name,
      "Price": widget.price,
      "Name": name,
      "Email":email,
      "Image":image,
      "ProductImage":widget.image,
      "Status": "Đang vận chuyển.",
    };
    await DatabaseMethods().orderDetails(orderInfoMap);
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        showDialog(context: context, builder: (_) =>
            AlertDialog(
              content: Column(mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.check_circle, color: Colors.green,),
                  Text("Payment Successfull")],
              ),
            ));
        paymentIntent = null;
      }).onError((error, stackTrace) {
        print("Error is : --> $error $stackTrace");
      });
    } on StripeException catch (e) {
      print("$e");
    }
  }
    createPaymentIntent(String amount, String currency) async{
      try{
        Map<String,dynamic> body={
          "amount": calculateAmount(amount),
          "currency": currency,
          "payment_method_types[]":"card"
        };
        var response= await http.post(Uri.parse("https://api.stripe.com/v1/payment_intents"),
            headers: {"Authorization":'Bearer $Secretkey',"Content-Type":"application/x-www-form-urlencoded",
            },body: body,
        );
        return jsonDecode(response.body);
      } catch (err){
        print("err charging user : ${err.toString()}");
      }
    }
    calculateAmount (String amount){
      final cleaneamount = amount.replaceAll(RegExp(r'\D'), '');
      return cleaneamount.toString();
    }

}