import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // LƯU Ý QUAN TRỌNG VỀ URL:
  // - Nếu chạy trên Android Emulator: dùng 'http://10.0.2.2:8080/api/v1/auth'
  // - Nếu chạy trên máy thật: Dùng địa chỉ IP LAN (VD: 'http://192.168.1.5:8080/api/v1/auth')
  // - Nếu dùng Cloudflare/Domain thực tế: Dùng 'https://api.buivietquangvinh.xyz/api/v1/auth'
  //static const String baseUrl = "https://api.buivietquangvinh.xyz/api/v1/auth";
  static const String baseUrl = "http://192.168.1.23:8080/api/v1/auth";
  // Header giả lập trình duyệt để tránh bị Cloudflare chặn
  static final Map<String, String> headers = {
    "Content-Type": "application/json",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  };

  // 1. Hàm Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Xử lý kết quả trả về
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'data': responseData};
      } else {
        // Cố gắng đọc thông báo lỗi từ server (nếu có)
        String msg = 'Đăng nhập thất bại';
        try {
          final body = jsonDecode(response.body);
          msg = body['message'] ?? body.toString();
        } catch (_) {
          msg = response.body; // Nếu server trả text thuần
        }
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // 2. Hàm Đăng ký
  Future<Map<String, dynamic>> register(String name, String email,String phone, String password) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'fullName': name, // Khớp với Backend Java: private String fullName;
          'email': email,
          'password': password,
          'phoneNumber': phone,
          'role': 'USER'
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend của bạn trả về chuỗi text "Đăng kí thành công!" hoặc JSON
        // Ta cần xử lý linh hoạt cả 2 trường hợp
        try {
          final data = jsonDecode(response.body);
          return {'success': true, 'data': data};
        } catch (_) {
          // Nếu backend trả text thuần (String)
          return {'success': true, 'message': response.body};
        }
      } else {
        String msg = 'Đăng ký thất bại';
        try {
          final body = jsonDecode(response.body);
          msg = body['message'] ?? body.toString();
        } catch (_) {
          msg = response.body;
        }
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
  //Hàm đăng nhập bằng gg ,fb
  Future<Map<String, dynamic>> loginSocial(String token, String provider) async {
    final url = Uri.parse('$baseUrl/social-login');

    try {
      final response = await http.post(
        url,
        headers: headers, // headers đã khai báo ở trên
        body: jsonEncode({
          'token': token,       // ID Token (Google) hoặc Access Token (FB)
          'provider': provider  // "GOOGLE" hoặc "FACEBOOK"
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}