import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/widget/support_widget.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController pricecontroller = new TextEditingController();
  TextEditingController detailcontroller = new TextEditingController();

  bool _isLoading = false;

  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> uploadItem() async {
    if (selectedImage != null &&
        namecontroller.text.isNotEmpty &&
        value != null) {
      setState(() {
        _isLoading = true;
      });

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
        String firstletter = namecontroller.text.substring(0, 1).toUpperCase();
        Map<String, dynamic> addProduct = {
          "Name": namecontroller.text,
          "Image": imageUrl,
          "SearchKey": firstletter,
          "UpdateName": namecontroller.text.toUpperCase(),
          "Price": pricecontroller.text,
          "Detail": detailcontroller.text,
        };

        await DatabaseMethods().addProduct(addProduct, value!);
        await DatabaseMethods().addAllProducts(addProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Sản phẩm đã được thêm thành công"),
          ),
        );
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Thêm sản phẩm thất bại"),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // Tắt loading dù thành công hay thất bại
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Vui lòng điền đầy đủ thông tin và chọn ảnh"),
        ),
      );
    }
  }

  String? value;
  final List<String> categoryitem = [
    'Watch',
    "Laptop",
    "TV",
    "Headphone",
    "Phone",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: Container(
          margin: EdgeInsets.only(left: 30.0),
          child: Text("Thêm sản phẩm", style: Appwidget.boldTextStyle()),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(right: 20.0, left: 20.0, bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  "Cập nhật ảnh sản phẩm",
                  style: Appwidget.lightTextStyle(),
                ),
              ),
              SizedBox(height: 30.0),
              GestureDetector(
                onTap: () {
                  getImage();
                },
                child: Center(
                  child: Container(
                    width: 150.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.camera_alt_outlined),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              Container(
                child: Text("Tên sản phẩm", style: Appwidget.lightTextStyle()),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  controller: namecontroller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hint: Text(
                      "Tên sản phẩm",
                      style: TextStyle(fontSize: 15.0, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              Container(
                child: Text("Giá sản phẩm", style: Appwidget.lightTextStyle()),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  controller: pricecontroller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hint: Text(
                      "Giá sản phẩm",
                      style: TextStyle(fontSize: 15.0, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              Container(
                child: Text(
                  "Mô tả sản phẩm",
                  style: Appwidget.lightTextStyle(),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  maxLines: 6,
                  controller: detailcontroller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hint: Text(
                      "Mô tả sản phẩm",
                      style: TextStyle(fontSize: 15.0, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text("Danh mục sản phẩm", style: Appwidget.lightTextStyle()),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    // Giúp dropdown chiếm hết chiều rộng
                    items: categoryitem
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: Appwidget.semiboldTextStyle(),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => {
                      setState(() {
                        this.value = value;
                      }),
                    },
                    dropdownColor: Colors.white,
                    hint: Text("Danh mục"),
                    iconSize: 36,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                    value: value,
                  ),
                ),
              ),
              SizedBox(height: 40.0),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : uploadItem,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Thêm danh mục", style: TextStyle(fontSize: 22.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
