import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class MoMoService {
  // --- THÔNG TIN TEST CHÍNH THỨC TỪ MOMO DEVELOPER ---
  static const String endpoint = "https://test-payment.momo.vn/v2/gateway/api/create";
  static const String partnerCode = "MOMO";
  static const String accessKey = "F8BBA842ECF85";
  static const String secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz";

  static Future<String?> createPaymentUrl(double amount, String orderInfo) async {
    String orderId = "BEAUTYEYES_${DateTime.now().millisecondsSinceEpoch}";
    String requestId = orderId;
    String redirectUrl = "https://momo.vn"; // URL MoMo sẽ trả về sau khi khách thanh toán xong
    String ipnUrl = "https://momo.vn";
    String requestType = "captureWallet";
    String extraData = "";
    String amountStr = amount.toInt().toString();

    // 1. Tạo chuỗi ký tự thô (Chữ ký)
    String rawSignature = "accessKey=$accessKey&amount=$amountStr&extraData=$extraData&ipnUrl=$ipnUrl&orderId=$orderId&orderInfo=$orderInfo&partnerCode=$partnerCode&redirectUrl=$redirectUrl&requestId=$requestId&requestType=$requestType";

    // 2. Mã hóa HMAC-SHA256
    var bytes = utf8.encode(rawSignature);
    var key = utf8.encode(secretKey);
    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes);
    String signature = digest.toString();

    // 3. Đóng gói dữ liệu
    Map<String, dynamic> body = {
      "partnerCode": partnerCode,
      "partnerName": "BeautyEyes",
      "storeId": "BeautyEyes",
      "requestId": requestId,
      "amount": amount.toInt(),
      "orderId": orderId,
      "orderInfo": orderInfo,
      "redirectUrl": redirectUrl,
      "ipnUrl": ipnUrl,
      "lang": "vi",
      "extraData": extraData,
      "requestType": requestType,
      "signature": signature
    };

    // 4. Gửi Request lên MoMo
    try {
      print("🚀 ĐANG GỬI MOMO SỐ TIỀN: $amountStr VND"); // Log kiểm tra số tiền

      var response = await http.post(
          Uri.parse(endpoint),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: jsonEncode(body)
      );

      // IN TOÀN BỘ PHẢN HỒI TỪ MOMO RA CONSOLE
      print("📦 PHẢN HỒI RAW TỪ MOMO: ${response.body}");

      var data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['resultCode'] == 0) {
        return data['payUrl'];
      } else {
        print("❌ MOMO TỪ CHỐI: ${data['message']} - Code: ${data['resultCode']}");
        return null;
      }
    } catch (e) {
      print("💥 LỖI MẠNG / CRASH: $e");
      return null;
    }
  }
}