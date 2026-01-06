import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import 'package:shopnew/Auth-Pages/Login.dart';
import 'package:shopnew/services/theme_provider.dart'; // 2. Import ThemeProvider

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Định nghĩa màu sắc
    Color bgColor = isDark ? Color(0xFF121212) : Color(0Xffecefe8);
    Color textColor = isDark ? Colors.white : Colors.black;
    Color buttonColor = isDark ? Colors.white : Colors.black;
    Color buttonTextColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần 1: Ảnh (Dùng Expanded để ảnh tự co giãn, không bị lỗi màn hình nhỏ)
            Expanded(
              flex: 6, // Chiếm 6 phần màn hình
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: Image.asset(
                  "images/headphone.PNG",
                  fit: BoxFit.contain, // Đảm bảo ảnh hiển thị trọn vẹn
                ),
              ),
            ),

            // Phần 2: Chữ tiêu đề
            Expanded(
              flex: 4, // Chiếm 4 phần màn hình
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "KHÁM PHÁ\nCÁC SẢN PHẨM\nTỐT NHẤT!",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        height: 1.2, // Khoảng cách giữa các dòng
                      ),
                    ),

                    Spacer(), // Đẩy nút xuống dưới

                    // Phần 3: Nút Next
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 30), // Cách đáy một chút
                            padding: EdgeInsets.all(30.0),
                            decoration: BoxDecoration(
                              color: buttonColor,
                              shape: BoxShape.circle, // Làm tròn dạng hình tròn
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                )
                              ],
                            ),
                            child: Text(
                              "Next",
                              style: TextStyle(
                                color: buttonTextColor,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}