import 'dart:convert';
import 'package:provider/provider.dart'; // 1. Import Provider
import 'package:shopnew/pages/Address.dart';
import 'package:shopnew/pages/AddressList.dart';
import 'package:shopnew/pages/Order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shopnew/Auth-Pages/Login.dart';
import 'package:shopnew/services/EmailService.dart';
import 'package:shopnew/services/constant.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/services/theme_provider.dart'; // 2. Import ThemeProvider
import 'package:shopnew/widget/support_widget.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class Shopping extends StatefulWidget {
  const Shopping({super.key});

  @override
  State<Shopping> createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  final currencyFormat = NumberFormat("#,##", "vi_VN");
  List<DocumentSnapshot> cartItems = [];
  bool _isBuyLoading = false;
  double tong = 0;
  String? email, name;
  Stream? addressStream;
  DocumentSnapshot? currentAddressDoc;
  Stream? orderStream;

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  getontheload() async {
    await getthesharedpref();
  }

  getthesharedpref() async {
    email = await Share_pref().getUserEmail();
    name = await Share_pref().getUserName();

    if (email != null) {
      orderStream = DatabaseMethods().getShopping(email!);
      addressStream = DatabaseMethods().getAddress(email!);
    } else {
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      }
    }
    setState(() {});
  }

  Map<String, dynamic>? paymentIntent;

  // Widget hiển thị địa chỉ (Đã hỗ trợ Dark Mode)
  Widget address(bool isDark) {
    Color cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;

    return StreamBuilder(
      stream: addressStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          currentAddressDoc = null;
          return GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => AddressPage()));
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFfd6f3e))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Thêm địa chỉ giao hàng", style: TextStyle(color: Color(0xFFfd6f3e), fontSize: 16, fontWeight: FontWeight.bold)),
                  Icon(Icons.add_location_alt_outlined, color: Color(0xFFfd6f3e))
                ],
              ),
            ),
          );
        }
        currentAddressDoc = snapshot.data.docs[0];
        Map<String, dynamic> data = currentAddressDoc!.data() as Map<String, dynamic>;
        String recipientName = data["Name"];
        String recipientPhone = data["Phone"];
        String displayAddress = "${data["Line"]}, ${data["Ward"]}, ${data["District"]}, ${data["City"]}";

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text("$recipientName | $recipientPhone",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      final selectedAddress = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Addresslist())
                      );

                      if (selectedAddress != null && selectedAddress is DocumentSnapshot) {
                        setState(() {
                          currentAddressDoc = selectedAddress;
                        });
                      }
                    },
                    child: Text("Thay đổi", style: TextStyle(color: Color(0xFFfd6f3e), fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              SizedBox(height: 8),
              Text(displayAddress, style: TextStyle(fontSize: 15, color: isDark ? Colors.white70 : Colors.black87)),
            ],
          ),
        );
      },
    );
  }

  // Widget hiển thị danh sách giỏ hàng (Đã hỗ trợ Dark Mode)
  Widget allShopping(bool isDark) {
    Color cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;

    return StreamBuilder(
      stream: orderStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          cartItems.clear();
          return Center(child: Text("Giỏ hàng của bạn đang trống", style: TextStyle(color: textColor)));
        }
        cartItems = snapshot.data.docs;
        tong = 0;
        for (var ds in cartItems) {
          String price = ds["Price"].replaceAll(".", "").replaceAll("₫", "");
          tong += (double.parse(price) * ds["Count"]);
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = cartItems[index];
                  int count = ds["Count"];
                  return Container(
                    margin: EdgeInsets.only(bottom: 30.0),
                    child: Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(10),
                      color: cardColor, // Màu nền thẻ sản phẩm
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                          right: 20.0,
                          top: 10.0,
                          bottom: 1.0,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                ds["ProductImage"],
                                width: 120.0,
                                height: 120.0,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                    width: 120, height: 120,
                                    color: Colors.grey,
                                    child: Icon(Icons.error)
                                ),
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ds["Product"],
                                    style: Appwidget.semiboldTextStyle().copyWith(color: textColor), // Màu tên sản phẩm
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    ds["Price"],
                                    style: TextStyle(
                                      color: Color(0xFFfd6f3e),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22.0,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      // Nút +
                                      GestureDetector(
                                        onTap: () async {
                                          if (email != null) {
                                            DatabaseMethods().updateShopping(
                                              email!,
                                              ds.id,
                                              {"Count": FieldValue.increment(1)},
                                            );
                                          }
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: textColor), // Viền nút
                                          ),
                                          child: Icon(Icons.add, color: textColor), // Icon nút
                                        ),
                                      ),
                                      // Số lượng
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        width: 50.0,
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            count.toString(),
                                            style: TextStyle(fontSize: 20.0, color: textColor), // Màu số lượng
                                          ),
                                        ),
                                      ),
                                      // Nút -
                                      GestureDetector(
                                        onTap: () async {
                                          if (email != null) {
                                            if (count != 1) {
                                              DatabaseMethods().updateShopping(
                                                email!,
                                                ds.id,
                                                {"Count": FieldValue.increment(-1)},
                                              );
                                            } else {
                                              DatabaseMethods().deleteShopping(
                                                email!,
                                                ds.id,
                                              );
                                            }
                                          }
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: textColor),
                                          ),
                                          child: Icon(Icons.remove, color: textColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Phần tổng tiền bên dưới
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              decoration: BoxDecoration(
                // Nếu dark mode thì dùng màu tối, ngược lại dùng xám nhạt
                  color: isDark ? Color(0xFF121212) : Color(0xfff2f3f2),
                  boxShadow: [
                    if(isDark) BoxShadow(color: Colors.white10, offset: Offset(0, -1), blurRadius: 2)
                  ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tổng : ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0,
                        color: textColor
                    ),
                  ),
                  Text(
                    "${currencyFormat.format(tong)}₫",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                      color: Color(0xFFfd6f3e),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (cartItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Giỏ hàng rỗng !",
                        style: TextStyle(color: Colors.redAccent),))
                  );
                  return;
                }

                if (currentAddressDoc == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Vui lòng thêm địa chỉ giao hàng!"),
                    backgroundColor: Colors.red,
                  ));
                  await Navigator.push(context, MaterialPageRoute(builder: (context)=> AddressPage()));
                  return;
                }

                setState(() { _isBuyLoading = true; });

                List<Map<String, dynamic>> productBuy = [];
                for (var doc in cartItems) {
                  String price = doc["Price"].replaceAll(".", "").replaceAll(
                      "₫", "");
                  double tongproduct = (double.parse(price) * doc["Count"]);
                  productBuy.add({
                    "Price": doc["Price"],
                    "Name": doc["Product"],
                    "Image": doc["ProductImage"],
                    "Count": doc["Count"],
                    "Tong": "${currencyFormat.format(tongproduct)}₫",
                  });
                }

                Map<String, dynamic> data = currentAddressDoc!.data() as Map<String, dynamic>;

                Map<String, dynamic> orderInfoMap = {
                  "Email": email,
                  "Total": "${currencyFormat.format(tong)}₫",
                  "Status": "Đang vận chuyển.",
                  "Products": productBuy,
                  "OrderTimestamp": FieldValue.serverTimestamp(),
                  "RecipientName": data["Name"],
                  "RecipientPhone": data["Phone"],
                  "ShippingAddress": "${data["Line"]}, ${data["Ward"]}, ${data["District"]}, ${data["City"]}",
                };

                await makepayment(tong.toStringAsFixed(0), orderInfoMap);
                setState(() { _isBuyLoading = false; });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(0xFFfd6f3e),
                ),
                child: Center(
                  child: _isBuyLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "Mua ngay",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.0),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3. Lấy thông tin theme
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    // Màu nền chính (Scaffold)
    final Color bgColor = isDark ? Color(0xFF121212) : Color(0xfff2f2f2);
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor, // Sử dụng màu động
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: bgColor,
        title: Text("Giỏ hàng", style: Appwidget.semiboldTextStyle().copyWith(color: textColor)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => OrderHistory()));
            },
            icon: Icon(Icons.receipt_long_outlined, color: textColor), // Icon đổi màu theo theme
            tooltip: "Lịch sử đơn hàng",
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(right: 20.0, left: 20.0, top: 20.0),
        child: Column(children: [
          address(isDark), // Truyền biến isDark vào
          SizedBox(height: 20.0,),
          Expanded(child: allShopping(isDark)) // Truyền biến isDark vào
        ]),
      ),
    );
  }

  // --- Các hàm thanh toán giữ nguyên ---
  Future<void> makepayment(String amount, orderInfoMap) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'usd');
      await Stripe.instance
          .initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent?["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "ShopNew",
        ),
      )
          .then((value) => {});
      await displayPaymentSheet(orderInfoMap);
    } catch (e, s) {
      print("exception $e$s");
      setState(() { _isBuyLoading = false; });
    }
  }

  displayPaymentSheet(orderInfoMap) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await DatabaseMethods().orderDetails(orderInfoMap);

      String productListString = cartItems.map((e) => "${e["Product"]} (x${e["Count"]})").join(", ");

      await EmailService.sendOrderConfirmation(
        userEmail: email!,
        userName: name!,
        productName: productListString,
        price: "${currencyFormat.format(tong)}₫",
        orderId: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 50,),
                  SizedBox(height: 10,),
                  Text("Thanh toán thành công!", style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
            ),
      );

      if(email!= null){
        for(var doc in cartItems){
          await DatabaseMethods().deleteShopping(email!, doc.id);
        }
      }
      cartItems.clear();
      paymentIntent = null;
    } on StripeException catch (e) {
      print("Payment failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Thanh toán thất bại hoặc bị hủy."))
      );
    } catch (e) {
      print("Lỗi không xác định: $e");
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
    final cleaneamount = amount.replaceAll(RegExp(r'\D'), '');
    final vnd = double.parse(cleaneamount);
    final usd = vnd / 26334;
    final cents = (usd * 100).toInt();
    return cents.toString();
  }
}