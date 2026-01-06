import 'dart:ui';

import 'package:flutter/material.dart';

class Appwidget{
  static TextStyle boldTextStyle(){
    return TextStyle(color: Colors.black,fontSize: 30.0,fontWeight: FontWeight.bold);
  }
  static TextStyle lightTextStyle(){
    return TextStyle(color: Colors.black45,fontSize: 10.0,fontWeight: FontWeight.w500);
  }
  static TextStyle semiboldTextStyle(){

    return TextStyle(color: Colors.black,fontSize: 20.0,fontWeight: FontWeight.bold);  }
  static  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
  static Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFFfd6f3e), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
      ),
      validator: validator,
    );
  }
  static  Widget buildFormSection({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
  static   Widget buildDynamicDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required bool isLoading,
    required void Function(T?) onChanged,
    required String? Function(T?) validator,
    required String Function(T) getItemName,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFFfd6f3e), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
        suffixIcon: isLoading
            ? Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFFfd6f3e),
            ),
          ),
        )
            : null,
      ),
      onChanged: (items.isEmpty || isLoading) ? null : onChanged,
      validator: validator,
      isExpanded: true,
      items: items.map((T item) {
        return DropdownMenuItem<T>(value: item, child: Text(getItemName(item)));
      }).toList(),
    );
  }
}
