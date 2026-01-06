import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  Stream? userStream;

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  getUsers() async {
    userStream = FirebaseFirestore.instance.collection("users").snapshots();
    setState(() {});
  }

  Future<void> deleteUser(String id, String name) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa tài khoản?"),
        content: Text("Bạn có chắc muốn xóa người dùng '$name' vĩnh viễn không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              await FirebaseFirestore.instance.collection("users").doc(id).delete();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã xóa người dùng thành công!")),
              );
            },
            child: const Text("Xóa ngay", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget allUsers() {
    return StreamBuilder(
      stream: userStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFfd6f3e)));
        }

        if (snapshot.data.docs.isEmpty) {
          return const Center(child: Text("Chưa có người dùng nào.", style: TextStyle(fontSize: 16, color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];

            String name = (ds.data() as Map<String, dynamic>).containsKey('Name') ? ds['Name'] : 'No Name';
            String email = (ds.data() as Map<String, dynamic>).containsKey('Email') ? ds['Email'] : 'No Email';
            String image = (ds.data() as Map<String, dynamic>).containsKey('Image') ? ds['Image'] : '';

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60), // Bo tròn thành hình tròn
                    child: image.isNotEmpty
                        ? Image.network(
                      image,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                    )
                        : _buildDefaultAvatar(),
                  ),
                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),

                  // 3. Nút Xóa
                  GestureDetector(
                    onTap: () => deleteUser(ds.id, name),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      height: 60,
      width: 60,
      color: Colors.grey[300],
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        title: const Text("Quản lý khách hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
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
        child: allUsers(),
      ),
    );
  }
}