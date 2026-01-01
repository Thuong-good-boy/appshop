import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  int totalOrders = 0;
  int totalProducts = 0;
  double totalRevenue = 0.0;
  bool _isLoading = true;

  // Dữ liệu cho biểu đồ 3 tháng
  List<double> monthlyRevenueData = [0.0, 0.0, 0.0];
  List<String> monthLabels = [];

  @override
  void initState() {
    super.initState();
    _generateMonthLabels();
    getStatistics();
  }

  // Tạo nhãn tháng (T1, T2, T12...)
  void _generateMonthLabels() {
    DateTime now = DateTime.now();
    for (int i = 2; i >= 0; i--) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      monthLabels.add("T${month.month}");
    }
  }

  // Hàm xử lý số liệu từ Firebase
  Future<void> getStatistics() async {
    try {
      QuerySnapshot orderSnapshot = await FirebaseFirestore.instance.collection("Orders").get();
      List<DocumentSnapshot> orders = orderSnapshot.docs;
      totalOrders = orders.length;

      double tempTotalRevenue = 0.0;
      List<double> tempMonthlyRevenue = [0, 0, 0];
      DateTime now = DateTime.now();

      for (var doc in orders) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // --- 1. XỬ LÝ GIÁ TIỀN (Khớp với "30.590.000đ") ---
        double orderValue = 0.0;
        var priceRaw = data.containsKey('Price') ? data['Price'] : data['price'];

        if (priceRaw != null) {
          // Xóa chữ "đ", dấu chấm, chỉ giữ lại số
          String cleanPrice = priceRaw.toString().replaceAll(RegExp(r'[^0-9]'), '');
          orderValue = double.tryParse(cleanPrice) ?? 0.0;
        }
        tempTotalRevenue += orderValue;

        // --- 2. XỬ LÝ NGÀY THÁNG (Khớp với OrderDate: Timestamp) ---
        DateTime? orderDate;
        try {
          if (data.containsKey('OrderDate')) {
            // Lấy trực tiếp từ Timestamp như trong ảnh bạn gửi
            orderDate = (data['OrderDate'] as Timestamp).toDate();
          } else if (data.containsKey('Date')) {
            // Dự phòng cho dữ liệu cũ
            String dateStr = data['Date'].toString();
            try {
              orderDate = DateFormat('dd/MM/yyyy').parse(dateStr);
            } catch (_) {
              try { orderDate = DateTime.parse(dateStr); } catch (__) {}
            }
          }
        } catch (e) {
          print("Lỗi ngày đơn ${doc.id}: $e");
        }

        // --- 3. PHÂN LOẠI VÀO BIỂU ĐỒ ---
        if (orderDate != null) {
          // Tính khoảng cách tháng
          int diffMonth = (now.year - orderDate.year) * 12 + now.month - orderDate.month;
          if (diffMonth >= 0 && diffMonth <= 2) {
            // diffMonth = 0 là tháng này -> index 2
            // diffMonth = 1 là tháng trước -> index 1
            tempMonthlyRevenue[2 - diffMonth] += orderValue;
          }
        }
      }

      // Đếm sản phẩm
      try {
        QuerySnapshot productSnapshot = await FirebaseFirestore.instance.collection("Products").get();
        totalProducts = productSnapshot.docs.length;
      } catch (e) {
        totalProducts = 0;
      }

      if (mounted) {
        setState(() {
          totalRevenue = tempTotalRevenue;
          monthlyRevenueData = tempMonthlyRevenue;
          _isLoading = false;
        });
      }

    } catch (e) {
      print("Lỗi thống kê: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return format.format(amount);
  }

  double _getMaxY() {
    double maxVal = monthlyRevenueData.reduce((curr, next) => curr > next ? curr : next);
    return maxVal == 0 ? 1000000 : maxVal * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        title: const Text("Thống kê & Doanh thu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFfd6f3e)))
          : RefreshIndicator(
        onRefresh: getStatistics,
        color: const Color(0xFFfd6f3e),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Tổng Doanh Thu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFfd6f3e), Color(0xffff9f7f)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFfd6f3e).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tổng doanh thu", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        Icon(Icons.monetization_on_outlined, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatCurrency(totalRevenue),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text("Cập nhật real-time từ hệ thống", style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 2 Card nhỏ
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      title: "Tổng Đơn",
                      value: totalOrders.toString(),
                      icon: Icons.shopping_bag,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildInfoCard(
                      title: "Sản phẩm",
                      value: totalProducts.toString(),
                      icon: Icons.inventory_2,
                      color: Colors.purpleAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),
              const Text("Doanh thu 3 tháng gần nhất", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 20),

              // BIỂU ĐỒ (Đã sửa lỗi getTooltipColor)
              Container(
                height: 350,
                padding: const EdgeInsets.fromLTRB(10, 30, 20, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxY(),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        // --- ĐÃ SỬA DÒNG NÀY ĐỂ HỢP VỚI MỌI PHIÊN BẢN ---
                        tooltipBgColor: Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            formatCurrency(rod.toY),
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < monthLabels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(monthLabels[index], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _makeGroupData(0, monthlyRevenueData[0], Colors.grey.shade400),
                      _makeGroupData(1, monthlyRevenueData[1], const Color(0xffff9f7f)),
                      _makeGroupData(2, monthlyRevenueData[2], const Color(0xFFfd6f3e)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color barColor) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: 35,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: _getMaxY(), color: Colors.grey.shade100),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}