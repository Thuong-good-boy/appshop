import 'package:flutter/material.dart';
import 'package:shopnew/widget/support_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List categories = [
    "images/headphone_icon.png",
    "images/laptop.png",
    "images/TV.png",
    "images/watch.png",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: Container(
        margin: EdgeInsets.only(top: 50.0,left: 20.0,right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hey, Thương",style: Appwidget.boldTextStyle()),
                    Text("Google morning",style: Appwidget.lightTextStyle(),)
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset("images/boy.jpg",height: 70,width: 70,fit: BoxFit.cover,),
                )

              ],

            ),
            SizedBox(height: 30.0,),
            Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  decoration: InputDecoration(border: InputBorder.none,hintText: "Search product",
                      hintStyle: Appwidget.lightTextStyle(),prefixIcon: Icon(Icons.search,color: Colors.black,)),
                )
            ),
            SizedBox(height: 20.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Categories",style: Appwidget.semiboldTextStyle(),),
                Text("See All",style: TextStyle(color: Color(0xFFfd6f3e),fontSize: 18.0,fontWeight: FontWeight.w500),)
              ],
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  padding: EdgeInsets.all(20),
                  height: 130.0,
                  decoration: BoxDecoration(
                      color: Color(0xFFfd6f3e),
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Center(child: Text("All",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20.0))),
                )
                ,
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 20.0,left: 20.0),
                    height: 130,
                    child: ListView.builder(
                      itemCount: categories.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context,index) {
                        return CategoryTile(image: categories[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("All Products",style: Appwidget.semiboldTextStyle(),),
                Text("See All",style: TextStyle(color: Color(0xFFfd6f3e),fontSize: 18.0,fontWeight: FontWeight.w500),)
              ],
            ),
            SizedBox(height: 20.0,),
            Container(
              height: 240,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [Container(
                  decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10.0)),
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  margin: EdgeInsets.only(right: 20.0),
                  child: Column(
                    children: [
                      Image.asset("images/headphone2.png",height: 150, width: 150,fit: BoxFit.cover,),
                      Text("Headphone",style: Appwidget.semiboldTextStyle(),),
                      SizedBox(height: 10,),
                      Row(

                        children: [
                          Text("\$100",style: TextStyle(color: Color(0xFFfd6f3e), fontWeight: FontWeight.bold,fontSize: 22.0),)
                          ,SizedBox(width: 40.0,),
                          Container(
                            decoration: BoxDecoration(color: Color(0xFFfd6f3e),borderRadius: BorderRadius.circular(5)),
                            child: Icon(Icons.add,color: Colors.white),)

                        ],
                      )
                    ],
                  ),
                ),Container(
                  decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10.0)),
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  margin: EdgeInsets.only(right: 20.0),
                  child: Column(
                    children: [
                      Image.asset("images/watch2.png",height: 150, width: 150,fit: BoxFit.cover,),
                      Text("Apple Watch",style: Appwidget.semiboldTextStyle(),),
                      SizedBox(height: 10,),
                      Row(

                        children: [
                          Text("\$50",style: TextStyle(color: Color(0xFFfd6f3e), fontWeight: FontWeight.bold,fontSize: 22.0),)
                          ,SizedBox(width: 40.0,),
                          Container(
                            decoration: BoxDecoration(color: Color(0xFFfd6f3e),borderRadius: BorderRadius.circular(5)),
                            child: Icon(Icons.add,color: Colors.white),)

                        ],
                      )
                    ],
                  ),
                ),Container(
                  decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10.0)),

                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Image.asset("images/laptop2.png",height: 150, width: 150,fit: BoxFit.cover,),
                      Text("Laptop",style: Appwidget.semiboldTextStyle(),),
                      SizedBox(height: 10,),
                      Row(

                        children: [
                          Text("\$1000",style: TextStyle(color: Color(0xFFfd6f3e), fontWeight: FontWeight.bold,fontSize: 22.0),)
                          ,SizedBox(width: 40.0,),
                          Container(
                            decoration: BoxDecoration(color: Color(0xFFfd6f3e),borderRadius: BorderRadius.circular(5)),
                            child: Icon(Icons.add,color: Colors.white),)

                        ],
                      )
                    ],
                  ),
                )

                ],
              ),
            ),
          ],

        ),
      ),
    );
  }

}
class CategoryTile extends StatelessWidget {
  String image;
  CategoryTile({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.only(right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(image,height: 50.0,width: 50.0,fit: BoxFit.cover,),
          Icon(Icons.arrow_forward)
        ],
      ),
    );
  }
}
