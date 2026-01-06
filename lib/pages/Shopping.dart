import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// Import các file trong dự án của bạn
import 'package:shopnew/Auth-Pages/Login.dart';
import 'package:shopnew/pages/Address.dart';
import 'package:shopnew/pages/AddressList.dart';
import 'package:shopnew/pages/Order.dart';
import 'package:shopnew/services/EmailService.dart';
import 'package:shopnew/services/constant.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/services/theme_provider.dart';
import 'package:shopnew/widget/support_widget.dart';

class Shopping extends StatefulWidget {
  const Shopping({super.key});

  @override
  State<Shopping> createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  // Định dạng tiền tệ VNĐ
  final currencyFormat = NumberFormat("#,##", "vi_VN");

  List<DocumentSnapshot> cartItems = [];
  bool _isBuyLoading = false;
  double tong = 0;
  String? email, name;

  Stream? addressStream;
  Stream? orderStream;
  DocumentSnapshot? currentAddressDoc;
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    super.initState();
    getOnLoad();
  }

  // Khởi tạo dữ liệu ban đầu
  Future<void> getOnLoad() async {
    email = await Share_pref().getUserEmail();
    name = await Share_pref().getUserName();

    if (email != null) {
      orderStream = DatabaseMethods().getShopping(email!);
      addressStream = DatabaseMethods().getAddress(email!);
      setState(() {});
    } else {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
      }
    }
  }

  // --- WIDGET: HIỂN THỊ ĐỊA CHỈ ---
  Widget buildAddressCard(bool isDark) {
    Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color primaryColor = const Color(0xFFfd6f3e);

    return StreamBuilder(
      stream: addressStream,
      builder: (context, AsyncSnapshot snapshot) {
        // Trạng thái đang tải
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 80,
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // Chưa có địa chỉ
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          currentAddressDoc = null;
          return GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => AddressPage()));
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Thêm địa chỉ giao hàng", style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  Icon(Icons.add_location_alt_outlined, color: primaryColor)
                ],
              ),
            ),
          );
        }

        // Đã có địa chỉ -> Hiển thị
        currentAddressDoc = snapshot.data.docs[0];
        Map<String, dynamic> data = currentAddressDoc!.data() as Map<String, dynamic>;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text("${data["Name"]} | ${data["Phone"]}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      final selectedAddress = await Navigator.push(
                          context, MaterialPageRoute(builder: (context) => Addresslist())
                      );
                      if (selectedAddress != null && selectedAddress is DocumentSnapshot) {
                        setState(() { currentAddressDoc = selectedAddress; });
                      }
                    },
                    child: Text("Thay đổi", style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "${data["Line"]}, ${data["Ward"]}, ${data["District"]}, ${data["City"]}",
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET: DANH SÁCH GIỎ HÀNG ---
  Widget buildCartList(bool isDark) {
    Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;

    return StreamBuilder(
      stream: orderStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          cartItems.clear();
          // Reset tổng tiền khi giỏ hàng trống để tránh hiển thị sai
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (tong != 0 && mounted) setState(() { tong = 0; });
          });
          return Center(child: Text("Giỏ hàng của bạn đang trống", style: TextStyle(color: textColor)));
        }

        cartItems = snapshot.data.docs;

        // Tính tổng tiền
        double tempTong = 0;
        for (var ds in cartItems) {
          String price = ds["Price"].toString().replaceAll(".", "").replaceAll("₫", "").replaceAll(",", "");
          tempTong += (double.parse(price) * ds["Count"]);
        }
        // Cập nhật biến tổng để hiển thị (dùng microtask để tránh lỗi setState khi build)
        if (tempTong != tong) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() { tong = tempTong; });
          });
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = cartItems[index];
            int count = ds["Count"];
            return Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))]
              ),
              child: Row(
                children: [
                  // Ảnh sản phẩm
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                    child: Image.network(
                      ds["ProductImage"],
                      width: 100, height: 100, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(width: 100, height: 100, color: Colors.grey, child: const Icon(Icons.error)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Thông tin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ds["Product"],
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis
                        ),
                        const SizedBox(height: 5),
                        Text(ds["Price"], style: const TextStyle(color: Color(0xFFfd6f3e), fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 5),
                        // Nút tăng giảm
                        Row(
                          children: [
                            _buildQuantityBtn(Icons.remove, () {
                              if (count > 1) {
                                DatabaseMethods().updateShopping(email!, ds.id, {"Count": FieldValue.increment(-1)});
                              } else {
                                DatabaseMethods().deleteShopping(email!, ds.id);
                              }
                            }, isDark),
                            Container(
                              width: 30, alignment: Alignment.center,
                              child: Text(count.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                            ),
                            _buildQuantityBtn(Icons.add, () {
                              DatabaseMethods().updateShopping(email!, ds.id, {"Count": FieldValue.increment(1)});
                            }, isDark),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Widget nút tăng giảm số lượng nhỏ gọn
  Widget _buildQuantityBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(5)
        ),
        child: Icon(icon, size: 16, color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  Future<void> handleCheckout() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Giỏ hàng rỗng!"), backgroundColor: Colors.red));
      return;
    }
    if (currentAddressDoc == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng thêm địa chỉ!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isBuyLoading = true);

    try {
      List<Map<String, dynamic>> productsList = [];
      for (var doc in cartItems) {
        productsList.add({
          "Name": doc["Product"],       // Tên SP
          "Image": doc["ProductImage"], // Ảnh SP
          "Price": doc["Price"],        // Giá tiền (String)
          "Count": doc["Count"],        // Số lượng
        });
      }

      Map<String, dynamic> addrData = currentAddressDoc!.data() as Map<String, dynamic>;
      String fullAddress = "${addrData["Line"]}, ${addrData["Ward"]}, ${addrData["District"]}, ${addrData["City"]}";

      Map<String, dynamic> orderInfoMap = {
        "Email": email,
        "Name": addrData["Name"],         // Tên người nhận
        "Phone": addrData["Phone"],       // SĐT người nhận
        "Address": fullAddress,           // Địa chỉ giao hàng
        "Status": "Đang vận chuyển",      // Trạng thái ban đầu
        "OrderTimestamp": FieldValue.serverTimestamp(), // Thời gian đặt (Server)
        "Total": "${currencyFormat.format(tong)}₫",     // Tổng tiền
        "Products": productsList,         // Danh sách sản phẩm (Quan trọng cho Admin)
      };

      await makeStripePayment(tong.toStringAsFixed(0), orderInfoMap, productsList);

    } catch (e) {
      print("Lỗi checkout: $e");
      setState(() => _isBuyLoading = false);
    }
  }

  Future<void> makeStripePayment(String amount, Map<String, dynamic> orderInfoMap, List<Map<String, dynamic>> productsList) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'usd');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent?["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "ShopNew",
        ),
      );

      // Hiển thị bảng thanh toán
      await Stripe.instance.presentPaymentSheet();


      await DatabaseMethods().orderDetails(orderInfoMap);

      String productNames = productsList.map((e) => "${e["Name"]} (x${e["Count"]})").join(", ");
      await EmailService.sendOrderConfirmation(
        userEmail: email!,
        userName: name!,
        productName: productNames, // Gửi danh sách tên SP
        price: "${currencyFormat.format(tong)}₫",
        orderId: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // 3. Xóa giỏ hàng
      if (email != null) {
        for (var doc in cartItems) {
          await DatabaseMethods().deleteShopping(email!, doc.id);
        }
      }

      // 4. Thông báo và reset
      setState(() {
        cartItems.clear();
        tong = 0;
        _isBuyLoading = false;
      });

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              SizedBox(height: 10),
              Text("Thanh toán thành công!", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
      paymentIntent = null;

    } on StripeException catch (e) {
      print("Stripe Error: $e");
      setState(() => _isBuyLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã hủy thanh toán")));
    } catch (e) {
      print("Error: $e");
      setState(() => _isBuyLoading = false);
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        "amount": calculateAmount(amount),
        "currency": currency,
        "payment_method_types[]": "card",
      };
      var response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        headers: {
          "Authorization": 'Bearer $Secretkey',
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      print("err charging user : ${err.toString()}");
    }
  }

  calculateAmount(String amount) {
    try {
      final cleaneamount = amount.replaceAll(RegExp(r'\D'), '');
      final vnd = double.parse(cleaneamount);
      final usd = vnd / 26334; // Tỷ giá tham khảo
      final cents = (usd * 100).toInt();
      return cents.toString();
    } catch (e) {
      return "100"; // Giá trị mặc định nếu lỗi parse
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xfff2f2f2);
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text("Giỏ hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: textColor)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrderHistory())),
            icon: Icon(Icons.receipt_long, color: textColor),
            tooltip: "Lịch sử đơn hàng",
          ),
          const SizedBox(width: 10)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Phần Địa chỉ
            buildAddressCard(isDark),
            const SizedBox(height: 15),

            // Phần Danh sách sản phẩm (Dùng Expanded để chiếm phần còn lại)
            Expanded(child: buildCartList(isDark)),

            // Phần Tổng tiền & Nút thanh toán
            Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: isDark ? Colors.white24 : Colors.black12))
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tổng cộng:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      Text("${currencyFormat.format(tong)}₫", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFfd6f3e))),
                    ],
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: handleCheckout,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          color: const Color(0xFFfd6f3e),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: const Color(0xFFfd6f3e).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))]
                      ),
                      child: Center(
                        child: _isBuyLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("THANH TOÁN NGAY", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}