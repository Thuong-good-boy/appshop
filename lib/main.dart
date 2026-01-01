import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart'; // Thêm để kiểm tra kIsWeb
import 'package:shopnew/Admin/AddProduct.dart';
import 'package:shopnew/Admin/HomeAdmin.dart';
import 'package:shopnew/Admin/LoginAdmin.dart';
import 'package:shopnew/Admin/all_orders.dart';
import 'package:shopnew/Auth-Pages/Login.dart';
import 'package:shopnew/Auth-Pages/SignUp.dart';
import 'package:shopnew/pages/Address.dart';
import 'package:shopnew/pages/AddressList.dart';
import 'package:shopnew/pages/Shopping.dart';
import 'package:shopnew/pages/bottomNar.dart';
import 'package:shopnew/pages/category_products.dart';
import 'package:shopnew/pages/home.dart';
import 'package:shopnew/pages/onboarding.dart';
import 'package:shopnew/services/constant.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cấu hình Stripe
  Stripe.publishableKey = Publishablekey;

  // Trên Web, Stripe cần script ở index.html.
  // Trên Mobile, đôi khi cần applySettings, nhưng chúng ta bọc lại để tránh lỗi Platform
  if (!kIsWeb) {
    // Nếu bạn có cấu hình thêm cho Mobile thì để ở đây
    // await Stripe.instance.applySettings();
  }

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "shopNew",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Bạn đang để mặc định vào trang Login của Admin
      home: const AdminLogin(),
    );
  }
}