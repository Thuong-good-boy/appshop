
import 'package:flutter/material.dart';
import 'package:shopnew/Auth-Pages/Login.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0Xffecefe8),
      body: Container(
        margin: EdgeInsets.only(top: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("images/headphone.PNG"),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text("KHÁM PHÁ\nCÁC SẢN PHẨM\n TỐT NHẤT!",style: TextStyle(color: Colors.black,fontSize: 40.0,fontWeight: FontWeight.bold),),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
                      },
                  child: Container(
                    margin: EdgeInsets.only(right: 40,top: 40),
                    padding: EdgeInsets.all(30.0),
                    decoration: BoxDecoration(color: Colors.black,borderRadius: BorderRadius.circular(120)),
                    child: Text("Next",style: TextStyle(color: Colors.white,fontSize: 20.0,fontWeight: FontWeight.bold),),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
