import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopnew/pages/Address.dart';
import 'package:shopnew/pages/Shopping.dart';
import 'package:shopnew/services/constant.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/widget/support_widget.dart';
import 'package:http/http.dart' as http;
// Import Service gửi mail
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
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(children: [
                    Center(
                        child: Image.network(
                          widget.image,
                          height: 400,
                        )),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 20.0),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(30)),
                        child: Icon(Icons.arrow_back_ios_new_outlined),
                      ),
                    ),
                  ]),
                  Container(
                    padding: EdgeInsets.only(bottom: 30.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      margin: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: Appwidget.boldTextStyle(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.price,
                            style: TextStyle(
                                color: Color(0xFFfd6f3e),
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Chi tiết",
                            style: Appwidget.semiboldTextStyle(),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(widget.detail),
                          SizedBox(
                            height: 120.0,
                          ),
                          Row(
                            children: [
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
                                    width: 100.0,
                                    padding: EdgeInsets.symmetric(vertical: 13.0),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: _isShoppingLoading
                                        ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                        : Icon(Icons.shopping_cart)),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),

                              GestureDetector(
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
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  width: 260.0,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Color(0xFFfd6f3e)),
                                  child: Center(
                                      child: _isBuyLoading
                                          ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                          : Text(
                                        "Mua ngay",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22.0),
                                      )),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Future<void> makepayment(String amount) async {
    try {
      // Đổi currency thành 'usd' để ổn định hơn với Stripe test
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

        // 1. Lưu thông tin đơn hàng
        Map<String, dynamic> orderInfoMap = {
          "Product": widget.name,
          "Price": widget.price,
          "Name": name,
          "Email": email,
          "Image": image,
          "ProductImage": widget.image,
          "Status": "Đang vận chuyển.",
          "OrderDate": DateTime.now(),
        };
        await DatabaseMethods().orderDetails(orderInfoMap);

        // 2. GỬI EMAIL XÁC NHẬN (Đã thêm mới)
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
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  Text("Thanh toán thành công! Đã gửi mail xác nhận.")
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

  // Sửa lại hàm tính tiền để đổi ra cent USD
  calculateAmount(String amount) {
    final cleaneamount = amount.replaceAll(RegExp(r'\D'), '');
    final vnd = double.parse(cleaneamount);
    final usd = vnd / 26334; // Tỷ giá giả định
    final cents = (usd * 100).toInt();

    return cents.toString();
  }
}