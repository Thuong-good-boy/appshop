import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopnew/Admin/HomeAdmin.dart';
import 'package:shopnew/widget/support_widget.dart';
class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  TextEditingController usernamecontroller= new TextEditingController();
  TextEditingController userpasswordcontroller= new TextEditingController();
  bool _isLoading= false;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top:40.0,left: 20.0,right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("images/login.png"),
                SizedBox(height: 30.0,),
                Center(child: Text("Admin Panel",style: Appwidget.semiboldTextStyle(),)),
                SizedBox(height: 20.0,),
                Text("userName",style: Appwidget.semiboldTextStyle(),),
                SizedBox(height: 20.0,),
                Container(
                    padding: EdgeInsets.only(left: 20.0),
                    decoration: BoxDecoration(color: Color(0xFFF4F5F9),borderRadius: BorderRadius.circular(10.0)),
                    child: TextFormField(
                      controller: usernamecontroller,
                      decoration: InputDecoration(border: InputBorder.none,hintText: "UserName"),)),
                SizedBox(height: 20.0,),
                Text("userPassword",style: Appwidget.semiboldTextStyle(),),
                SizedBox(height: 20.0,),
                Container(
                    padding: EdgeInsets.only(left: 20.0),
                    decoration: BoxDecoration(color: Color(0xFFF4F5F9),borderRadius: BorderRadius.circular(10.0)),
                    child: TextFormField(

                      obscureText: true,
                      controller: userpasswordcontroller,
                      decoration: InputDecoration(border: InputBorder.none,hintText: "Password"),)),
                SizedBox(height: 30.0,),
                Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null: () async {
                        setState(() {
                          _isLoading=true;
                        });
                        String userName = usernamecontroller.text.trim();
                        String userPassword = userpasswordcontroller.text.trim();
                        if(userName.isEmpty || userPassword.isEmpty){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text("Vui lòng nhập đủ thông tin!",style: TextStyle(fontSize: 15.0),)));
                          return;
                        }
                        try{
                          final QuerySnapshot snapshot = await FirebaseFirestore.instance
                          .collection("Admin").where("userName",isEqualTo : userName).get();
                          if(snapshot.docs.isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Text("Tài khoản sai!",style: TextStyle(fontSize: 15.0),)));
                          }else{
                            final useradmin= snapshot.docs.first;
                            if(useradmin.get("userPassword")==userPassword){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.greenAccent,
                              content: Text("Chào mừng anh Thương!",style: TextStyle(fontSize: 15.0),)));
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeAdmin()));
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text("Mật khẩu sai!",style: TextStyle(fontSize: 15.0),)));
                            }

                          }

                        }catch(e){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text("Đã lỗi, vui lòng thử lại!",style: TextStyle(fontSize: 15.0),)));
                        }finally{
                          if(mounted){
                            setState(() {
                              _isLoading=false;
                            });
                          }
                        }


                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(MediaQuery.of(context).size.width/2, 50),
                      ),

                      child: _isLoading ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.green),):
                      Text("Đăng nhập", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    )
                ),

              ],),
          ),
        ),
      );
  }
}
