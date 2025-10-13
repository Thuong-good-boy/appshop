import 'dart:ui';

import 'package:flutter/material.dart';

class Appwidget{
  static TextStyle boldTextStyle(){
    return TextStyle(color: Colors.black,fontSize: 30.0,fontWeight: FontWeight.bold);
  }
  static TextStyle lightTextStyle(){
    return TextStyle(color: Colors.black45,fontSize: 20.0,fontWeight: FontWeight.w500);
  }
  static TextStyle semiboldTextStyle(){

    return TextStyle(color: Colors.black,fontSize: 20.0,fontWeight: FontWeight.bold);  }
}