import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopnew/pages/ProductDeTail.dart';
import 'package:shopnew/pages/category_products.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/widget/support_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream? CategoryStream;
  bool search = false;
  List categories = [
    "images/headphone_icon.png",
    "images/laptop.png",
    "images/TV.png",
    "images/watch.png",
    "images/iphone.png",
  ];
  List categoryName = ["Headphone", "Laptop", "TV", "Watch", "Phone"];
  var queryResultSet = [];
  var tempSearchStore = [];
  TextEditingController searchcontroller = new TextEditingController();

  initiateSearch(value) async {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
        search = false;
      });
      return;
    }
    if (search == false) {
      setState(() {
        search = true;
      });
    }
    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.isEmpty) {
      String firstLetter = value.substring(0, 1).toUpperCase();
      QuerySnapshot docs = await DatabaseMethods().search(firstLetter);
      for (int i = 0; i < docs.docs.length; i++) {
        queryResultSet.add(docs.docs[i].data());
      }
    }

    tempSearchStore = [];
    queryResultSet.forEach((element) {
      if (element["UpdateName"].startsWith(capitalizedValue)) {
        tempSearchStore.add(element);
      }
    });
    setState(() {});
  }

  String? name, image;

  getthesharedpredf() async {
    name = await Share_pref().getUserName();
    image = await Share_pref().getUserImage();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpredf();
    CategoryStream =  DatabaseMethods().getAllProducts();
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: name == null
          ? Center(child: CircularProgressIndicator())
          : Container(
        margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hey, " + name!,
                      style: Appwidget.boldTextStyle(),
                    ),
                    Text(
                      "Google morning",
                      style: Appwidget.lightTextStyle(),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    image!,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),

            SizedBox(height: 30.0),

            // Search box
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: searchcontroller,
                onChanged: (value) {
                  initiateSearch(value.toUpperCase());
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search product",
                  hintStyle: Appwidget.lightTextStyle(),
                  prefixIcon: search
                      ? GestureDetector(
                    onTap: () {
                      search = false;
                      tempSearchStore = [];
                      queryResultSet = [];
                      searchcontroller.text = "";
                      setState(() {});
                    },
                    child: Icon(Icons.close),
                  )
                      : Icon(Icons.search, color: Colors.black),
                ),
              ),
            ),

            SizedBox(height: 20.0),

            // Search result
            search
                ? ListView(
              padding:
              EdgeInsets.only(left: 10.0, right: 10.0),
              primary: false,
              shrinkWrap: true,
              children: tempSearchStore
                  .map((element) => buildResultCard(element))
                  .toList(),
            )
                : Column(
              children: [
                // Categories header
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Categories",
                      style: Appwidget.semiboldTextStyle(),
                    ),
                    Text(
                      "See All",
                      style: TextStyle(
                        color: Color(0xFFfd6f3e),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Category tiles
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      padding: EdgeInsets.all(20),
                      height: 130.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFfd6f3e),
                        borderRadius:
                        BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Text(
                          "All",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          top: 20.0,
                          left: 20.0,
                        ),
                        height: 130,
                        child: ListView.builder(
                          itemCount: categories.length,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return CategoryTile(
                              image: categories[index],
                              name: categoryName[index],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30.0),

                // All Products
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "All Products",
                      style: Appwidget.semiboldTextStyle(),
                    ),
                    Text(
                      "See All",
                      style: TextStyle(
                        color: Color(0xFFfd6f3e),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.0),

                Container(
                  height: 260,
                  child: StreamBuilder(
                    stream: CategoryStream,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            DocumentSnapshot ds =
                            snapshot.data.docs[index];
                            Map<String, dynamic> data =
                            ds.data()
                            as Map<String, dynamic>;
                            String name = data["Name"];
                            String image = data["Image"];
                            String price = data["Price"];
                            String detail = data["Detail"];
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductDeTail(name: name, image: image, detail: detail, price: price)));
                              },
                              child: Container(
                                width: 250.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                ),
                                padding: EdgeInsets.all(
                                   10.0,
                                ),
                                margin: EdgeInsets.only(
                                    right: 20.0),
                                child: Column(
                                  children: [
                                    Image.network(
                                      image,
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    ),
                                    Text(
                                      name,
                                      style: Appwidget
                                          .semiboldTextStyle(), maxLines:  1, overflow:  TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Text(
                                          price,
                                          style: TextStyle(
                                            color:
                                            Color(0xFFfd6f3e),
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 22.0,
                                          ),maxLines:  1, overflow:  TextOverflow.ellipsis
                                        ),
                                        SizedBox(width: 30.0),
                                        Container(
                                          decoration:
                                          BoxDecoration(
                                            color:
                                            Color(0xFFfd6f3e),
                                            borderRadius:
                                            BorderRadius
                                                .circular(5),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Đã xảy ra lỗi!"));
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDeTail(
              name: data["Name"],
              image: data["Image"],
              detail: data["Detail"],
              price: data["Price"],
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 20.0),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        height: 100,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                data["Image"],
                height: 70.0,
                width: 70.0,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 20.0),
            Text(
              data["Name"],
              style: Appwidget.semiboldTextStyle(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  String image, name;

  CategoryTile({required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProducts(category: name),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(image, height: 50.0, width: 50.0, fit: BoxFit.cover),
            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
