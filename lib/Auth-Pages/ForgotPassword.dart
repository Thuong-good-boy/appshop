import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopnew/Auth-Pages/Login.dart';
import 'package:shopnew/Auth-Pages/SignUp.dart';
import 'package:shopnew/widget/support_widget.dart';
class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  bool _isLoading= false;
  TextEditingController emailcontroller= new TextEditingController();
  final _keyform= GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top:40.0,left: 20.0,right: 20.0),
          child: Form(
            key: _keyform,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("images/login.png"),
                SizedBox(height: 30.0,),
                Center(child: Text("Sign In",style: Appwidget.semiboldTextStyle(),)),
                SizedBox(height: 20.0,),
                Center(child: Text("Vui lòng nhập email để lấy lại mật khẩu.",textAlign: TextAlign.center,style: Appwidget.lightTextStyle(),)),
                SizedBox(height: 30.0,),
                Text("Email",style: Appwidget.semiboldTextStyle(),),
                SizedBox(height: 20.0,),
                Container(
                    padding: EdgeInsets.only(left: 20.0),
                    decoration: BoxDecoration(color: Color(0xFFF4F5F9),borderRadius: BorderRadius.circular(10.0)),
                    child: TextFormField(
                      validator: (value){
                        if(value==null || value.isEmpty){
                          return"Xin hãy nhập email của bạn.";
                        }
                        return null;
                      },
                      controller: emailcontroller,
                      decoration: InputDecoration(border: InputBorder.none,hintText: "Email"),)),

                SizedBox(height: 30.0,),
                Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        if(_keyform.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                                email: emailcontroller.text);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.greenAccent,
                                content:
                                Text("Email đặt lại mật khẩu đã được gởi.",
                                  style: TextStyle(fontSize: 15.0),)));
                          } on FirebaseException catch (e) {
                            String message = "Đã xảy ra lỗi.";
                            if (e.code == "user-not-found") {
                              message =
                              "Không tìm thấy người dùng với email này.";
                            } else if (e.code == "invalid-email") {
                              message = "Email không hợp lệ.";
                            }
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
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
                        minimumSize: Size(MediaQuery.of(context).size.width/2, 50),
                      ),
                      child:
                      _isLoading ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.green),):
                      Text("Xác nhận", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    )
                ),
                SizedBox(height: 20.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                SizedBox( height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Bạn chưa có tài khoản?",style: Appwidget.lightTextStyle(),),
                    GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUp()));
                        },
                        child: Text("Đăng ký ",style: TextStyle(color: Colors.green,fontWeight: FontWeight.w500,fontSize: 18.0),)),
                  ],
                ),

              ],),
          ),
        ),
      ),
    );
  }
}
