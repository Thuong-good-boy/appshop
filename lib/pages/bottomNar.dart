import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shopnew/pages/Order.dart';
import 'package:shopnew/pages/home.dart';
import 'package:shopnew/pages/profile.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}


class _BottomNavState extends State<BottomNav> {
  late List<Widget>pages;

  late Home HomePage;
  late Order OrderPage;
  late Profile ProfilePage;

  int currentTabIndex =0;

  @override
  void initState() {
    HomePage = Home();
    OrderPage = Order();
    ProfilePage = Profile();

    pages=[Home(),Order(),Profile()];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          height: 65,
          backgroundColor: Color(0xfff2f2f2),
          color: Colors.black,
          animationDuration: Duration(milliseconds: 500),
          onTap: (int index){
            setState(() {
              currentTabIndex =index;
            });
          },
          items: [
            Icon(Icons.home_outlined,color: Colors.white,),
            Icon(Icons.shopping_bag_outlined,color: Colors.white,),
            Icon(Icons.person_outline,color: Colors.white,),
          ]),
      body: pages[currentTabIndex],
    );
  }
}
