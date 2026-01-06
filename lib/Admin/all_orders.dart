import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopnew/services/theme_provider.dart';

class AllOrders extends StatefulWidget {
  const AllOrders({super.key});

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  Stream? orderStream;

  // Lấy dữ liệu Realtime
  getOntheLoad() async {
    orderStream = FirebaseFirestore.instance
        .collection("Orders")
        .snapshots();
    setState(() {});
  }

  @override
  void initState() {
    getOntheLoad();
    super.initState();
  }

  void showStatusBottomSheet(String orderId, String currentStatus, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Cập nhật trạng thái",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 20),
              _buildStatusOption(orderId, "Đang xử lý", Colors.orange, currentStatus, isDark),
              _buildStatusOption(orderId, "Đang vận chuyển", Colors.blue, currentStatus, isDark),
              _buildStatusOption(orderId, "Đã giao", Colors.green, currentStatus, isDark),
              _buildStatusOption(orderId, "Đã hủy", Colors.red, currentStatus, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(String docId, String status, Color color, String currentStatus, bool isDark) {
    bool isSelected = status == currentStatus;
    return ListTile(
      leading: Icon(Icons.circle, color: color, size: 14),
      title: Text(status,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : (isDark ? Colors.white : Colors.black))),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () async {
        Navigator.pop(context);
        await FirebaseFirestore.instance.collection("Orders").doc(docId).update({
          "Status": status
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Đã cập nhật: $status"), backgroundColor: color));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xfff2f2f2);
    Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Quản lý Đơn hàng",
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: StreamBuilder(
          stream: orderStream,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.orange));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                Map<String, dynamic> data = ds.data() as Map<String, dynamic>;

                List<Map<String, dynamic>> productsToShow = [];
                String totalPriceDisplay = "0đ";

                if (data.containsKey('Products') && data['Products'] is List) {
                  List<dynamic> listRaw = data['Products'];
                  for (var item in listRaw) {
                    productsToShow.add({
                      "Name": item["Name"],
                      "Image": item["Image"],
                      "Price": item["Price"],
                      "Count": item["Count"] ?? 1,
                    });
                  }
                  if (productsToShow.isNotEmpty) {
                    totalPriceDisplay = productsToShow[0]['Price'];
                  }
                }
                else if (data.containsKey('Product')) {
                  productsToShow.add({
                    "Name": data["Product"],
                    "Image": data["ProductImage"],
                    "Price": data["Price"],
                    "Count": 1,
                  });
                  totalPriceDisplay = data["Price"];
                }

                String name = "Khách hàng";
                if (data.containsKey("Name")) {
                  name = data["Name"];
                } else if (data.containsKey("Email")) {
                  name = data["Email"].toString().split('@')[0];
                }

                String status = data["Status"] ?? "Đang xử lý";
                Color statusColor = Colors.grey;
                if (status == "Đang xử lý") statusColor = Colors.orange;
                else if (status == "Đang vận chuyển") statusColor = Colors.blue;
                else if (status == "Đã giao") statusColor = Colors.green;
                else if (status == "Đã hủy") statusColor = Colors.red;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("KH: $name",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                                Text(data["Email"] ?? "",
                                    style: TextStyle(fontSize: 12, color: subTextColor), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => showStatusBottomSheet(ds.id, status, isDark),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(status,
                                  style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.withOpacity(0.2), height: 20),

                      if (productsToShow.isEmpty)
                        Text("Dữ liệu lỗi hoặc chưa đồng bộ", style: TextStyle(color: Colors.red)),

                      ...productsToShow.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item["Image"] ?? "",
                                  height: 60, width: 60, fit: BoxFit.cover,
                                  errorBuilder: (c, o, s) => Container(color: Colors.grey[300], height: 60, width: 60, child: Icon(Icons.image)),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item["Name"] ?? "Sản phẩm",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text("SL: ${item["Count"]}  |  ${item["Price"]}",
                                        style: TextStyle(fontSize: 13, color: subTextColor)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      Divider(color: Colors.grey.withOpacity(0.2), height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tổng tiền (ước tính):", style: TextStyle(color: subTextColor)),
                          Text(totalPriceDisplay,
                              style: const TextStyle(color: Color(0xFFfd6f3e), fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}