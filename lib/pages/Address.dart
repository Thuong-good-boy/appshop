import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shopnew/services/database.dart';
import 'package:shopnew/services/share_pref.dart';
import 'package:shopnew/services/theme_provider.dart';

// --- MODELS (Giữ nguyên) ---
class Province {
  final int code;
  final String name;
  Province({required this.code, required this.name});
  factory Province.fromJson(Map<String, dynamic> json) => Province(code: json['code'], name: json['name']);
}

class District {
  final int code;
  final String name;
  District({required this.code, required this.name});
  factory District.fromJson(Map<String, dynamic> json) => District(code: json['code'], name: json['name']);
}

class Ward {
  final int code;
  final String name;
  Ward({required this.code, required this.name});
  factory Ward.fromJson(Map<String, dynamic> json) => Ward(code: json['code'], name: json['name']);
}
// ---------------------------------------------

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  String? email;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressLineController = TextEditingController();
  final receiverNameController = TextEditingController();
  final receiverPhoneController = TextEditingController();

  // State UI
  String gioitinh = "Anh";
  int deliveryMethod = 0;
  bool isDifferentReceiver = false;
  bool isloading = false;

  // Data Location
  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];
  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  bool isProvincesLoading = false;
  bool isDistrictsLoading = false;
  bool isWardsLoading = false;

  @override
  void initState() {
    super.initState();
    getontheload();
    fetchProvinces();
  }

  getontheload() async {
    email = await Share_pref().getUserEmail();
    setState(() {});
  }

  // --- API CALLS (Giữ nguyên) ---
  Future<void> fetchProvinces() async {
    setState(() => isProvincesLoading = true);
    try {
      final response = await http.get(Uri.parse('https://provinces.open-api.vn/api/p/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          provinces = data.map((json) => Province.fromJson(json)).toList();
        });
      }
    } catch (e) { print("Lỗi: $e"); }
    finally { if (mounted) setState(() => isProvincesLoading = false); }
  }

  Future<void> fetchDistricts(int provinceCode) async {
    setState(() => isDistrictsLoading = true);
    try {
      final response = await http.get(Uri.parse('https://provinces.open-api.vn/api/p/$provinceCode?depth=2'));
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          districts = (data['districts'] as List).map((json) => District.fromJson(json)).toList();
        });
      }
    } catch (e) { print("Lỗi: $e"); }
    finally { if (mounted) setState(() => isDistrictsLoading = false); }
  }

  Future<void> fetchWards(int districtCode) async {
    setState(() => isWardsLoading = true);
    try {
      final response = await http.get(Uri.parse('https://provinces.open-api.vn/api/d/$districtCode?depth=2'));
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          wards = (data['wards'] as List).map((json) => Ward.fromJson(json)).toList();
        });
      }
    } catch (e) { print("Lỗi: $e"); }
    finally { if (mounted) setState(() => isWardsLoading = false); }
  }

  @override
  void dispose() {
    nameController.dispose(); phoneController.dispose();
    addressLineController.dispose(); receiverNameController.dispose();
    receiverPhoneController.dispose();
    super.dispose();
  }

  void submitAddress() async {
    setState(() => isloading = true);
    try {
      if (_formKey.currentState!.validate()) {
        if (email == null) return;

        Map<String, String> addressInfoMap = {
          'Email': email!,
          'Gioitinh': gioitinh,
          'Name': nameController.text,
          'Phone': phoneController.text,
          'Delivery': deliveryMethod == 0 ? "Giao tận nơi" : "Nhận tại siêu thị",
          'Is_different_receiver': isDifferentReceiver.toString(),
          'Receiver_name': isDifferentReceiver ? receiverNameController.text : nameController.text,
          'Receiver_phone': isDifferentReceiver ? receiverPhoneController.text : phoneController.text,
        };

        if (deliveryMethod == 0) {
          addressInfoMap.addAll({
            'Line': addressLineController.text,
            'Ward': selectedWard!.name,
            'District': selectedDistrict!.name,
            'City': selectedProvince!.name,
            'State': selectedProvince!.name,
            'Country': 'VN',
          });
        }
        await DatabaseMethods().Address(addressInfoMap);
        Navigator.pop(context);
      }
    } catch (e) { print(e); }
    finally { setState(() => isloading = false); }
  }

  @override
  Widget build(BuildContext context) {
    // --- CẤU HÌNH THEME ---
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    // Màu sắc
    Color bgColor = isDark ? Color(0xFF121212) : Color(0xfff2f2f2);
    Color cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    TextStyle headerStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Thông tin giao hàng", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new, color: textColor),
        ),
        backgroundColor: bgColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- PHẦN 1: NGƯỜI ĐẶT ---
              _buildSectionContainer(
                isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Thông tin người đặt", style: headerStyle),
                    SizedBox(height: 10),
                    // Radio Giới tính
                    Row(
                      children: [
                        _buildRadio(context, "Anh", "Anh", isDark),
                        _buildRadio(context, "Chị", "Nữ", isDark),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Input Fields mới đẹp hơn
                    _buildStylishTextField(
                      controller: nameController,
                      label: "Họ và tên",
                      hint: "Nhập họ tên đầy đủ",
                      isDark: isDark,
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Vui lòng nhập họ tên' : null,
                    ),
                    SizedBox(height: 15),
                    _buildStylishTextField(
                      controller: phoneController,
                      label: "Số điện thoại",
                      hint: "Nhập số điện thoại",
                      isDark: isDark,
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.length < 10 ? 'SĐT không hợp lệ' : null,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Text("Hình thức giao hàng", style: headerStyle),
              SizedBox(height: 10),

              // Toggle Button
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? Border.all(color: Colors.white10) : null,
                ),
                child: ToggleButtons(
                  isSelected: [deliveryMethod == 0, deliveryMethod == 1],
                  onPressed: (int index) {
                    setState(() {
                      deliveryMethod = index;
                      if (index == 1) _formKey.currentState?.validate();
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  renderBorder: false,
                  selectedColor: Colors.white,
                  fillColor: Color(0xFFfd6f3e),
                  color: subTextColor,
                  constraints: BoxConstraints(
                    minHeight: 50.0,
                    minWidth: (MediaQuery.of(context).size.width - 40) / 2,
                  ),
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.local_shipping_outlined, size: 20), SizedBox(width: 8), Text('Giao tận nơi')]),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.store_outlined, size: 20), SizedBox(width: 8), Text('Tại siêu thị')]),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // --- PHẦN 2: ĐỊA CHỈ (Chỉ hiện khi Giao tận nơi) ---
              if (deliveryMethod == 0)
                _buildSectionContainer(
                  isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Địa chỉ nhận hàng", style: headerStyle),
                      SizedBox(height: 15),

                      _buildStylishDropdown<Province>(
                        hint: "Chọn Tỉnh/Thành phố",
                        value: selectedProvince,
                        items: provinces,
                        isDark: isDark,
                        isLoading: isProvincesLoading,
                        onChanged: (val) {
                          setState(() { selectedProvince = val; selectedDistrict = null; selectedWard = null; districts = []; wards = []; });
                          if (val != null) fetchDistricts(val.code);
                        },
                        itemLabel: (p) => p.name,
                        validator: (v) => v == null ? 'Chọn Tỉnh/Thành' : null,
                      ),
                      SizedBox(height: 15),

                      _buildStylishDropdown<District>(
                        hint: "Chọn Quận/Huyện",
                        value: selectedDistrict,
                        items: districts,
                        isDark: isDark,
                        isLoading: isDistrictsLoading,
                        onChanged: (val) {
                          setState(() { selectedDistrict = val; selectedWard = null; wards = []; });
                          if (val != null) fetchWards(val.code);
                        },
                        itemLabel: (d) => d.name,
                        validator: (v) => v == null ? 'Chọn Quận/Huyện' : null,
                      ),
                      SizedBox(height: 15),

                      _buildStylishDropdown<Ward>(
                        hint: "Chọn Phường/Xã",
                        value: selectedWard,
                        items: wards,
                        isDark: isDark,
                        isLoading: isWardsLoading,
                        onChanged: (val) => setState(() => selectedWard = val),
                        itemLabel: (w) => w.name,
                        validator: (v) => v == null ? 'Chọn Phường/Xã' : null,
                      ),
                      SizedBox(height: 15),

                      _buildStylishTextField(
                        controller: addressLineController,
                        label: "Số nhà, tên đường",
                        hint: "VD: 123 Nguyễn Huệ",
                        isDark: isDark,
                        icon: Icons.home_outlined,
                        validator: (v) => v!.isEmpty ? 'Nhập địa chỉ cụ thể' : null,
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 10),

              // Checkbox Người khác nhận
              if (deliveryMethod == 0)
                Theme(
                  data: Theme.of(context).copyWith(unselectedWidgetColor: subTextColor),
                  child: CheckboxListTile(
                    title: Text("Người khác nhận hàng", style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                    value: isDifferentReceiver,
                    onChanged: (val) => setState(() {
                      isDifferentReceiver = val ?? false;
                      if (!val!) { receiverNameController.clear(); receiverPhoneController.clear(); }
                    }),
                    activeColor: Color(0xFFfd6f3e),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),

              if (isDifferentReceiver)
                _buildSectionContainer(
                  isDark,
                  child: Column(
                    children: [
                      _buildStylishTextField(
                        controller: receiverNameController,
                        label: "Tên người nhận",
                        hint: "Nhập tên người nhận",
                        isDark: isDark,
                        icon: Icons.person_add_outlined,
                        validator: (v) => isDifferentReceiver && v!.isEmpty ? 'Nhập tên' : null,
                      ),
                      SizedBox(height: 15),
                      _buildStylishTextField(
                        controller: receiverPhoneController,
                        label: "SĐT người nhận",
                        hint: "Nhập số điện thoại",
                        isDark: isDark,
                        icon: Icons.phone_forwarded_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => isDifferentReceiver && v!.isEmpty ? 'Nhập SĐT' : null,
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 30),

              // Button Xác nhận
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isloading ? null : submitAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFfd6f3e),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: Color(0xFFfd6f3e).withOpacity(0.5),
                  ),
                  child: isloading
                      ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Text("XÁC NHẬN", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS LÀM ĐẸP (CUSTOM UI) ---

  // 1. Ô Nhập liệu (TextField) xịn xò
  Widget _buildStylishTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    Color fillColor = isDark ? Color(0xFF2C2C2C) : Colors.grey[100]!;
    Color hintColor = isDark ? Colors.grey[500]! : Colors.grey[500]!;
    Color labelColor = isDark ? Colors.white70 : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 14, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: isDark ? Colors.grey : Colors.grey[600]) : null,
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontSize: 14),
            filled: true,
            fillColor: fillColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFfd6f3e), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  // 2. Dropdown xịn xò
  Widget _buildStylishDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required bool isDark,
    required bool isLoading,
    required Function(T?) onChanged,
    required String Function(T) itemLabel,
    String? Function(T?)? validator,
  }) {
    Color fillColor = isDark ? Color(0xFF2C2C2C) : Colors.grey[100]!;
    Color textColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFfd6f3e), width: 1.5),
            ),
          ),
          dropdownColor: isDark ? Color(0xFF2C2C2C) : Colors.white,
          icon: isLoading
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white70 : Colors.black54),
          hint: Text(hint, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 14)),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item), style: TextStyle(color: textColor, overflow: TextOverflow.ellipsis)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  // 3. Khung chứa (Card)
  Widget _buildSectionContainer(bool isDark, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  // 4. Radio Button tùy chỉnh
  Widget _buildRadio(BuildContext context, String title, String val, bool isDark) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        value: val,
        groupValue: gioitinh,
        onChanged: (value) => setState(() => gioitinh = value!),
        activeColor: Color(0xFFfd6f3e),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}