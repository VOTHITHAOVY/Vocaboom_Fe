import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import để dùng InputFormatter
import 'package:google_sign_in/google_sign_in.dart';


import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../services/auth_service.dart'; // Đảm bảo đường dẫn đúng
import 'main_screen.dart';

// ==========================================
// MÀN HÌNH ĐĂNG NHẬP (LOGIN SCREEN)
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 1. CẤU HÌNH GOOGLE SIGN IN
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );


  // 2. HÀM XỬ LÝ LOGIN GOOGLE
  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false); // Người dùng hủy
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        final authService = AuthService();
        final result = await authService.loginSocial(idToken, "GOOGLE");

        if (mounted) {
          setState(() => _isLoading = false);
          if (result['success']) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(userData: result['data'])),
                  (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi Backend: ${result['message']}")));
          }
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi Google: $error")));
      }
    }
  }

  // 3. HÀM XỬ LÝ LOGIN FACEBOOK
  void _handleFacebookLogin() async {
    setState(() => _isLoading = true);
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final authService = AuthService();
        // ĐÚNG (Ở bản mới):
        final backendResult = await authService.loginSocial(accessToken.tokenString, "FACEBOOK");

        if (mounted) {
          setState(() => _isLoading = false);
          if (backendResult['success']) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(userData: backendResult['data'])),
                  (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(backendResult['message'])));
          }
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi Facebook: $e")));
      }
    }
  }

  // 4. HÀM XỬ LÝ LOGIN THƯỜNG
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = AuthService();
      final result = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập thành công!'), backgroundColor: Colors.green),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(userData: result['data'])),
                (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: const Icon(Icons.school, size: 50, color: Colors.purple),
                    ),
                    const SizedBox(height: 20),
                    const Text('AI Tutor', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Học tiếng Anh thông minh', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),

              // Form Đăng nhập
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Đăng nhập', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Text('Chào mừng bạn quay trở lại!', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      const SizedBox(height: 32),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.purple),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                          if (!value.contains('@')) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.purple),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                          if (value.length < 6) return 'Mật khẩu quá ngắn';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Quên mật khẩu?', style: TextStyle(color: Colors.purple)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Đăng nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider & Social Login
                      Row(children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Hoặc đăng nhập bằng', style: TextStyle(color: Colors.grey[600]))),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ]),
                      const SizedBox(height: 24),

                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleGoogleLogin,
                            icon: const Icon(Icons.g_mobiledata, size: 32),
                            label: const Text('Google'),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleFacebookLogin,
                            icon: const Icon(Icons.facebook, color: Colors.blue),
                            label: const Text('Facebook'),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 24),

                      // Link to Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Chưa có tài khoản? ', style: TextStyle(color: Colors.grey[600])),
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                            child: const Text('Đăng ký ngay', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH ĐĂNG KÝ (REGISTER SCREEN)
// ==========================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- HÀM XỬ LÝ ĐĂNG KÝ ---
  void _handleRegister() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý với điều khoản sử dụng'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = AuthService();
      // Gọi API với 4 tham số: Tên, Email, SĐT, Pass
      final result = await authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Quay về màn hình đăng nhập
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // --- CÁC HÀM VALIDATE CHẶT CHẼ ---

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ và tên';
    // Chỉ cho phép chữ và khoảng trắng (hỗ trợ Tiếng Việt)
    if (!RegExp(r"^[\p{L} .'-]+$", unicode: true).hasMatch(value)) {
      return 'Tên không được chứa ký tự đặc biệt hoặc số';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Email không hợp lệ';
    if (value.contains("'") || value.contains(";") || value.contains("--")) {
      return 'Email chứa ký tự không an toàn';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Số điện thoại chỉ được chứa số';
    if (value.length < 9 || value.length > 11) return 'Số điện thoại phải từ 9-11 số';
    if (!value.startsWith('0')) return 'Số điện thoại phải bắt đầu bằng số 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tạo tài khoản', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text('Bắt đầu hành trình học tập của bạn', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 32),

                  // 1. INPUT HỌ TÊN
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.purple),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\u00C0-\u1EF9]"))],
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),

                  // 2. INPUT EMAIL
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.purple),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // 3. INPUT SỐ ĐIỆN THOẠI
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: const Icon(Icons.phone_outlined, color: Colors.purple),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 16),

                  // 4. INPUT MẬT KHẨU
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.purple),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                      if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                      if (value.contains("'") || value.contains("--")) return 'Mật khẩu chứa ký tự không an toàn';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 5. INPUT XÁC NHẬN MẬT KHẨU
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.purple),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                      if (value != _passwordController.text) return 'Mật khẩu không khớp';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Terms Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                        activeColor: Colors.purple,
                      ),
                      const Expanded(child: Text('Tôi đồng ý với Điều khoản sử dụng')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Nút Đăng ký
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  // Link về Login
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Đã có tài khoản? ', style: TextStyle(color: Colors.grey[600])),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đăng nhập', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}