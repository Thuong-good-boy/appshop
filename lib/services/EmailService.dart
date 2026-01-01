import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static const String _username = '22T1020756@husc.edu.vn';
  static const String _password = 'bxkvwtkyqefrfuuh';

  // --- HÀM GỐC: GỬI MAIL CƠ BẢN ---
  static Future<bool> sendEmail({
    required String toEmail,
    required String subject,
    required String messageBody,
  }) async {
    final smtpServer = gmail(_username, _password);

    final message = Message()
      ..from = Address(_username, 'ShopNew Support') // Tên hiển thị
      ..recipients.add(toEmail)
      ..subject = subject
      ..html = messageBody; // Dùng HTML để format đẹp hơn text thường

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      return true;
    } catch (e) {
      print('Lỗi gửi mail: $e');
      return false;
    }
  }

  // --- MẪU 1: GỬI KHI ĐĂNG KÝ THÀNH CÔNG ---
  static Future<void> sendRegistrationSuccess(String userEmail, String userName) async {
    String subject = "Chào mừng đến với ShopNew!";
    String content = '''
      <h1>Xin chào $userName! 🎉</h1>
      <p>Chúc mừng bạn đã đăng ký tài khoản thành công tại <b>ShopNew</b>.</p>
      <p>Hãy bắt đầu khám phá các sản phẩm công nghệ tuyệt vời ngay hôm nay.</p>
      <hr>
      <p>Trân trọng,<br>Đội ngũ ShopNew</p>
    ''';

    await sendEmail(toEmail: userEmail, subject: subject, messageBody: content);
  }

  // --- MẪU 2: GỬI KHI MUA HÀNG THÀNH CÔNG ---
  static Future<void> sendOrderConfirmation({
    required String userEmail,
    required String userName,
    required String productName,
    required String price,
    required String orderId, // Có thể dùng DateTime.now().toString() làm ID tạm
  }) async {
    String subject = "Xác nhận đơn hàng #$orderId";
    String content = '''
      <h2>Cảm ơn bạn đã mua hàng, $userName! 🛍️</h2>
      <p>Đơn hàng của bạn đã được thanh toán thành công.</p>
      
      <table border="1" cellpadding="10" cellspacing="0" style="border-collapse: collapse;">
        <tr>
          <td bgcolor="#f2f2f2"><b>Sản phẩm</b></td>
          <td>$productName</td>
        </tr>
        <tr>
          <td bgcolor="#f2f2f2"><b>Giá tiền</b></td>
          <td style="color: red; font-weight: bold;">$price</td>
        </tr>
         <tr>
          <td bgcolor="#f2f2f2"><b>Thời gian</b></td>
          <td>${DateTime.now().toString().substring(0, 16)}</td>
        </tr>
      </table>
      
      <p>Chúng tôi sẽ sớm giao hàng cho bạn.</p>
      <hr>
      <p>Cần hỗ trợ? Liên hệ lại email này.</p>
    ''';

    await sendEmail(toEmail: userEmail, subject: subject, messageBody: content);
  }
}