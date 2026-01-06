import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopnew/services/theme_provider.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  int totalOrders = 0;
  int successfulOrders = 0;
  int totalInventory = 0;
  double totalRevenue = 0.0;
  bool _isLoading = true;

  List<double> monthlyRevenueData = [0.0, 0.0, 0.0];
  List<String> monthLabels = [];

  @override
  void initState() {
    super.initState();
    _generateMonthLabels();
    getStatistics();
  }

  void _generateMonthLabels() {
    DateTime now = DateTime.now();
    for (int i = 2; i >= 0; i--) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      monthLabels.add("T${month.month}");
    }
  }

  Future<void> getStatistics() async {
    try {
      QuerySnapshot orderSnapshot = await FirebaseFirestore.instance.collection("Orders").get();
      List<DocumentSnapshot> orders = orderSnapshot.docs;

      totalOrders = orders.length;
      successfulOrders = 0;

      double tempTotalRevenue = 0.0;
      List<double> tempMonthlyRevenue = [0, 0, 0];
      DateTime now = DateTime.now();

      for (var doc in orders) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        String status = (data["Status"] ?? "").toString().toLowerCase();

        if (status.contains("đã hủy") ) {
          continue;
        }

        successfulOrders++;

        double orderValue = 0.0;

        if (data.containsKey('Products') && data['Products'] is List) {
          List<dynamic> products = data['Products'];
          for (var item in products) {
            double price = _parsePrice(item['Price']);
            int count = item['Count'] ?? 1;
            orderValue += (price * count);
          }
        }
        else {
          var priceRaw = data['Price'] ?? data['price'] ?? data['Total'];
          orderValue = _parsePrice(priceRaw);
        }

        tempTotalRevenue += orderValue;

        DateTime? orderDate;
        try {
          if (data.containsKey('OrderTimestamp')) {
            orderDate = (data['OrderTimestamp'] as Timestamp).toDate();
          } else if (data.containsKey('OrderDate')) {
            orderDate = (data['OrderDate'] as Timestamp).toDate();
          } else if (data.containsKey('Date')) {
            String dateStr = data['Date'].toString();
            try { orderDate = DateFormat('dd/MM/yyyy').parse(dateStr); } catch (_) {}
          }
        } catch (e) {
        }

        if (orderDate != null) {
          int diffMonth = (now.year - orderDate.year) * 12 + now.month - orderDate.month;

          if (diffMonth >= 0 && diffMonth <= 2) {

            tempMonthlyRevenue[2 - diffMonth] += orderValue;
          }
        }
      }

      try {
        QuerySnapshot productSnapshot = await FirebaseFirestore.instance.collection("Products").get();
        totalInventory = productSnapshot.docs.length;
      } catch (e) {
        totalInventory = 0;
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

  double _parsePrice(dynamic priceRaw) {
    if (priceRaw == null) return 0.0;
    String str = priceRaw.toString();
    String cleanStr = str.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleanStr) ?? 0.0;
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xfff2f2f2);
    Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color subTextColor = isDark ? Colors.white70 : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Thống kê & Doanh thu",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor), // Màu nút back
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
              // --- CARD TỔNG DOANH THU ---
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
                        Text("Thực thu (Đã trừ đơn hủy)", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        Icon(Icons.monetization_on_outlined, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatCurrency(totalRevenue),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text("$successfulOrders đơn hàng thành công", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      title: "Tổng đơn đặt",
                      value: totalOrders.toString(),
                      icon: Icons.shopping_bag,
                      color: Colors.blueAccent,
                      cardColor: cardColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildInfoCard(
                      title: "SP trong kho",
                      value: totalInventory.toString(),
                      icon: Icons.inventory_2,
                      color: Colors.purpleAccent,
                      cardColor: cardColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),
              Text("Biểu đồ doanh thu 3 tháng", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 20),

              Container(
                height: 350,
                padding: const EdgeInsets.fromLTRB(10, 30, 20, 10),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark?0.3:0.1), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxY(),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.blueGrey, // Màu nền tooltip
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
                                child: Text(monthLabels[index], style: TextStyle(fontWeight: FontWeight.bold, color: subTextColor)),
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
                      _makeGroupData(0, monthlyRevenueData[0], Colors.grey.shade400, isDark),
                      _makeGroupData(1, monthlyRevenueData[1], const Color(0xffff9f7f), isDark),
                      _makeGroupData(2, monthlyRevenueData[2], const Color(0xFFfd6f3e), isDark),
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

  BarChartGroupData _makeGroupData(int x, double y, Color barColor, bool isDark) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: 35,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: isDark ? Colors.white10 : Colors.grey.shade100 // Màu nền cột mờ
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
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
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(color: subTextColor, fontSize: 13)),
        ],
      ),
    );
  }
}