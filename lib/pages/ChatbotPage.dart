import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:shopnew/pages/ProductDeTail.dart';
import 'package:shopnew/services/ChatbotService.dart';
import 'package:shopnew/services/theme_provider.dart'; // Import ThemeProvider

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ChatbotService _chatbotService = ChatbotService();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'sender': 'bot',
      'text': 'Chào bạn! Mình là trợ lý AI của ShopNew. Mình có thể giúp gì cho bạn hôm nay?'
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String text = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _scrollToBottom();

    // Gọi AI (Giả định ChatbotService trả về đúng định dạng)
    try {
      Map<String, dynamic> botResponse = await _chatbotService.sendMessage(text);

      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': botResponse['text'],
          'productId': botResponse['productId'],
          'productName': botResponse['productName'],
          'productImage': botResponse['productImage'],
          'productPrice': botResponse['productPrice'],
          'productDetail': botResponse['productDetail'],
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': 'Xin lỗi, hiện tại mình đang gặp sự cố kết nối. Bạn thử lại sau nhé!',
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  // Widget hiển thị thẻ sản phẩm (Hỗ trợ Dark Mode)
  Widget _buildProductCard(Map<String, dynamic> message, Color cardColor, Color textColor) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor, // Màu nền thẻ theo theme
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              message['productImage'] ?? '',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120, color: Colors.grey[800], child: Icon(Icons.image_not_supported, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            message['productName'] ?? 'Sản phẩm',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            message['productPrice'] ?? '',
            style: TextStyle(color: Color(0xFFfd6f3e), fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDeTail(
                  id: message['productId'],
                  name: message['productName'],
                  image: message['productImage'],
                  detail: message['productDetail'] ?? "Đang cập nhật",
                  price: message['productPrice'],
                )));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFfd6f3e),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("Xem ngay", style: TextStyle(fontSize: 12)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- Cấu hình Theme ---
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white; // Màu nền item chat bot
    final Color inputColor = isDark ? Color(0xFF1E1E1E) : Colors.white; // Màu nền thanh nhập liệu
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color hintColor = isDark ? Colors.white54 : Colors.grey.shade400;
    final Color textFieldFill = isDark ? Color(0xFF2C2C2C) : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy_outlined, size: 24, color: Color(0xFFfd6f3e)),
            SizedBox(width: 8),
            Text("Trợ lý ảo AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
          ],
        ),
        backgroundColor: bgColor,
        surfaceTintColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: 20, top: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message['sender'] == 'user';
                bool hasProduct = message['productId'] != null;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        // Bong bóng chat
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                              color: isUser ? Color(0xFFfd6f3e) : cardColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: isUser ? Radius.circular(15) : Radius.zero,
                                bottomRight: isUser ? Radius.zero : Radius.circular(15),
                              ),
                              boxShadow: [
                                if(!isDark) // Chỉ đổ bóng ở Light mode cho đẹp
                                  BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
                              ]
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(
                              color: isUser ? Colors.white : textColor,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        // Nếu có sản phẩm đi kèm thì hiển thị card bên dưới
                        if (!isUser && hasProduct) _buildProductCard(message, cardColor, textColor),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Thanh loading
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10),
              child: Row(children: [
                Text("AI đang nhập...", style: TextStyle(color: Colors.grey, fontSize: 12)),
                SizedBox(width: 10),
                SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFfd6f3e))),
              ]),
            ),

          // Khu vực nhập liệu
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: inputColor,
                boxShadow: [
                  BoxShadow(color: Colors.black12, offset: Offset(0,-1), blurRadius: 3)
                ]
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: textColor), // Màu chữ khi gõ
                    decoration: InputDecoration(
                      hintText: "Hỏi về sản phẩm...",
                      hintStyle: TextStyle(color: hintColor),
                      filled: true,
                      fillColor: textFieldFill, // Màu nền ô nhập liệu
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFfd6f3e),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}