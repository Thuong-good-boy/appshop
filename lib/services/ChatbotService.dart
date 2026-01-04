import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotService {

  static const String _apiKey = 'AIzaSyAdwX_WJ-6YAVz34H-rVJ72ssi0d_OyOYc';

  late final GenerativeModel _model;
  ChatSession? _chatSession;

  ChatbotService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  // Hàm lấy toàn bộ sản phẩm để "dạy" cho Gemini
  Future<String> _getProductContext() async {
    try {
      // Lấy danh sách sản phẩm từ Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Products').get();

      if (snapshot.docs.isEmpty) return "Hiện tại cửa hàng không có sản phẩm nào.";

      String context = "Dưới đây là danh sách sản phẩm hiện có của cửa hàng:\n";

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Tạo chuỗi mô tả từng sản phẩm
        context += "- Tên: ${data['Name']}\n";
        context += "  Giá: ${data['Price']}\n";
        context += "  Mô tả: ${data['Detail']}\n";
        context += "  ID: ${doc.id}\n"; // Quan trọng: Phải đưa ID cho Gemini biết
        context += "---\n";
      }

      return context;
    } catch (e) {
      print("Lỗi lấy sản phẩm: $e");
      return "";
    }
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      // Nếu là lần đầu chat, cần khởi tạo session và nạp dữ liệu sản phẩm
      if (_chatSession == null) {
        String productData = await _getProductContext();

        // Cấu hình hướng dẫn cho Gemini (System Instruction)
        String systemInstruction = """
        Bạn là nhân viên tư vấn bán hàng nhiệt tình, thân thiện.
        Dưới đây là dữ liệu sản phẩm của cửa hàng:
        $productData
        
        Quy tắc trả lời:
        1. Trả lời ngắn gọn, tập trung vào nhu cầu khách hàng.
        2. Chỉ tư vấn các sản phẩm có trong danh sách trên.
        3. QUAN TRỌNG: Nếu bạn gợi ý một sản phẩm cụ thể cho khách, hãy chèn ID của nó vào cuối câu trả lời theo định dạng chính xác này: [PRODUCT_ID: id_của_sản_phẩm].
        4. Nếu không tìm thấy sản phẩm phù hợp, hãy xin lỗi và gợi ý sản phẩm khác.
        """;

        _chatSession = _model.startChat(history: [
          Content.text(systemInstruction),
        ]);
      }

      // Gửi tin nhắn của khách
      final response = await _chatSession!.sendMessage(Content.text(message));
      final textResponse = response.text ?? "Xin lỗi, tôi đang gặp sự cố.";

      // --- XỬ LÝ PHÂN TÁCH ID SẢN PHẨM ---
      String finalText = textResponse;
      String? productId;

      // Tìm mẫu [PRODUCT_ID: xxx]
      RegExp regExp = RegExp(r'\[PRODUCT_ID:\s*(.*?)\]');
      Match? match = regExp.firstMatch(textResponse);

      if (match != null) {
        productId = match.group(1); // Lấy ID ra
        finalText = textResponse.replaceAll(match.group(0)!, '').trim(); // Xóa mã ID khỏi lời thoại cho đẹp
      }

      // Nếu có ID, ta cần lấy lại thông tin chi tiết (ảnh, tên) để hiển thị UI đẹp
      Map<String, dynamic> result = {
        'text': finalText,
      };

      if (productId != null) {
        // Lấy lại thông tin chi tiết từ Firestore để hiển thị cái thẻ đẹp
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('Products').doc(productId).get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          result['productId'] = productId;
          result['productName'] = data['Name'];
          result['productImage'] = data['Image'];
          result['productPrice'] = data['Price'];
          result['productDetail'] = data['Detail'];
        }
      }

      return result;

    } catch (e) {
      return {'text': "Lỗi kết nối: $e"};
    }
  }
}