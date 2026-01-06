import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopnew/pages/ProductDeTail.dart';
import 'package:shopnew/services/ChatbotService.dart';
import 'package:shopnew/services/theme_provider.dart';

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
          duration: const Duration(milliseconds: 300),
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

    try {
      Map<String, dynamic> botResponse = await _chatbotService.sendMessage(text);

      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': botResponse['text'],
          'products': botResponse['products'],
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

  Widget _buildProductCard(Map<String, dynamic> product, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product['productImage'] ?? '',
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100, color: Colors.grey[800], child: const Icon(Icons.image_not_supported, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product['productName'] ?? 'Sản phẩm',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            product['productPrice'] ?? '',
            style: const TextStyle(color: Color(0xFFfd6f3e), fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDeTail(
                  id: product['productId'],
                  name: product['productName'],
                  image: product['productImage'],
                  detail: product['productDetail'] ,
                  price: product['productPrice'],
                )));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFfd6f3e),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Xem ngay", style: TextStyle(fontSize: 11)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color inputColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color hintColor = isDark ? Colors.white54 : Colors.grey.shade400;
    final Color textFieldFill = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_outlined, size: 24, color: Color(0xFFfd6f3e)),
            const SizedBox(width: 8),
            Text("Trợ lý ảo AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
          ],
        ),
        backgroundColor: bgColor,
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
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message['sender'] == 'user';
                List<dynamic> products = message['products'] ?? [];

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                              color: isUser ? const Color(0xFFfd6f3e) : cardColor,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(15),
                                topRight: const Radius.circular(15),
                                bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
                                bottomRight: isUser ? Radius.zero : const Radius.circular(15),
                              ),
                              boxShadow: [
                                if(!isDark) const BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
                              ]
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(color: isUser ? Colors.white : textColor, fontSize: 15),
                          ),
                        ),

                        if (!isUser && products.isNotEmpty)
                          Container(
                            height: 220,
                            margin: const EdgeInsets.only(top: 10),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: products.length,
                              itemBuilder: (context, pIndex) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _buildProductCard(products[pIndex], cardColor, textColor),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10),
              child: Row(children: [
                const Text("AI đang nhập...", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 10),
                const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFfd6f3e))),
              ]),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: inputColor,
                boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(0,-1), blurRadius: 3)]
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Hỏi về sản phẩm...",
                      hintStyle: TextStyle(color: hintColor),
                      filled: true,
                      fillColor: textFieldFill,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Color(0xFFfd6f3e), shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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