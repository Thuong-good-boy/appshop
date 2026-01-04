import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:shopnew/Auth-Pages/Login.dart';
import 'package:shopnew/Auth-Pages/SignUp.dart';
import 'package:shopnew/services/theme_provider.dart'; // Đảm bảo đường dẫn đúng
import 'package:shopnew/widget/support_widget.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  bool _isLoading = false;
  TextEditingController emailcontroller = TextEditingController();
  final _keyform = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Lấy theme
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Màu sắc động
    final Color inputFillColor = isDark ? Color(0xFF1E1E1E) : Color(0xFFF4F5F9);
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color hintColor = isDark ? Colors.white54 : Colors.black45;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Form(
              key: _keyform,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nút back nhỏ ở góc trên (tùy chọn, nếu thích thì giữ, không thì xóa)
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Ảnh minh họa
                  Center(
                    child: Image.asset(
                      "images/login.png",
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 30.0),

                  // Tiêu đề
                  Center(
                    child: Text(
                      "Khôi Phục Mật Khẩu",
                      style: Appwidget.semiboldTextStyle().copyWith(
                        fontSize: 24,
                        color: textColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Center(
                    child: Text(
                      "Nhập email đã đăng ký để nhận đường dẫn\nđặt lại mật khẩu.",
                      textAlign: TextAlign.center,
                      style: Appwidget.lightTextStyle().copyWith(
                        color: hintColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.0),

                  // Input Email
                  Text("Email", style: Appwidget.semiboldTextStyle().copyWith(color: textColor)),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: emailcontroller,
                    style: TextStyle(color: textColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Xin hãy nhập email của bạn.";
                      }
                      // Kiểm tra định dạng email cơ bản
                      if (!value.contains('@')) {
                        return "Email không hợp lệ.";
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

                  SizedBox(height: 30.0),

                  // Nút Gửi
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                          if (_keyform.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await FirebaseAuth.instance.sendPasswordResetEmail(
                                  email: emailcontroller.text.trim());

                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text(
                                    "Đã gửi email! Vui lòng kiểm tra hộp thư.",
                                    style: TextStyle(fontSize: 15.0),
                                  )));

                              // Tùy chọn: Sau khi gửi xong thì quay về trang Login luôn
                              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));

                            } on FirebaseAuthException catch (e) {
                              String message = "Đã xảy ra lỗi.";
                              if (e.code == "user-not-found") {
                                message = "Email này chưa được đăng ký.";
                              } else if (e.code == "invalid-email") {
                                message = "Định dạng email không hợp lệ.";
                              }
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  backgroundColor: Colors.redAccent,
                                  content: Text(
                                    message,
                                    style: TextStyle(fontSize: 15.0),
                                  )));
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5.0,
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white))
                            : Text(
                          "Gửi Yêu Cầu",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),

                  // Nút quay lại Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Đã nhớ ra mật khẩu? ", style: Appwidget.lightTextStyle().copyWith(color: textColor)),
                      GestureDetector(
                        onTap: () {
                          // Dùng pop để quay lại trang trước thay vì push chồng lên
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        child: Text(
                          "Đăng nhập",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),

                  // Nút Đăng ký (Phụ)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Chưa có tài khoản? ", style: Appwidget.lightTextStyle().copyWith(color: textColor)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => SignUp()));
                        },
                        child: Text(
                          "Đăng ký",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
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