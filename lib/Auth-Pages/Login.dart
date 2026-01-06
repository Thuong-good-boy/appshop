import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:shopnew/Auth-Pages/ForgotPassword.dart';
import 'package:shopnew/Auth-Pages/SignUp.dart';
import 'package:shopnew/pages/bottomNar.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/services/theme_provider.dart'; // Đảm bảo đường dẫn đúng
import 'package:shopnew/widget/support_widget.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPasswordVisible = false; // Biến để ẩn/hiện mật khẩu

  @override
  Widget build(BuildContext context) {
    // Lấy trạng thái theme
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Định nghĩa màu sắc dựa trên theme
    final Color inputFillColor = isDark ? Color(0xFF1E1E1E) : Color(0xFFF4F5F9);
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color hintColor = isDark ? Colors.white54 : Colors.black45;

    return Scaffold(
      // Màu nền lấy từ Theme hệ thống (đã cài ở main.dart)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea( // Dùng SafeArea để không bị che bởi tai thỏ
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Ảnh minh họa ---
                  Center(
                    child: Image.asset(
                      "images/login.png",
                      height: 200, // Giới hạn chiều cao để không chiếm hết màn hình
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 30.0),

                  // --- Tiêu đề ---
                  Center(
                    child: Text(
                      "Đăng Nhập",
                      style: Appwidget.semiboldTextStyle().copyWith(
                        fontSize: 28,
                        color: textColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Center(
                    child: Text(
                      "Vui lòng nhập thông tin bên dưới để\n tiếp tục.",
                      textAlign: TextAlign.center,
                      style: Appwidget.lightTextStyle().copyWith(
                        color: hintColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.0),

                  // --- Input Email ---
                  Text(
                    "Email",
                    style: Appwidget.semiboldTextStyle().copyWith(color: textColor),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: emailcontroller,
                    style: TextStyle(color: textColor), // Màu chữ khi gõ
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Xin hãy nhập email của bạn.";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      hintText: "Nhập email...",
                      hintStyle: TextStyle(color: hintColor),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.green),
                    ),
                  ),
                  SizedBox(height: 20.0),

                  // --- Input Password ---
                  Text(
                    "Mật khẩu",
                    style: Appwidget.semiboldTextStyle().copyWith(color: textColor),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: passwordcontroller,
                    style: TextStyle(color: textColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Hãy nhập mật khẩu của bạn.";
                      }
                      return null;
                    },
                    obscureText: !_isPasswordVisible, // Logic ẩn hiện
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      hintText: "Nhập mật khẩu...",
                      hintStyle: TextStyle(color: hintColor),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.green),
                      // Nút con mắt để ẩn/hiện mật khẩu
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: hintColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),

                  // --- Quên mật khẩu ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Forgotpassword()));
                        },
                        child: Text(
                          "Quên mật khẩu?",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.0),

                  // --- Nút Đăng Nhập ---
                  Center(
                    child: SizedBox(
                      width: double.infinity, // Nút full chiều ngang
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            String email = emailcontroller.text.trim();
                            String password = passwordcontroller.text.trim();
                            try {
                              UserCredential user = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                  email: email, password: password);
                              if (user.user != null) {
                                await Share_pref()
                                    .saveUserEmail(user.user!.email!);
                                await Share_pref()
                                    .saveUserId(user.user!.uid);
                                DocumentSnapshot userDoc = await DatabaseMethods()
                                    .getUserbyUid(user.user!.uid);
                                if (userDoc.exists) {
                                  String name = userDoc.get("Name");
                                  String image = userDoc.get("Image");
                                  await Share_pref().saveUserName(name);
                                  await Share_pref().saveUserImage(image);
                                }
                              }

                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text("Đăng nhập thành công!",
                                      style: TextStyle(fontSize: 16.0))));
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) => BottomNav()));
                            } on FirebaseAuthException catch (e) {
                              String errorMsg = "Đã xảy ra lỗi";
                              if (e.code == "invalid-credential" || e.code == 'user-not-found' || e.code == 'wrong-password') {
                                errorMsg = "Email hoặc mật khẩu không chính xác.";
                              }
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  backgroundColor: Colors.redAccent,
                                  content: Text(errorMsg,
                                      style: TextStyle(fontSize: 16.0))));
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white, // Màu chữ nút
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5.0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                            : Text(
                          "ĐĂNG NHẬP",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bạn chưa có tài khoản? ",
                        style: Appwidget.lightTextStyle().copyWith(color: textColor),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => SignUp()));
                        },
                        child: Text(
                          "Đăng ký ngay",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}