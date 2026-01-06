import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:shopnew/pages/ChatbotPage.dart';
import 'package:shopnew/pages/ProductDeTail.dart';
import 'package:shopnew/pages/category_products.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/services/theme_provider.dart'; // Đảm bảo đường dẫn đúng
import 'package:shopnew/widget/support_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream? CategoryStream;
  bool search = false;

  // Danh sách danh mục
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
  TextEditingController searchcontroller = TextEditingController();

  String? name, image;

  // --- Logic Tìm kiếm ---
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
        Map<String, dynamic> data = docs.docs[i].data() as Map<String, dynamic>;
        data["Id"] = docs.docs[i].id; // Lấy ID document
        queryResultSet.add(data);
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

  getthesharedpredf() async {
    name = await Share_pref().getUserName();
    image = await Share_pref().getUserImage();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpredf();
    CategoryStream = DatabaseMethods().getAllProducts();
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // --- Lấy Theme ---
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Màu sắc động
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      // --- Nút Chatbot ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ChatbotPage()));
        },
        backgroundColor: Color(0xFFfd6f3e),
        elevation: 10.0,
        shape: CircleBorder(), // Bo tròn hoàn toàn
        child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 30),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: name == null
              ? Container(
              height: MediaQuery.of(context).size.height,
              child: Center(child: CircularProgressIndicator(color: Colors.orange)))
              : Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header (Avatar + Hello) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Xin chào, " + name!,
                          style: Appwidget.boldTextStyle().copyWith(
                            color: textColor,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "Chúc bạn một ngày tốt lành!",
                          style: Appwidget.lightTextStyle().copyWith(
                            color: subTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          image!,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.person, size: 60, color: subTextColor),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.0),

                // --- Search Box ---
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: searchcontroller,
                    style: TextStyle(color: textColor),
                    onChanged: (value) {
                      initiateSearch(value.toUpperCase());
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Tìm kiếm sản phẩm...",
                      hintStyle: TextStyle(color: subTextColor),
                      prefixIcon: Icon(Icons.search, color: subTextColor),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      suffixIcon: search
                          ? GestureDetector(
                        onTap: () {
                          search = false;
                          tempSearchStore = [];
                          queryResultSet = [];
                          searchcontroller.text = "";
                          setState(() {});
                        },
                        child: Icon(Icons.close, color: subTextColor),
                      )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),

                // --- Search Results Logic ---
                search
                    ? ListView.builder(
                  padding: EdgeInsets.zero,
                  primary: false,
                  shrinkWrap: true,
                  itemCount: tempSearchStore.length,
                  itemBuilder: (context, index) {
                    return buildResultCard(
                        tempSearchStore[index], cardColor, textColor);
                  },
                )
                    : Column(
                  children: [
                    // --- Categories Header ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Danh mục",
                            style: Appwidget.semiboldTextStyle().copyWith(color: textColor)),
                        Text(
                          "Xem tất cả",
                          style: TextStyle(
                            color: Color(0xFFfd6f3e),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.0),

                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          height: 110.0,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Color(0xFFfd6f3e),
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFfd6f3e).withOpacity(0.4),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("All",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0)),
                              SizedBox(height: 5),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Container(
                            height: 110,
                            child: ListView.builder(
                              itemCount: categories.length,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return CategoryTile(
                                  image: categories[index],
                                  name: categoryName[index],
                                  cardColor: cardColor,
                                  textColor: textColor,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Sản phẩm nổi bật",
                            style: Appwidget.semiboldTextStyle().copyWith(color: textColor)),
                        Text(
                          "Xem tất cả",
                          style: TextStyle(
                            color: Color(0xFFfd6f3e),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),

                    Container(
                      height: 280, // Tăng chiều cao để thẻ thoáng hơn
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
                                ds.data() as Map<String, dynamic>;
                                String id = ds.id;

                                return _buildProductCard(
                                  context,
                                  id,
                                  data,
                                  cardColor,
                                  textColor,
                                  subTextColor,
                                );
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text("Lỗi tải dữ liệu", style: TextStyle(color: textColor)));
                          } else {
                            return Center(child: CircularProgressIndicator(color: Colors.orange));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget hiển thị 1 thẻ sản phẩm
  Widget _buildProductCard(BuildContext context, String id, Map<String, dynamic> data,
      Color cardColor, Color textColor, Color subTextColor) {
    String name = data["Name"] ?? "No Name";
    String image = data["Image"] ?? "";
    String price = data["Price"] ?? "0";
    String detail = data["Detail"] ?? "";

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDeTail(
                    id: id,
                    name: name,
                    image: image,
                    detail: detail,
                    price: price)));
      },
      child: Container(
        width: 220.0,
        margin: EdgeInsets.only(right: 20.0, bottom: 10.0, top: 5.0), // Margin top bottom cho shadow
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  image,
                  height: 140,
                  width: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(height: 140, width: 140, color: Colors.grey[200], child: Icon(Icons.image_not_supported)),
                ),
              ),
            ),
            SizedBox(height: 10),
            // Tên sản phẩm
            Text(
              name,
              style: Appwidget.semiboldTextStyle().copyWith(
                color: textColor,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 5),
            // Giá tiền + Nút Add
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$" + price,
                  style: TextStyle(
                    color: Color(0xFFfd6f3e),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFfd6f3e),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data, Color cardColor, Color textColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDeTail(
              id: data["Id"],
              name: data["Name"],
              image: data["Image"],
              detail: data["Detail"],
              price: data["Price"],
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                data["Image"],
                height: 70.0,
                width: 70.0,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
              ),
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["Name"],
                    style: Appwidget.semiboldTextStyle().copyWith(color: textColor, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "\$${data["Price"]}",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// Widget Danh mục (Tách riêng để code gọn)
class CategoryTile extends StatelessWidget {
  final String image, name;
  final Color cardColor;
  final Color textColor;

  CategoryTile({
    required this.image,
    required this.name,
    required this.cardColor,
    required this.textColor
  });

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
        width: 90, // Cố định chiều rộng để đều nhau
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 3),
            )
          ],
        ),
        margin: EdgeInsets.only(right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              height: 40.0,
              width: 40.0,
              fit: BoxFit.contain, // Đổi thành contain để ảnh không bị méo
              errorBuilder: (context, error, stackTrace) => Icon(Icons.category, color: textColor),
            ),
            SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}