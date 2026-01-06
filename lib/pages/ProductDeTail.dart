import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:shopnew/services/constant.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/services/theme_provider.dart';
import 'package:shopnew/widget/support_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shopnew/services/EmailService.dart';
// Import trang Address của bạn
import 'package:shopnew/pages/Address.dart';

class ProductDeTail extends StatefulWidget {
  final String id, name, image, detail, price;
  ProductDeTail({
    required this.id,
    required this.name,
    required this.image,
    required this.detail,
    required this.price,
  });

  @override
  State<ProductDeTail> createState() => _ProductDeTailState();
}

class _ProductDeTailState extends State<ProductDeTail> {
  bool _isBuyLoading = false;
  bool _isShoppingLoading = false;
  bool _hasAddress = false;
  String? name, email, image;

  getthesharedpref() async {
    name = await Share_pref().getUserName();
    email = await Share_pref().getUserEmail();
    image = await Share_pref().getUserImage();
  }

  ontheload() async {
    await getthesharedpref();

    if (email != null) {
      QuerySnapshot addressSnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(email)
          .collection("Address")
          .get();

      if (addressSnapshot.docs.isNotEmpty) {
        setState(() {
          _hasAddress = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final Color bgColor = isDark ? Color(0xFF121212) : Color(0xFFfef5f1);
    final Color sheetColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
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
                Container(
                  height: 350,
                  width: double.infinity,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Image.network(widget.image, fit: BoxFit.contain),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.black54 : Colors.white.withOpacity(0.8),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))]),
                      child: Icon(Icons.arrow_back_ios_new_outlined, color: textColor, size: 20),
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
                    color: sheetColor,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, -5), blurRadius: 10)]),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        Text(widget.price, style: TextStyle(color: Color(0xFFfd6f3e), fontSize: 22.0, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Text("Chi tiết", style: isDark ? TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold) : Appwidget.semiboldTextStyle()),
                    SizedBox(height: 10.0),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Text(widget.detail, style: TextStyle(color: subTextColor, fontSize: 15, height: 1.5)),
                      ),
                    ),
                    SizedBox(height: 20.0),

                    // --- CÁC NÚT BẤM ---
                    Row(
                      children: [
                        // Nút Thêm vào giỏ
                        GestureDetector(
                          onTap: () async {
                            if (_isShoppingLoading) return;
                            Map<String, dynamic> shoppingInfoMap = {
                              "ProductId": widget.id,
                              "Product": widget.name,
                              "Price": widget.price,
                              "Name": name,
                              "Image": image,
                              "ProductImage": widget.image,
                              "Count": 1,
                            };
                            setState(() => _isShoppingLoading = true);
                            try {
                              await DatabaseMethods().addProductToCart(email!, shoppingInfoMap);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.greenAccent, content: Text("Thêm vào giỏ thành công")));
                            } catch (e) {
                              print("Lỗi shopping: $e");
                            } finally {
                              setState(() => _isShoppingLoading = false);
                            }
                          },
                          child: Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[800] : Color(0xFFfef5f1),
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(color: Color(0xFFfd6f3e))),
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

                              if (!_hasAddress) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Vui lòng thêm địa chỉ giao hàng!")),
                                );
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => AddressPage()));
                                ontheload();
                                return;
                              }

                              setState(() => _isBuyLoading = true);
                              try {
                                await makepayment(widget.price);
                              } catch (e) {
                                print("Lỗi thanh toán: $e");
                              } finally {
                                setState(() => _isBuyLoading = false);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 18.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Color(0xFFfd6f3e),
                                  boxShadow: [BoxShadow(color: Color(0xFFfd6f3e).withOpacity(0.4), blurRadius: 10, offset: Offset(0, 5))]),
                              child: Center(
                                  child: _isBuyLoading
                                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text("Mua ngay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0))),
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

  // --- GIỮ NGUYÊN PHẦN STRIPE PAYMENT CỦA BẠN ---
  Future<void> makepayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'usd');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent?["client_secret"],
              style: ThemeMode.dark,
              merchantDisplayName: "ShopNew"));
      displayPaymentSheet();
    } catch (e) {
      print("Stripe Init Error: $e");
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {

        // Lấy địa chỉ mới nhất để lưu vào đơn hàng
        var addrSnap = await FirebaseFirestore.instance.collection("Users").doc(email).collection("Address").get();
        var addrData = addrSnap.docs.first.data();
        String fullAddr = "${addrData["Line"]}, ${addrData["Ward"]}, ${addrData["District"]}, ${addrData["City"]}";

        Map<String, dynamic> orderInfoMap = {
          "Email": email,
          "Name": addrData["Name"] ?? name,
          "Phone": addrData["Phone"] ?? "",
          "Address": fullAddr,
          "Status": "Đang vận chuyển",
          "OrderTimestamp": FieldValue.serverTimestamp(),
          "Total": widget.price,
          "Products": [
            {"Name": widget.name, "Image": widget.image, "Price": widget.price, "Count": 1}
          ]
        };

        await DatabaseMethods().orderDetails(orderInfoMap);

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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 50),
                  SizedBox(height: 10),
                  Text("Thanh toán thành công!", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ));
        paymentIntent = null;
      });
    } on StripeException catch (e) {
      print("User cancelled: $e");
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
        headers: {"Authorization": 'Bearer $Secretkey', "Content-Type": "application/x-www-form-urlencoded"},
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      print("err charging: $err");
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