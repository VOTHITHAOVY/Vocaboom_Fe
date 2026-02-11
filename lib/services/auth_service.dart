import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  // Domain API
  static const String baseUrl = "https://api.buivietquangvinh.xyz/api/v1/auth";

  // 👇 HÀM TẠO HEADER THÔNG MINH
  Map<String, String> getHeaders() {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "*/*",
    };

    // Giả danh trình duyệt để qua mặt Cloudflare trên Mobile
    if (!kIsWeb) {
      headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";
    }

    return headers;
  }

  // 1. Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    print("🚀 Login: $url");

    try {
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      return _processResponse(response);
    } catch (e) {
      print("❌ Lỗi login: $e");
      return {'success': false, 'message': 'Lỗi kết nối mạng: $e'};
    }
  }

  // 2. Đăng ký
  Future<Map<String, dynamic>> register(String name, String email, String phone, String password) async {
    final url = Uri.parse('$baseUrl/register');
    print("🚀 Register: $url");

    try {
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode({
          'fullName': name,
          'email': email,
          'password': password,
          'phoneNumber': phone,
          'role': 'USER'
        }),
      );
      return _processResponse(response);
    } catch (e) {
      print("❌ Lỗi register: $e");
      return {'success': false, 'message': 'Lỗi kết nối mạng: $e'};
    }
  }

  // 3. Login Social
  Future<Map<String, dynamic>> loginSocial(String token, String provider) async {
    final url = Uri.parse('$baseUrl/social-login');
    try {
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode({
          'token': token,
          'provider': provider
        }),
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // 🔥 HÀM XỬ LÝ KẾT QUẢ (ĐÃ SỬA LỖI FONT VÀ CRASH)
  Map<String, dynamic> _processResponse(http.Response response) {
    print("📩 Code: ${response.statusCode}");

    // 1. GIẢI MÃ UTF-8 AN TOÀN (FIX LỖI CRASH VÀ LỖI FONT)
    // allowMalformed: true giúp bỏ qua các ký tự lỗi thay vì làm sập app
    String responseBody = "";
    try {
      responseBody = utf8.decode(response.bodyBytes, allowMalformed: true);
    } catch (e) {
      responseBody = response.body; // Fallback nếu decode thất bại
    }

    // Uncomment dòng dưới để xem server thực sự trả về gì
    // print("📩 Raw Body: $responseBody");

    // 2. XỬ LÝ THÀNH CÔNG (200 - 299)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        // Trường hợp 1: Server trả về JSON (VD: Login thành công)
        final data = jsonDecode(responseBody);
        return {'success': true, 'data': data};
      } catch (e) {
        // Trường hợp 2: Server trả về Text thuần (VD: "Đăng ký thành công!")
        // Ta vẫn coi đây là thành công
        return {'success': true, 'message': responseBody, 'data': {}};
      }
    }

    // 3. XỬ LÝ LỖI (400, 401, 403, 500...)
    else {
      // Check lỗi Cloudflare (Trả về HTML)
      if (responseBody.contains("<!DOCTYPE html>") || responseBody.contains("<html")) {
        return {'success': false, 'message': 'Hệ thống đang bận (Cloudflare Block). Vui lòng thử lại sau.'};
      }

      String errorMsg = 'Thất bại';
      try {
        // Cố gắng đọc lỗi từ JSON server trả về
        final body = jsonDecode(responseBody);
        errorMsg = body['message'] ?? body.toString();
      } catch (_) {
        // Nếu server chỉ trả về text lỗi (VD: "Email đã tồn tại")
        errorMsg = responseBody;
      }

      return {'success': false, 'message': errorMsg};
    }
  }
}