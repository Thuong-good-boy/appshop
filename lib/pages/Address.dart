import 'package:flutter/material.dart';
import 'dart:convert'; // Cần để giải mã JSON
import 'package:http/http.dart' as http;
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/widget/support_widget.dart'; // Cần để gọi API

// Model cho Tỉnh/Thành
class Province {
  final int code;
  final String name;
  Province({required this.code, required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(code: json['code'], name: json['name']);
  }
}

// Model cho Quận/Huyện
class District {
  final int code;
  final String name;

  District({required this.code, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(code: json['code'], name: json['name']);
  }
}

// Model cho Phường/Xã
class Ward {
  final int code;
  final String name;

  Ward({required this.code, required this.name});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(code: json['code'], name: json['name']);
  }
}
// ---------------------------------------------

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  String? email;
  getontheload() async{
    email= await Share_pref().getUserEmail();
    setState(() {

    });
  }

  final _formKey = GlobalKey<FormState>();

  // Controllers cho người đặt hàng
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressLineController = TextEditingController();

  // --- THÊM MỚI: Controllers cho người nhận hàng (nếu khác) ---
  final receiverNameController = TextEditingController();
  final receiverPhoneController = TextEditingController();

  // -----------------------------------------------------

  // --- THÊM MỚI: Các biến trạng thái cho UI ---
  String gioitinh = "Anh"; // Mặc định là "Anh"
  int deliveryMethod = 0; // 0: Giao tận nơi, 1: Nhận tại siêu thị
  bool isDifferentReceiver = false; // Checkbox "Người khác nhận hàng"
  // ------------------------------------------

  // list để bỏ vào items địa chỉ
  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  // Trạng thái loading
  bool isProvincesLoading = false;
  bool isDistrictsLoading = false;
  bool isWardsLoading = false;
  bool isloading= false;

  @override
  void initState() {
    super.initState();
    getontheload();
    fetchProvinces();
  }

  // --- CÁC HÀM GỌI API (giữ nguyên) ---
  Future<void> fetchProvinces() async {
    setState(() => isProvincesLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://provinces.open-api.vn/api/p/'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          provinces = data.map((json) => Province.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print("Lỗi khi tải Tỉnh/Thành: $e");
    } finally {
      if (mounted) setState(() => isProvincesLoading = false);
    }
  }

  Future<void> fetchDistricts(int provinceCode) async {
    setState(() => isDistrictsLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://provinces.open-api.vn/api/p/$provinceCode?depth=2'),
      );
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> districtData = data['districts'];
        setState(() {
          districts = districtData
              .map((json) => District.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      print("Lỗi khi tải Quận/Huyện: $e");
    } finally {
      if (mounted) setState(() => isDistrictsLoading = false);
    }
  }

  Future<void> fetchWards(int districtCode) async {
    setState(() => isWardsLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://provinces.open-api.vn/api/d/$districtCode?depth=2'),
      );
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> wardData = data['wards'];
        setState(() {
          wards = wardData.map((json) => Ward.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print("Lỗi khi tải Phường/Xã: $e");
    } finally {
      if (mounted) setState(() => isWardsLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressLineController.dispose();
    receiverNameController.dispose();
    receiverPhoneController.dispose();
    super.dispose();
  }

  void submitAddress()  async{
    setState(() {
      isloading= true;
    });
    try{
    if (_formKey.currentState!.validate()) {
      if (email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: Không tìm thấy email người dùng. Vui lòng thử đăng nhập lại.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Dừng hàm submit lại
      }
      Map<String, String> addressInfoMap = {
        // Thông tin người đặt
        'Email' : email!,
        'Gioitinh': gioitinh,
        'Name': nameController.text,
        'Phone': phoneController.text,

        // Hình thức giao hàng
        'Delivery': deliveryMethod == 0
            ? "Giao tận nơi"
            : "Nhận tại siêu thị",

        // Người nhận (nếu có)
        'Is_different_receiver': isDifferentReceiver.toString(),
        'Receiver_name': isDifferentReceiver
            ? receiverNameController.text
            : nameController.text,
        'Receiver_phone': isDifferentReceiver
            ? receiverPhoneController.text
            : phoneController.text,
      };

      if (deliveryMethod == 0) {
        addressInfoMap.addAll({
          'Line': addressLineController.text,
          'Ward': selectedWard!.name,
          'District': selectedDistrict!.name,
          // --- CÁC TRƯỜNG CHUẨN CHO STRIPE ADDRESS ---
          'City': selectedProvince!.name,
          'State': selectedProvince!.name,
          'Country': 'VN',
        });
      }
        await DatabaseMethods().Address(addressInfoMap);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin bắt buộc.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    }catch (e){
      print(e);
    }finally{
      setState(() {
        isloading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thông tin giao hàng",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
            child: Icon(Icons.arrow_back_ios_new_outlined)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Color(0xfff2f2f2), // Nền xám nhạt cho đẹp
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Appwidget.buildSectionTitle("Thông tin người đặt"),
                Appwidget.buildFormSection(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("Anh"),
                              value: "Anh",
                              groupValue: gioitinh,
                              onChanged: (value) => setState(() {
                                gioitinh = value!;
                              }),
                              activeColor: Color(0xFFfd6f3e),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              title: const Text("Chị"),
                              value: "Nữ",
                              groupValue: gioitinh,
                              onChanged: (value) => setState(() {
                                gioitinh = value!;
                              }),
                            ),
                          ),
                        ],
                      ),
                      Appwidget.buildTextFormField(
                        controller: nameController,
                        label: "Họ và tên",
                        hint: "Nhập họ tên đầy đủ",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập họ tên';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Appwidget.buildTextFormField(
                        controller: phoneController,
                        label: "Số điện thoại",
                        hint: "Nhập số điện thoại",
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          if (value.length < 10) {
                            return 'Số điện thoại không hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Appwidget.buildSectionTitle("Chọn hình thức giao hàng"),
                Container(
                  width: double.infinity,
                  child: ToggleButtons(
                    isSelected: [deliveryMethod == 0, deliveryMethod == 1],
                    onPressed: (int index) {
                      setState(() {
                        deliveryMethod = index;
                        // Nếu chọn "Nhận tại siêu thị", xóa validate của form địa chỉ (nếu có)
                        if (index == 1) {
                          _formKey.currentState?.validate();
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10.0),
                    selectedColor: Colors.white,
                    fillColor: Color(0xFFfd6f3e),
                    color: Color(0xFFfd6f3e),
                    borderColor: Color(0xFFfd6f3e),
                    selectedBorderColor: Color(0xFFfd6f3e),
                    constraints: BoxConstraints(
                      minHeight: 50.0,
                      minWidth: (MediaQuery.of(context).size.width - 36) / 2,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_shipping_outlined),
                            SizedBox(width: 8),
                            Text('Giao tận nơi'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store_outlined),
                            SizedBox(width: 8),
                            Text('Nhận tại siêu thị'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // --- ẨN/HIỆN FORM ĐỊA CHỈ ---
                if (deliveryMethod == 0) // Chỉ hiện khi chọn "Giao tận nơi"
                  Appwidget.buildFormSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Địa chỉ nhận hàng",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        Appwidget.buildDynamicDropdown <Province>(
                          hint: "Chọn Tỉnh/Thành phố",
                          value: selectedProvince,
                          items: provinces,
                          isLoading: isProvincesLoading,
                          onChanged: (value) {
                            setState(() {
                              selectedProvince = value;
                              selectedDistrict = null;
                              selectedWard = null;
                              districts = [];
                              wards = [];
                            });
                            if (value != null) fetchDistricts(value.code);
                          },
                          validator: (value) =>
                              (deliveryMethod == 0 && value == null)
                              ? 'Vui lòng chọn Tỉnh/Thành'
                              : null,
                          getItemName: (province) => province.name,
                        ),
                        SizedBox(height: 16),
                        Appwidget.buildDynamicDropdown<District>(
                          hint: selectedProvince == null
                              ? "Vui lòng chọn Tỉnh/Thành trước"
                              : "Chọn Quận/Huyện",
                          value: selectedDistrict,
                          items: districts,
                          isLoading: isDistrictsLoading,
                          onChanged: (district) {
                            setState(() {
                              selectedDistrict = district;
                              selectedWard = null;
                              wards = [];
                            });
                            if (district != null) fetchWards(district.code);
                          },
                          validator: (value) =>
                              (deliveryMethod == 0 && value == null)
                              ? 'Vui lòng chọn Quận/Huyện'
                              : null,
                          getItemName: (district) => district.name,
                        ),
                        SizedBox(height: 16),
                        Appwidget.buildDynamicDropdown<Ward>(
                          hint: selectedDistrict == null
                              ? "Vui lòng chọn Quận/Huyện trước"
                              : "Chọn Phường/Xã",
                          value: selectedWard,
                          items: wards,
                          isLoading: isWardsLoading,
                          onChanged: (ward) =>
                              setState(() => selectedWard = ward),
                          validator: (value) =>
                              (deliveryMethod == 0 && value == null)
                              ? 'Vui lòng chọn Phường/Xã'
                              : null,
                          getItemName: (ward) => ward.name,
                        ),
                        SizedBox(height: 16),
                        Appwidget.buildTextFormField(
                          controller: addressLineController,
                          label: "Số nhà, tên đường",
                          hint: "Ví dụ: 123 Nguyễn Huệ",
                          validator: (value) {
                            if (deliveryMethod == 0 &&
                                (value == null || value.isEmpty)) {
                              return 'Vui lòng nhập số nhà, tên đường';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                // --- THÊM MỚI: Checkbox Người khác nhận hàng ---
                SizedBox(height: 10),
                if (deliveryMethod == 0)
                  CheckboxListTile(
                    title: Text(
                      "Người khác nhận hàng",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: isDifferentReceiver,
                    onChanged: (bool? value) {
                      setState(() {
                        isDifferentReceiver = value ?? false;
                        // Nếu bỏ check thì có thể reset các trường người nhận
                        if (!isDifferentReceiver) {
                          receiverNameController.clear();
                          receiverPhoneController.clear();
                        }
                      });
                    },
                    activeColor: Color(0xFFfd6f3e),
                    controlAffinity: ListTileControlAffinity.leading,
                    // checkbox bên trái
                    contentPadding: EdgeInsets.zero,
                  ),

                // --- ẨN/HIỆN FORM NGƯỜI NHẬN ---
                if (isDifferentReceiver)
                  Appwidget.buildFormSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Thông tin người nhận",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        Appwidget.buildTextFormField(
                          controller: receiverNameController,
                          label: "Họ tên người nhận",
                          hint: "Nhập họ tên đầy đủ",
                          validator: (value) {
                            if (isDifferentReceiver &&
                                (value == null || value.isEmpty)) {
                              return 'Vui lòng nhập họ tên người nhận';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        Appwidget.buildTextFormField(
                          controller: receiverPhoneController,
                          label: "Số điện thoại người nhận",
                          hint: "Nhập số điện thoại",
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (isDifferentReceiver &&
                                (value == null || value.isEmpty)) {
                              return 'Vui lòng nhập SĐT người nhận';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                // ------------------------------------
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFfd6f3e),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3, // Thêm bóng đổ
                    ),
                    child: isloading ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white),): Text(
                      "XÁC NHẬN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20), // Thêm khoảng trống ở dưới
              ],
            ),
          ),
        ),
      ),
    );
  }
}
