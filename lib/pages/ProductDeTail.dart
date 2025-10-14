import 'package:flutter/material.dart';
import 'package:shopnew/widget/support_widget.dart';
class ProductDeTail extends StatefulWidget {
  String name, image,detail, price;
  ProductDeTail({required this.name,required this.image,required this.detail, required this.price});

  @override
  State<ProductDeTail> createState() => _ProductDeTailState();
}

class _ProductDeTailState extends State<ProductDeTail> {

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
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0),color: Color(0xFFfd6f3e) ),
                            child: Center(child: Text("Mua ngay",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 22.0),)),
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
}
