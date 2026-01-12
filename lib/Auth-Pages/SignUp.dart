import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:shopnew/Auth-Pages/Login.dart';
import 'package:shopnew/pages/bottomNar.dart';
import 'package:shopnew/services/EmailService.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/services/theme_provider.dart'; // Đảm bảo đường dẫn đúng
import 'package:shopnew/widget/support_widget.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController(); // Controller riêng cho xác nhận

  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Biến quản lý ẩn hiện mật khẩu cho 2 ô
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh minh họa
                  Center(
                    child: Image.asset(
                      "images/login.png",
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 20.0),

                  // Tiêu đề
                  Center(
                    child: Text(
                      "Đăng Ký",
                      style: Appwidget.semiboldTextStyle().copyWith(
                        fontSize: 28,
                        color: textColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Center(
                    child: Text(
                      "Điền thông tin bên dưới để tạo tài khoản mới.",
                      textAlign: TextAlign.center,
                      style: Appwidget.lightTextStyle().copyWith(
                        color: hintColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),

                  // --- HỌ TÊN ---
                  Text("Họ và tên", style: Appwidget.semiboldTextStyle().copyWith(color: textColor)),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: namecontroller,
                    style: TextStyle(color: textColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Xin hãy nhập tên của bạn";
                      return null;
                    },
                    decoration: _buildInputDecoration("Nhập họ tên...", Icons.person_outline, inputFillColor, hintColor),
                  ),
                  SizedBox(height: 20.0),

                  Text("Email", style: Appwidget.semiboldTextStyle().copyWith(color: textColor)),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: emailcontroller,
                    style: TextStyle(color: textColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Xin hãy nhập email";
                      if (!value.contains('@')) return "Email không hợp lệ";
                      return null;
                    },
                    decoration: _buildInputDecoration("Nhập email...", Icons.email_outlined, inputFillColor, hintColor),
                  ),
                  SizedBox(height: 20.0),

                  Text("Mật khẩu", style: Appwidget.semiboldTextStyle().copyWith(color: textColor)),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: passwordcontroller,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(color: textColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Xin hãy nhập mật khẩu";
                      if (value.length < 6) return "Mật khẩu phải từ 6 ký tự";
                      return null;
                    },
                    decoration: _buildInputDecoration(
                        "Nhập mật khẩu...",
                        Icons.lock_outline,
                        inputFillColor,
                        hintColor,
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: hintColor),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        )
                    ),
                  ),
                  SizedBox(height: 20.0),

                  Text("Xác nhận mật khẩu", style: Appwidget.semiboldTextStyle().copyWith(color: textColor)),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    style: TextStyle(color: textColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Hãy nhập lại mật khẩu";
                      if (value != passwordcontroller.text) return "Mật khẩu không khớp";
                      return null;
                    },
                    decoration: _buildInputDecoration(
                        "Nhập lại mật khẩu...",
                        Icons.lock_outline,
                        inputFillColor,
                        hintColor,
                        suffixIcon: IconButton(
                          icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: hintColor),
                          onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                        )
                    ),
                  ),
                  SizedBox(height: 40.0),

                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          elevation: 5.0,
                        ),
                        child: _isLoading
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : Text("ĐĂNG KÝ", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Bạn đã có tài khoản rồi? ", style: Appwidget.lightTextStyle().copyWith(color: textColor)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                        },
                        child: Text("Đăng nhập", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16.0)),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon, Color fillColor, Color hintColor, {Widget? suffixIcon}) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      hintText: hint,
      hintStyle: TextStyle(color: hintColor),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none),
      prefixIcon: Icon(icon, color: Colors.green),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _handleSignUp() async {
    if (_formkey.currentState!.validate()) {
      setState(() => _isLoading = true);
      String name = namecontroller.text.trim();
      String email = emailcontroller.text.trim();
      String password = passwordcontroller.text.trim();

      try {
        UserCredential user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password
        );

        String uid = user.user!.uid;
        String avata = "https://ui-avatars.com/api/?name=${name}&background=random&color=fff&size=128";

        await Share_pref().saveUserId(uid);
        await Share_pref().saveUserName(name);
        await Share_pref().saveUserEmail(email);
        await Share_pref().saveUserImage(avata);

        Map<String, dynamic> userInfoMap = {
          "ID": uid,
          "Name": name,
          "Email": email,
          "Image": avata,
        };

        await DatabaseMethods().addUserDetails(userInfoMap, uid);

        try {
          EmailService.sendRegistrationSuccess(email, name);
        } catch (e) {
          print("Lỗi gửi mail: $e");
        }

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.green, content: Text("Đăng ký thành công!"))
        );

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNav()));

      } on FirebaseAuthException catch (e) {
        String errorMessage = "Đã có lỗi xảy ra.";
        if (e.code == "weak-password") errorMessage = 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
        else if (e.code == "email-already-in-use") errorMessage = 'Email này đã được sử dụng.';
        else if (e.code == 'invalid-email') errorMessage = 'Định dạng email không hợp lệ.';

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.redAccent, content: Text(errorMessage))
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}