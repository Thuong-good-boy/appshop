import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopnew/pages/ProductDeTail.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/theme_provider.dart';
import 'package:shopnew/widget/support_widget.dart';

class CategoryProducts extends StatefulWidget {
  final String category;
  const CategoryProducts({super.key, required this.category});

  @override
  State<CategoryProducts> createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  Stream? CategoryStream;

  getontheload() async {
    CategoryStream = await DatabaseMethods().getProducts(widget.category);
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  // Widget hiển thị danh sách sản phẩm
  Widget allProducts(Color cardColor, Color textColor) {
    return StreamBuilder(
      stream: CategoryStream,
      builder: (context, AsyncSnapshot snapshot) {
        // Kiểm tra dữ liệu
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data.docs.isEmpty) {
          return Center(
            child: Text("Không có sản phẩm nào",
                style: TextStyle(color: textColor, fontSize: 16)),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.70, // Tỷ lệ thẻ sản phẩm (cao/rộng)
            mainAxisSpacing: 15.0,
            crossAxisSpacing: 15.0,
          ),
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return GestureDetector(
              onTap: () {
                // Chuyển sang trang chi tiết
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDeTail(
                      id: ds.id,
                      name: ds["Name"],
                      image: ds["Image"],
                      detail: ds["Detail"],
                      price: ds["Price"],
                    ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: cardColor, // Màu nền thẻ thay đổi theo Theme
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Ảnh sản phẩm
                      Expanded(
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              ds["Image"],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image_not_supported, color: textColor),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),

                      // 2. Tên sản phẩm
                      Text(
                        ds["Name"],
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: textColor, // Màu chữ thay đổi theo Theme
                          fontFamily: 'Poppins', // Nếu có font này
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5.0),

                      // 3. Giá và Nút mũi tên
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Giá tiền (Bọc Expanded để tránh tràn nếu giá quá dài)
                          Expanded(
                            child: Text(
                              ds["Price"],
                              style: TextStyle(
                                color: Color(0xFFfd6f3e),
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Nút mũi tên
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Color(0xFFfd6f3e),
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 14),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lấy Theme hiện tại
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // 2. Thiết lập bộ màu sắc
    final Color bgColor = isDark ? Color(0xFF121212) : Color(0xfff2f2f2);
    final Color cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor, // Màu nền chính
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
        ),
        title: Text(
          widget.category,
          style: TextStyle(
            color: textColor,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            // Gọi widget hiển thị danh sách
            Expanded(child: allProducts(cardColor, textColor))
          ],
        ),
      ),
    );
  }
}