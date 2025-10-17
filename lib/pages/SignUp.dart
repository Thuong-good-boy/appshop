import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:shopnew/pages/Login.dart';
import 'package:shopnew/pages/bottomNar.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/widget/support_widget.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignInState();
}

class _SignInState extends State<SignUp> {
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
            top: 40.0,
            left: 20.0,
            right: 20.0,
            bottom: 50.0,
          ),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("images/login.png"),
                SizedBox(height: 30.0),
                Center(
                  child: Text("Sign Up", style: Appwidget.semiboldTextStyle()),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: Text(
                    "Vui lòng nhập thông tin bên dưới để\n tiếp tục.",
                    textAlign: TextAlign.center,
                    style: Appwidget.lightTextStyle(),
                  ),
                ),

                Text("Name", style: Appwidget.semiboldTextStyle()),
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F5F9),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Xin hãy nhập tên của bạn";
                      }
                      return null;
                    },
                    controller: namecontroller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Name",
                    ),
                  ),
                ),
                Text("Email", style: Appwidget.semiboldTextStyle()),
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F5F9),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Xin hãy nhập mail của bạn";
                      }
                      return null;
                    },
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Email",
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Text("Password", style: Appwidget.semiboldTextStyle()),
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F5F9),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextFormField(
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Xin hãy nhập password của bạn";
                      }
                      return null;
                    },
                    controller: passwordcontroller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Password",
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            if (_formkey.currentState!.validate()) {
                              String name = namecontroller.text;
                              String email = emailcontroller.text;
                              String password = passwordcontroller.text;
                              try {
                                UserCredential user = await FirebaseAuth
                                    .instance
                                    .createUserWithEmailAndPassword(
                                      email: email!,
                                      password: password!,
                                    );
                                String uid = user.user!.uid;
                                String avata =
                                    "https://ui-avatars.com/api/?name=${name}&background=random&format=png";
                                await Share_pref().saveUserId(uid);
                                await Share_pref().saveUserName(
                                  namecontroller.text,
                                );
                                await Share_pref().saveUserEmail(
                                  emailcontroller.text,
                                );
                                await Share_pref().saveUserImage(avata);
                                Map<String, dynamic> userInfoMap = {
                                  "ID": uid,
                                  "Name": namecontroller.text,
                                  "Email": emailcontroller.text,
                                  "Image": avata,
                                };
                                await DatabaseMethods().addUserDetails(
                                  userInfoMap,
                                  uid,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                      "đăng ký thành công! ",
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  ),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BottomNav(),
                                  ),
                                );
                              } on FirebaseException catch (e) {
                                String errorMessage = "Đã có lỗi xảy ra.";
                                if (e.code == "weak-password") {
                                  errorMessage =
                                      'Mật khẩu quá yếu, vui lòng nhập ít nhất 6 ký tự.';
                                } else if (e.code == "email-already-in-use") {
                                  errorMessage =
                                      'Email này đã được sử dụng bởi một tài khoản khác.';
                                } else if (e.code == 'invalid-email') {
                                  errorMessage =
                                      'Định dạng email không hợp lệ.';
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.redAccent,
                                    content: Text(
                                      errorMessage,
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(
                        MediaQuery.of(context).size.width / 2,
                        50,
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.green),
                          )
                        : Text(
                            "Đăng ký",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Bạn đã có tài khoản rồi?",
                      style: Appwidget.lightTextStyle(),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: Text(
                        "Đăng nhập ",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: 18.0,
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
    );
  }
}
