import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart'; // 1. Mới thêm: Provider
import 'package:shopnew/services/theme_provider.dart'; // 2. Mới thêm: Kiểm tra lại đường dẫn file này nếu nó báo đỏ

// Các import cũ của bạn giữ nguyên
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

  Stripe.publishableKey = Publishablekey;

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Thay đổi: Bọc MyApp trong ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "shopNew",
      debugShowCheckedModeBanner: false,

      // 4. Thay đổi: Cấu hình ThemeMode lấy từ Provider
      themeMode: Provider.of<ThemeProvider>(context).themeMode,

      // Cấu hình giao diện Sáng (Light Mode)
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xfff2f2f2), // Màu nền xám như cũ
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // Cấu hình giao diện Tối (Dark Mode)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF121212), // Màu nền đen
        useMaterial3: true,
      ),

      home: const Login(),
    );
  }
}