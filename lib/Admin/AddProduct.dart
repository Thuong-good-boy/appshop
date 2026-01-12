import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopnew/services/database.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();

  bool _isLoading = false;
  String? value;
  final List<String> categoryitem = [
    'Watch', "Laptop", "TV", "Headphone", "Phone",
  ];

  final Color primaryColor = const Color(0xFFfd6f3e);

  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> uploadItem() async {
    if (selectedImage != null && namecontroller.text.isNotEmpty && value != null) {
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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Sản phẩm đã được thêm thành công"),
            ),
          );
          namecontroller.clear();
          pricecontroller.clear();
          detailcontroller.clear();
          setState(() {
            selectedImage = null;
            value = null;
          });
        }
      } catch (e) {
        print(e.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Thêm sản phẩm thất bại"),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Vui lòng điền đầy đủ thông tin và chọn ảnh"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        ),
        title: const Text("Thêm sản phẩm",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: getImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: selectedImage != null ? primaryColor : Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(selectedImage!, fit: BoxFit.cover),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_rounded, color: Colors.grey[400], size: 40),
                        const SizedBox(height: 8),
                        Text("Chọn ảnh", style: TextStyle(color: Colors.grey[600]))
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _buildTextField(
                  controller: namecontroller,
                  label: "Tên sản phẩm",
                  icon: Icons.shopping_bag_outlined
              ),
              const SizedBox(height: 20),

              _buildTextField(
                  controller: pricecontroller,
                  label: "Giá sản phẩm",
                  icon: Icons.attach_money,
                  inputType: TextInputType.number
              ),
              const SizedBox(height: 20),

              _buildTextField(
                  controller: detailcontroller,
                  label: "Mô tả chi tiết",
                  icon: Icons.description_outlined,
                  maxLines: 4
              ),
              const SizedBox(height: 20),

              Text("Danh mục", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    hint: const Text("Chọn loại sản phẩm"),
                    icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.grey),
                    items: categoryitem.map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontWeight: FontWeight.w500)),
                    )).toList(),
                    onChanged: (val) => setState(() => value = val),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : uploadItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Thêm Ngay",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFececf8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.grey),
              hintText: "Nhập $label...",
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }
}