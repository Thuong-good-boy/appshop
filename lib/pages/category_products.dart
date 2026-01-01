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

  getontheload() async {
    CategoryStream = await DatabaseMethods().getProducts(widget.category);
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  Widget allProducts() {
    return StreamBuilder(
        stream: CategoryStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                return Container(
                  margin: EdgeInsets.all(5), // Thêm margin để không bị dính sát lề
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Padding(
                    padding: EdgeInsets.all(10.0), // Padding bọc nội dung
                    child: Column( // Bỏ Expanded đi, dùng Column trực tiếp
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ảnh sản phẩm
                        Center(
                          child: Image.network(
                            ds["Image"],
                            height: 120,
                            width: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
                          ),
                        ),
                        SizedBox(height: 10.0),

                        // Tên sản phẩm
                        Text(
                          ds["Name"],
                          style: Appwidget.semiboldTextStyle(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Spacer(), // Dùng Spacer để đẩy giá xuống đáy (chỉ hoạt động trong Column/Row có chiều cao cố định)

                        // Giá và nút cộng
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ds["Price"],
                              style: TextStyle(
                                  color: Color(0xFFfd6f3e),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProductDeTail(
                                            id: ds.id, // Sửa lỗi lấy ID: dùng ds.id
                                            name: ds["Name"],
                                            image: ds["Image"],
                                            detail: ds["Detail"],
                                            price: ds["Price"])));
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Color(0xFFfd6f3e),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Icon(Icons.add, color: Colors.white, size: 20),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              })
              : Center(child: CircularProgressIndicator()); // Thêm loading khi chưa có data
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      appBar: AppBar(
        backgroundColor: Color(0xfff2f2f2),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(widget.category, style: Appwidget.boldTextStyle()), // Hiển thị tên danh mục
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Column(
          children: [Expanded(child: allProducts())],
        ),
      ),
    );
  }
}