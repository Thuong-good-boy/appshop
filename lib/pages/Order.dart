import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/services/theme_provider.dart'; // Import theme
import 'package:shopnew/widget/support_widget.dart';
import 'package:intl/intl.dart'; // Cần thêm package này vào pubspec.yaml nếu chưa có: intl: ^0.18.1

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  String? email;
  Stream? orderStream;

  getthesharedpref() async {
    email = await Share_pref().getUserEmail();
    setState(() {});
  }

  getontheload() async {
    await getthesharedpref();
    if (email != null) {
      // Hàm getOrder trong DatabaseMethods cần trả về stream collection "Orders" của user
      orderStream = await DatabaseMethods().getOrder(email!);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  // Widget hiển thị danh sách sản phẩm nhỏ trong 1 đơn hàng
  Widget buildProductList(List<dynamic> products, Color textColor) {
    return Column(
      children: products.map((item) {
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item["Image"],
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["Name"],
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "x${item["Count"]}",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                item["Tong"] ?? "", // Giá tổng của item đó
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget allOrder(Color cardColor, Color textColor) {
    return StreamBuilder(
      stream: orderStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Bạn chưa có đơn hàng nào", style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ));
        }

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 20, top: 10),
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            Map<String, dynamic> data = ds.data() as Map<String, dynamic>;

            // Lấy dữ liệu an toàn
            List<dynamic> products = data["Products"] ?? [];
            String status = data["Status"] ?? "Đang xử lý";
            String total = data["Total"] ?? "0₫";
            Timestamp? timestamp = data["OrderTimestamp"];

            String dateStr = timestamp != null
                ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate())
                : "N/A";

            return Container(
              margin: EdgeInsets.only(bottom: 20.0),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header: Mã đơn / Ngày / Status ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Ngày: $dateStr", style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: status == "Đang vận chuyển." ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: status == "Đang vận chuyển." ? Colors.blue : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.withOpacity(0.3), height: 20),

                  // --- Body: Danh sách sản phẩm ---
                  products.isNotEmpty
                      ? buildProductList(products, textColor)
                      : Text("Không có thông tin sản phẩm", style: TextStyle(color: textColor)),

                  Divider(color: Colors.grey.withOpacity(0.3), height: 20),

                  // --- Footer: Tổng tiền ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tổng tiền thanh toán", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                      Text(
                        total,
                        style: TextStyle(
                          color: Color(0xFFfd6f3e),
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Theme setup
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: bgColor, // Fix màu khi scroll
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Lịch sử đơn hàng",
          style: Appwidget.semiboldTextStyle().copyWith(color: textColor),
        ),
        leading: IconButton(
          onPressed: () {
            // Dùng pop vì trang này được push từ Shopping
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Expanded(child: allOrder(cardColor, textColor)),
          ],
        ),
      ),
    );
  }
}