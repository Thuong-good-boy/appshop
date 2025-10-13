import 'package:flutter/material.dart';
import 'package:shopnew/widget/support_widget.dart';
class ProductDeTail extends StatefulWidget {
  const ProductDeTail({super.key});

  @override
  State<ProductDeTail> createState() => _ProductDeTailState();
}

class _ProductDeTailState extends State<ProductDeTail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body:
      Container(
        margin: EdgeInsets.only(top: 50.0,),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Stack(
                  children:[ GestureDetector(
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
                    Center(child: Image.asset("images/headphone2.png",height: 400,)),
                  ]),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:  BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)) ),
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    margin: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Headphone",style: Appwidget.boldTextStyle(),),
                            Text("\$300",style: TextStyle(color: Color(0xFFfd6f3e),fontSize: 22.0,fontWeight: FontWeight.bold),)
                          ],

                        ),
                        SizedBox(height: 20.0,),
                        Text("Chi tiết",style: Appwidget.semiboldTextStyle(),),
                        SizedBox(height: 10.0,),
                        Text("Sản phẩm rất tốt. Bảo hành 1 năm. Tai nghe này quá tốt, bạn có "
                            "thể nghe được cả người nói chậm. Nhưng lưu ý là Shivam nói rất to."),
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
              )

            ]),
      ),
    );
  }
}
