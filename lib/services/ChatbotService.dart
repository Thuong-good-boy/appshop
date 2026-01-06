import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

import 'package:shopnew/services/constant.dart';

class ChatbotService {
  static String _apiKey = apiKey;

  late final GenerativeModel _model;
  ChatSession? _chatSession;

  ChatbotService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> _getProductContext() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Products').get();

      if (snapshot.docs.isEmpty) return "Hiện tại cửa hàng không có sản phẩm nào.";

      String context = "Dưới đây là danh sách sản phẩm hiện có của cửa hàng:\n";

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        context += "- Tên: ${data['Name']}\n";
        context += "  Giá: ${data['Price']}\n";
        context += "  Mô tả: ${data['Detail']}\n";
        context += "  ID: ${doc.id}\n";
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
      if (_chatSession == null) {
        String productData = await _getProductContext();

        String systemInstruction = """
        Bạn là nhân viên tư vấn bán hàng nhiệt tình, thân thiện của ShopNew.
        Dưới đây là dữ liệu sản phẩm của cửa hàng:
        $productData
        
        Quy tắc trả lời:
        1. Trả lời ngắn gọn, tập trung vào nhu cầu khách hàng.
        2. Chỉ tư vấn các sản phẩm có trong danh sách trên.
        3. QUAN TRỌNG: Nếu bạn gợi ý các sản phẩm cho khách, hãy chèn ID của chúng vào cuối câu trả lời. 
           Nếu có nhiều sản phẩm phù hợp, hãy liệt kê tất cả ID theo định dạng: [PRODUCT_ID: id1] [PRODUCT_ID: id2] [PRODUCT_ID: id3].
        4. Nếu không tìm thấy sản phẩm phù hợp, hãy xin lỗi và gợi ý sản phẩm gần giống nhất.
        """;

        _chatSession = _model.startChat(history: [
          Content.text(systemInstruction),
        ]);
      }

        final response = await _chatSession!.sendMessage(Content.text(message));
        final textResponse = response.text ?? "Xin lỗi, tôi đang gặp sự cố.";

        String finalText = textResponse;
        List<Map<String, dynamic>> productsList = [];

        // lấy id
        RegExp regExp = RegExp(r'\[PRODUCT_ID:\s*([^\]]+)\]');
        Iterable<RegExpMatch> matches = regExp.allMatches(textResponse);

        for (var match in matches) {
          String pId = match.group(1)!.trim();

          finalText = finalText.replaceAll(match.group(0)!, '').trim();

          DocumentSnapshot doc = await FirebaseFirestore.instance.collection('Products').doc(pId).get();
          if (doc.exists) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            productsList.add({
              'productId': pId,
              'productName': data['Name'],
              'productImage': data['Image'],
              'productPrice': data['Price'],
              'productDetail': data['Detail'],
            });
          }
        }

        return {
          'text': finalText,
          'products': productsList,
        };

    } catch (e) {
      return {'text': "Lỗi kết nối: $e", 'products': []};
    }
  }
}