import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import 'package:shopnew/services/constant.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/services/theme_provider.dart'; // 2. Import ThemeProvider
import 'package:shopnew/widget/support_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shopnew/services/EmailService.dart';

class ProductDeTail extends StatefulWidget {
  String id, name, image, detail, price;
  ProductDeTail(
      {required this.id,
        required this.name,
        required this.image,
        required this.detail,
        required this.price});

  @override
  State<ProductDeTail> createState() => _ProductDeTailState();
}

class _ProductDeTailState extends State<ProductDeTail> {
  bool _isBuyLoading = false;
  bool _isShoppingLoading = false;
  String? name, email, image;

  // Giữ nguyên logic lấy dữ liệu của bạn
  getthesharedpref() async {
    name = await Share_pref().getUserName();
    email = await Share_pref().getUserEmail();
    image = await Share_pref().getUserImage();
  }

  ontheload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    // --- 1. CẤU HÌNH THEME ---
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Định nghĩa bộ màu
    final Color bgColor = isDark ? Color(0xFF121212) : Color(0xFFfef5f1); // Nền chính
    final Color sheetColor = isDark ? Color(0xFF1E1E1E) : Colors.white; // Nền khung thông tin
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white70 : Color(0xFF5E5E5E);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- PHẦN TRÊN: ẢNH & NÚT BACK ---
            Stack(
              children: [
                // Ảnh sản phẩm
                Container(
                  height: 350, // Giảm chiều cao chút để cân đối
                  width: double.infinity,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Image.network(
                    widget.image,
                    fit: BoxFit.contain,
                  ),
                ),
                // Nút Back (Làm đẹp hơn: hình tròn, bán trong suốt)
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.black54 : Colors.white.withOpacity(0.8),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 2))
                          ]),
                      child: Icon(Icons.arrow_back_ios_new_outlined,
                          color: textColor, size: 20),
                    ),
                  ),
                ),
              ],
            ),

            // --- PHẦN DƯỚI: THÔNG TIN CHI TIẾT ---
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0, bottom: 20.0),
                decoration: BoxDecoration(
                    color: sheetColor, // Màu nền thay đổi theo theme
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40), // Bo tròn mềm mại hơn
                        topRight: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, -5),
                          blurRadius: 10)
                    ]
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên và Giá
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.name,
                            style: isDark
                                ? TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
                                : Appwidget.boldTextStyle(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          widget.price,
                          style: TextStyle(
                              color: Color(0xFFfd6f3e),
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),

                    // Tiêu đề Chi tiết
                    Text(
                      "Chi tiết",
                      style: isDark
                          ? TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                          : Appwidget.semiboldTextStyle(),
                    ),
                    SizedBox(height: 10.0),

                    // Nội dung chi tiết (Dùng Expanded + SingleChildScrollView để cuộn nếu dài)
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Text(
                          widget.detail,
                          style: TextStyle(
                              color: subTextColor,
                              fontSize: 15,
                              height: 1.5 // Giãn dòng cho dễ đọc
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.0),

                    // --- CÁC NÚT BẤM (GIỮ NGUYÊN LOGIC) ---
                    Row(
                      children: [
                        // Nút Thêm vào giỏ
                        GestureDetector(
                          onTap: () async {
                            Map<String, dynamic> shoppingInfoMap = {
                              "ProductId": widget.id,
                              "Product": widget.name,
                              "Price": widget.price,
                              "Name": name,
                              "Image": image,
                              "ProductImage": widget.image,
                              "Count": 1,
                            };
                            if (_isShoppingLoading) return;
                            setState(() {
                              _isShoppingLoading = true;
                            });
                            try {
                              // GIỮ NGUYÊN HÀM CŨ CỦA BẠN
                              await DatabaseMethods()
                                  .addProductToCart(email!, shoppingInfoMap);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: Colors.greenAccent,
                                      content: Text(
                                        "Thêm vào giỏ thành công",
                                        style: TextStyle(fontSize: 15.0),
                                      )));
                            } catch (e) {
                              print("có lỗi  $e");
                            } finally {
                              setState(() {
                                _isShoppingLoading = false;
                              });
                            }
                          },
                          child: Container(
                              width: 60.0, // Thu gọn nút giỏ hàng lại cho đẹp
                              height: 60.0,
                              decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[800] : Color(0xFFfef5f1), // Màu nền nút nhạt
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(color: Color(0xFFfd6f3e))
                              ),
                              child: Center(
                                child: _isShoppingLoading
                                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFfd6f3e)))
                                    : Icon(Icons.shopping_cart_outlined, color: Color(0xFFfd6f3e)),
                              )),
                        ),
                        SizedBox(width: 20.0),

                        // Nút Mua ngay
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (_isBuyLoading) return;
                              setState(() {
                                _isBuyLoading = true;
                              });
                              try {
                                await makepayment(widget.price);
                              } catch (e) {
                                print("có lỗi  $e");
                              } finally {
                                setState(() {
                                  _isBuyLoading = false;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 18.0), // Nút cao hơn chút cho sang
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Color(0xFFfd6f3e),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color(0xFFfd6f3e).withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: Offset(0, 5)
                                    )
                                  ]
                              ),
                              child: Center(
                                  child: _isBuyLoading
                                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text(
                                    "Mua ngay",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIC THANH TOÁN & MAIL (GIỮ NGUYÊN KHÔNG ĐỔI) ---
  Future<void> makepayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'usd');
      await Stripe.instance
          .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent?["client_secret"],
              style: ThemeMode.dark,
              merchantDisplayName: "ShopNew"))
          .then((value) {});
      displayPaymentSheet();
    } catch (e, s) {
      print("exception $e$s");
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {

        // --- SỬA ĐOẠN NÀY: CHUẨN HÓA DỮ LIỆU VỀ DẠNG DANH SÁCH ---
        Map<String, dynamic> orderInfoMap = {
          "Email": email,
          "Name": name, // Tên người mua
          "Image": image, // Avatar người mua
          "Status": "Đang vận chuyển",
          "OrderTimestamp": DateTime.now(), // Dùng Timestamp để sort cho dễ
          "Total": widget.price, // Lưu tổng tiền
          "Products": [
            {
              "Name": widget.name,
              "Image": widget.image, // Ảnh sản phẩm
              "Price": widget.price,
              "Count": 1
            }
          ]
        };
        // -----------------------------------------------------------

        await DatabaseMethods().orderDetails(orderInfoMap);

        // ... (Phần gửi mail giữ nguyên) ...
        if (email != null && name != null) {
          await EmailService.sendOrderConfirmation(
            userEmail: email!,
            userName: name!,
            productName: widget.name,
            price: widget.price,
            orderId: DateTime.now().millisecondsSinceEpoch.toString(),
          );
        }

        showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Provider.of<ThemeProvider>(context, listen: false).isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 50),
                  SizedBox(height: 10),
                  Text("Thanh toán thành công!", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Đã gửi mail xác nhận.")
                ],
              ),
            ));
        paymentIntent = null;
      }).onError((error, stackTrace) {
        print("Error is : --> $error $stackTrace");
      });
    } on StripeException catch (e) {
      print("$e");
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text("Thanh toán bị hủy hoặc lỗi"),
          ));
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        "amount": calculateAmount(amount),
        "currency": currency,
        "payment_method_types[]": "card"
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
    final cleaneamount = amount.replaceAll(RegExp(r'\D'), '');
    final vnd = double.parse(cleaneamount);
    final usd = vnd / 26334;
    final cents = (usd * 100).toInt();
    return cents.toString();
  }
}