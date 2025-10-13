import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopnew/pages/SignUp.dart';
import 'package:shopnew/pages/bottomNar.dart';
import 'package:shopnew/widget/support_widget.dart';
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController passwordcontroller= new TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool _isLoading= false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top:40.0,left: 20.0,right: 20.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("images/login.png"),
                SizedBox(height: 30.0,),
                Center(child: Text("Sign In",style: Appwidget.semiboldTextStyle(),)),
                SizedBox(height: 20.0,),
                Center(child: Text("Vui lòng nhập thông tin bên dưới để\n tiếp tục.",textAlign: TextAlign.center,style: Appwidget.lightTextStyle(),)),
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
                SizedBox(height: 20.0,),
                Text("Password",style: Appwidget.semiboldTextStyle(),),
                SizedBox(height: 20.0,),
                Container(
                    padding: EdgeInsets.only(left: 20.0),
                    decoration: BoxDecoration(color: Color(0xFFF4F5F9),borderRadius: BorderRadius.circular(10.0)),
                    child: TextFormField(
                      validator: (value){
                        if(value==null || value.isEmpty){
                          return"Hãy nhập mật khẩu của bạn.";
                        }
                        return null;
                      },
                      obscureText: true,
                     controller: passwordcontroller,
                      decoration: InputDecoration(border: InputBorder.none,hintText: "Password"),)),
                SizedBox(height: 20.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Quên mật khẩu?",style: TextStyle(color: Colors.green,fontWeight: FontWeight.w500,fontSize: 18.0),),
                  ],
                ),
                SizedBox(height: 30.0,),
                Center(
                  child: ElevatedButton(
                      
                      onPressed: _isLoading ? null : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          if(_formkey.currentState!.validate()){
                            String  email= emailcontroller.text;
                            String  password= passwordcontroller.text;
                          try{
                            await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.greenAccent,
                              content: Text("Đăng nhập thành công!",style: TextStyle(fontSize: 15.0),)));
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>BottomNav()));
                          }on FirebaseException catch(e){
                            if(e.code == "invalid-credential"){
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: Text("Email hoặc mật khẩu không chính xác.",style: TextStyle(fontSize: 15.0),)));
                            }
                          }finally{
                            setState(() {
                              _isLoading = false;
                            });
                          }
                          };
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(MediaQuery.of(context).size.width/2, 50),
                    ),
                      child: 
                      _isLoading ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.green),):
                      Text("Đăng nhập", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                  )
                ),
                SizedBox(height: 20.0,),

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
