import 'package:flutter/material.dart';
import 'package:shopnew/Admin/AddProduct.dart';
import 'package:shopnew/Admin/ManageProduct.dart';
import 'package:shopnew/Admin/all_orders.dart';
import 'package:shopnew/Admin/manage_users.dart';
import 'package:shopnew/Admin/statistics.dart';
import 'package:shopnew/widget/support_widget.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.black),
            SizedBox(width: 10),
            Text("Admin Dashboard", style: Appwidget.boldTextStyle()),
          ],
        ),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- PHẦN THỐNG KÊ NHANH (HEADER) ---
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFfd6f3e), Color(0xffff9f7f)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Color(0xFFfd6f3e).withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Xin chào, Admin!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("Chúc bạn một ngày làm việc hiệu quả.", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              SizedBox(height: 30.0),

              Text("Chức năng quản lý", style: Appwidget.boldTextStyle()),
              SizedBox(height: 20.0),

              // --- GRID CÁC CHỨC NĂNG ---
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // Để scroll theo parent
                crossAxisCount: 2, // 2 cột
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.1, // Tỉ lệ khung hình
                children: [
                  // 1. Thêm sản phẩm
                  _buildMenuCard(
                    title: "Add Product",
                    icon: Icons.add_circle_outline,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddProduct()));
                    },
                  ),

                  _buildMenuCard(
                    title: "Duyệt đơn",
                    icon: Icons.shopping_bag_outlined,
                    color: Color(0xFFfd6f3e),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AllOrders()));
                    },
                  ),

                  // 3. Quản lý kho (All Products) - Sẽ làm sau
                  _buildMenuCard(
                    title: "Kho hàng",
                    icon: Icons.inventory_2_outlined,
                    color: Colors.blueAccent,
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => ManageProduct()));
                    },
                  ),

                  // 4. Quản lý người dùng (Users) - Sẽ làm sau
                  _buildMenuCard(
                    title: "Users",
                    icon: Icons.group_outlined,
                    color: Colors.purpleAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> ManageUsers()));
                    },
                  ),
                  _buildMenuCard(
                    title: "Thống kê", // Đổi tên nút thành Thống kê cho hợp
                    icon: Icons.bar_chart_rounded,
                    color: Colors.purpleAccent,
                    onTap: () {
                      // BỎ COMMENT DÒNG NÀY VÀ SỬA TÊN CLASS
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Statistics()));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Card Tùy Chỉnh (Giúp code gọn hơn) ---
  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1), // Màu nền nhạt theo màu icon
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40.0, color: color),
              ),
              SizedBox(height: 15.0),
              Text(
                title,
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}