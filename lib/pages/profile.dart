import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:shopnew/services/auth.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/services/theme_provider.dart'; // Đảm bảo đường dẫn này đúng
import 'package:shopnew/widget/support_widget.dart';
import 'package:shopnew/pages/onboarding.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? image, name, email;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getthesharedpref();
  }

  getthesharedpref() async {
    image = await Share_pref().getUserImage();
    name = await Share_pref().getUserName();
    email = await Share_pref().getUserEmail();
    setState(() {});
  }

  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        _isLoading = true; // Bật loading
      });
      uploadItem();
    }
  }

  Future<void> uploadItem() async {
    if (selectedImage != null) {
      final cloudinary = CloudinaryPublic(
        "dzztoxy1d",
        "saslqhh5",
        cache: false,
      );
      try {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            selectedImage!.path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        String imageUrl = response.secureUrl;
        await Share_pref().saveUserImage(imageUrl);
        // Cập nhật lại UI sau khi upload xong
        setState(() {
          image = imageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Cập nhật ảnh thành công!"),
          ),
        );
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Thay đổi thất bại"),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy theme hiện tại để xử lý màu sắc
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      // Màu nền tự động theo theme
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Thông tin cá nhân",
          style: Appwidget.boldTextStyle().copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: name == null
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView( // Thêm cái này để không bị lỗi tràn màn hình
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: [
              // --- Phần ảnh đại diện ---
              GestureDetector(
                onTap: () {
                  getImage();
                },
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4), // Viền trắng/đen nhẹ
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.grey : Colors.green,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60.0),
                          child: selectedImage != null
                              ? Image.file(
                            selectedImage!,
                            width: 120.0,
                            height: 120.0,
                            fit: BoxFit.cover,
                          )
                              : Image.network(
                            image ?? "https://i.imgur.com/BoN9kdC.png", // Ảnh mặc định nếu null
                            width: 120.0,
                            height: 120.0,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.person, size: 60),
                          ),
                        ),
                      ),
                      if (_isLoading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30.0),

              // --- Các ô thông tin ---

              // Tên
              _buildProfileOption(
                context,
                icon: Icons.person_outline,
                title: "Họ và tên",
                subtitle: name!,
                isDark: isDark,
              ),

              // Email
              _buildProfileOption(
                context,
                icon: Icons.mail_outline,
                title: "Email",
                subtitle: email!,
                isDark: isDark,
              ),

              // --- NÚT DARK MODE MỚI ---
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Material(
                  elevation: 2.0,
                  borderRadius: BorderRadius.circular(15.0),
                  color: Theme.of(context).cardColor, // Màu thẻ động
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          size: 30.0,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        SizedBox(width: 20.0),
                        Text(
                          isDark ? "Chế độ sáng" : "Chế độ tối",
                          style: Appwidget.semiboldTextStyle().copyWith(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Spacer(),
                        Switch(
                          value: isDark,
                          activeColor: Colors.green,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Đăng xuất
              _buildProfileOption(
                context,
                icon: Icons.logout,
                title: "Đăng xuất",
                subtitle: "",
                isDark: isDark,
                isAction: true,
                onTap: () async {
                  await AuthMethods().SignOut().then((value) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Onboarding()));
                  });
                },
              ),

              // Xóa tài khoản
              _buildProfileOption(
                context,
                icon: Icons.delete_outline,
                title: "Xóa tài khoản",
                subtitle: "",
                isDark: isDark,
                isAction: true,
                textColor: Colors.redAccent,
                onTap: () async {
                  // Nên thêm Dialog xác nhận ở đây nếu có thời gian
                  await AuthMethods().deleteuser().then((value) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Onboarding()));
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget con để tái sử dụng code cho đẹp và gọn
  Widget _buildProfileOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required bool isDark,
        bool isAction = false,
        Color? textColor,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Material(
          elevation: 2.0, // Đổ bóng nhẹ
          borderRadius: BorderRadius.circular(15.0), // Bo góc tròn hơn
          color: Theme.of(context).cardColor, // Màu nền thẻ tự động đổi
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 30.0,
                  color: textColor ?? (isDark ? Colors.white70 : Colors.black54),
                ),
                SizedBox(width: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isAction) // Chỉ hiện tiêu đề nhỏ nếu không phải nút hành động
                      Text(
                        title,
                        style: Appwidget.lightTextStyle().copyWith(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    Text(
                      isAction ? title : subtitle,
                      style: Appwidget.semiboldTextStyle().copyWith(
                        color: textColor ?? (isDark ? Colors.white : Colors.black),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                if (isAction)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: isDark ? Colors.white54 : Colors.black38,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}