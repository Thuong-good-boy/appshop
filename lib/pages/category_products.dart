import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopnew/pages/ProductDeTail.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/widget/support_widget.dart';
class CategoryProducts extends StatefulWidget {
String category;
CategoryProducts({required this.category});

  @override
  State<CategoryProducts> createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  Stream? CategoryStream;
  getontheload() async{
    CategoryStream = await DatabaseMethods().getProducts(widget.category);
    setState(() {
      
    });
  }
  @override
  void initState() {
    getontheload();
    super.initState();
  }
  Widget allProducts(){
    return StreamBuilder(stream: CategoryStream, builder: (context, AsyncSnapshot snapshot){
      return snapshot.hasData? GridView.builder(
        padding:  EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              mainAxisSpacing: 10.0 ,
              crossAxisSpacing: 10.0),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context,index){
                DocumentSnapshot ds=  snapshot.data.docs[index];
                return Container(
                  height: 240,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10.0)),
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Expanded(
                        child: Container(
                          padding: EdgeInsets.only(top: 10.0,bottom: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(ds["Image"],height: 150, width:150,fit: BoxFit.cover,),
                              SizedBox(height: 30.0,),
                              Text(ds["Name"],style: Appwidget.semiboldTextStyle(),maxLines: 2,overflow: TextOverflow.ellipsis,),
                              Spacer(),

                              Row(

                                children: [
                                  Text(ds["Price"],style: TextStyle(color: Color(0xFFfd6f3e), fontWeight: FontWeight.bold,fontSize: 22.0),maxLines: 2,overflow: TextOverflow.ellipsis,)
                                  ,SizedBox(width: 5.0,),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> ProductDeTail(name: ds["Name"], image: ds["Image"], detail: ds["Detail"], price: ds["Price"])));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(color: Color(0xFFfd6f3e),borderRadius: BorderRadius.circular(5)),
                                      child: Icon(Icons.add,color: Colors.white),),
                                  )

                                ],
                              )
                            ],
                          ),
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
          backgroundColor: Color(0xfff2f2f2)
      ),
      body: Container(
        child: Column(
          children: [Expanded(child: allProducts())],
        ),
      ),
    );
  }
}
