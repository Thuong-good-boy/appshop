import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Nhớ thêm intl vào pubspec.yaml

class AllOrders extends StatefulWidget {
  const AllOrders({super.key});

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  Stream? orderStream;

  // Hàm lấy dữ liệu Realtime
  getOntheLoad() async {
    orderStream = FirebaseFirestore.instance
        .collection("Orders")
        .orderBy('OrderDate', descending: true) // Mới nhất lên đầu
        .snapshots();
    setState(() {});
  }

  @override
  void initState() {
    getOntheLoad();
    super.initState();
  }

  // --- HÀM ĐỔI TRẠNG THÁI ĐƠN HÀNG ---
  void showStatusBottomSheet(String orderId, String currentStatus) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Cập nhật trạng thái", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              _buildStatusOption(orderId, "Đang xử lý", Colors.orange, currentStatus),
              _buildStatusOption(orderId, "Đang giao hàng", Colors.blue, currentStatus),
              _buildStatusOption(orderId, "Đã giao", Colors.green, currentStatus),
              _buildStatusOption(orderId, "Đã hủy", Colors.red, currentStatus),
            ],
          ),
        );
      },
    );
  }

  // Widget con cho từng dòng trạng thái
  Widget _buildStatusOption(String docId, String status, Color color, String currentStatus) {
    bool isSelected = status == currentStatus;
    return ListTile(
      leading: Icon(Icons.circle, color: color, size: 14),
      title: Text(status, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? color : Colors.black)),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () async {
        Navigator.pop(context); // Đóng menu
        await FirebaseFirestore.instance.collection("Orders").doc(docId).update({
          "Status": status
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã chuyển sang: $status")));
      },
    );
  }

  // Hàm format tiền
  String formatCurrency(String priceRaw) {
    // Xử lý chuỗi giá từ "30.590.000₫" nếu cần, hoặc hiển thị trực tiếp
    return priceRaw;
  }

  Widget allOrders() {
    return StreamBuilder(
      stream: orderStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFfd6f3e)));

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];

            // Xử lý status để hiển thị màu sắc
            String status = ds["Status"];
            Color statusColor = Colors.grey;
            if (status == "Đang xử lý") statusColor = Colors.orange;
            else if (status == "Đang giao hàng") statusColor = Colors.blue;
            else if (status == "Đã giao") statusColor = Colors.green;
            else if (status == "Đã hủy") statusColor = Colors.red;

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dòng 1: Ảnh + Tên sp
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          ds["ProductImage"],
                          height: 70, width: 70, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(height: 70, width: 70, color: Colors.grey[300]),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ds["Product"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2),
                            const SizedBox(height: 5),
                            Text("KH: ${ds["Name"]}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 25),

                  // Dòng 2: Giá + Trạng thái
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ds["Price"], style: const TextStyle(color: Color(0xFFfd6f3e), fontSize: 16, fontWeight: FontWeight.bold)),

                      // Nút trạng thái (Bấm vào để đổi)
                      GestureDetector(
                        onTap: () => showStatusBottomSheet(ds.id, status),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor),
                          ),
                          child: Row(
                            children: [
                              Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(width: 5),
                              Icon(Icons.edit, size: 14, color: statusColor)
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
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
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        title: const Text("Quản lý Đơn hàng", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: allOrders(),
      ),
    );
  }
}