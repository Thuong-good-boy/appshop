import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopnew/Admin/AddProduct.dart';

class ManageProduct extends StatefulWidget {
  const ManageProduct({super.key});

  @override
  State<ManageProduct> createState() => _ManageProductState();
}

class _ManageProductState extends State<ManageProduct> {
  // Biến dùng để lấy dữ liệu từ Firebase theo thời gian thực
  Stream? productStream;

  // Controller dùng cho việc Sửa sản phẩm
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  // Hàm lấy dữ liệu
  getOntheLoad() async {
    productStream = FirebaseFirestore.instance.collection("Products").snapshots();
    setState(() {});
  }

  @override
  void initState() {
    getOntheLoad();
    super.initState();
  }

  // --- HÀM 1: XÓA SẢN PHẨM ---
  Future<void> deleteProduct(String id) async {
    // Hiện hộp thoại xác nhận trước khi xóa
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa sản phẩm này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Đóng hộp thoại
              await FirebaseFirestore.instance.collection("Products").doc(id).delete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã xóa sản phẩm thành công!")),
              );
            },
            child: const Text("Xóa ngay", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- HÀM 2: HIỆN POPUP SỬA SẢN PHẨM ---
  void showEditDialog(DocumentSnapshot doc) {
    // Gán dữ liệu cũ vào ô nhập
    nameController.text = doc["Name"];
    priceController.text = doc["Price"];
    detailController.text = doc["Detail"];

    String id = doc.id; // Lấy ID để biết update cái nào

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text("Chỉnh sửa sản phẩm", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            _buildTextField("Tên sản phẩm", nameController),
            const SizedBox(height: 10),
            _buildTextField("Giá tiền", priceController),
            const SizedBox(height: 10),
            _buildTextField("Mô tả chi tiết", detailController, maxLines: 3),

            const SizedBox(height: 20),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  Map<String, dynamic> updateInfo = {
                    "Name": nameController.text,
                    "Price": priceController.text,
                    "Detail": detailController.text,
                  };

                  await FirebaseFirestore.instance.collection("Products").doc(id).update(updateInfo);
                  Navigator.pop(context); // Đóng popup
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: Colors.green, content: Text("Cập nhật thành công!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFfd6f3e),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget ô nhập liệu nhỏ gọn
  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }

  // Widget hiển thị từng dòng sản phẩm
  Widget allProducts() {
    return StreamBuilder(
      stream: productStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFfd6f3e)));

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))
                ],
              ),
              child: Row(
                children: [
                  // 1. Ảnh sản phẩm
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      ds["Image"],
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 80, width: 80, color: Colors.grey[300], child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // 2. Tên và Giá
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ds["Name"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Text(ds["Price"], style: const TextStyle(color: Color(0xFFfd6f3e), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  // 3. Nút Sửa & Xóa
                  Column(
                    children: [
                      // Nút Sửa
                      GestureDetector(
                        onTap: () => showEditDialog(ds),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Nút Xóa
                      GestureDetector(
                        onTap: () => deleteProduct(ds.id),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        title: const Text("Quản lý kho hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Column(
          children: [
            Expanded(child: allProducts()),
          ],
        ),
      ),
      // Nút trôi để thêm sản phẩm mới nhanh
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           Navigator.push(context, MaterialPageRoute(builder: (context) => AddProduct()));
        },
        backgroundColor: const Color(0xFFfd6f3e),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}