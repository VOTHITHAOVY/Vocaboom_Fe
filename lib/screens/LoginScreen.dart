import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../services/auth_service.dart';
import 'main_screen.dart';

// ==========================================
// 1. WIDGET LOGO RIÊNG (DÙNG CHUNG CHO CẢ 2 MÀN)
// ==========================================
class VocaBoomLogo extends StatelessWidget {
  final double size;
  const VocaBoomLogo({Key? key, this.size = 140}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10), // Viền trắng xung quanh
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        // 👇 QUAN TRỌNG: Lấy đúng ảnh từ assets/images/logo.png
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover, // Đảm bảo ảnh lấp đầy khung tròn
          errorBuilder: (context, error, stackTrace) {
            // Fallback: Nếu quên thêm ảnh vào pubspec.yaml thì hiện icon này
            return Container(
              color: Colors.orange.shade100,
              child: const Icon(Icons.rocket_launch_rounded, size: 50, color: Colors.deepOrange),
            );
          },
        ),
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH ĐĂNG NHẬP
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

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIC GIỮ NGUYÊN NHƯ CŨ (VÌ ĐÃ ĐÚNG) ---
  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.idToken != null) {
        _callAuthService(googleAuth.idToken!, "GOOGLE");
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi Google: $error")));
      }
    }
  }

  void _handleFacebookLogin() async {
    setState(() => _isLoading = true);
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        _callAuthService(result.accessToken!.tokenString, "FACEBOOK");
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

  void _callAuthService(String token, String provider) async {
    final authService = AuthService();
    final result = await authService.loginSocial(token, provider);
    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen(userData: result['data'])), (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authService = AuthService();
      final result = await authService.login(_emailController.text.trim(), _passwordController.text);
      setState(() => _isLoading = false);

      if (mounted) {
        if (result['success']) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen(userData: result['data'])), (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // 👇 SỬ DỤNG LOGO TÙY CHỈNH Ở ĐÂY
                  const VocaBoomLogo(size: 140),
                  const SizedBox(height: 20),
                  const Text('VocaBoom', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Text('✨ Học tiếng Anh siêu vui ✨', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),

            // FORM
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Đăng nhập', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 32),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6C63FF)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => (value == null || !value.contains('@')) ? 'Email không hợp lệ' : null,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6C63FF)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => (value == null || value.length < 6) ? 'Mật khẩu quá ngắn' : null,
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFFD93D)]),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: const Color(0xFFFF6B6B).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Đăng nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Social Login
                    Row(
                      children: [
                        Expanded(child: OutlinedButton.icon(onPressed: _handleGoogleLogin, icon: const Icon(Icons.g_mobiledata, size: 32), label: const Text('Google'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)))),
                        const SizedBox(width: 12),
                        Expanded(child: OutlinedButton.icon(onPressed: _handleFacebookLogin, icon: const Icon(Icons.facebook, color: Colors.blue), label: const Text('Facebook'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)))),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Chưa có tài khoản? ', style: TextStyle(color: Colors.grey[600])),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                          child: const Text('Đăng ký ngay', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
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
    );
  }
}

// ==========================================
// MÀN HÌNH ĐĂNG KÝ
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

  void _handleRegister() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đồng ý với điều khoản sử dụng'), backgroundColor: Colors.orange));
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authService = AuthService();
      final result = await authService.register(_nameController.text.trim(), _emailController.text.trim(), _phoneController.text.trim(), _passwordController.text);
      setState(() => _isLoading = false);
      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập.'), backgroundColor: Colors.green));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
        }
      }
    }
  }

  // --- VALIDATORS ---
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ và tên';
    if (!RegExp(r"^[\p{L} .'-]+$", unicode: true).hasMatch(value)) return 'Tên không hợp lệ';
    return null;
  }

  // (Giữ các validator Email, Phone như cũ...)
  String? _validateEmail(String? val) => (val == null || !val.contains('@')) ? 'Email không hợp lệ' : null;
  String? _validatePhone(String? val) => (val == null || val.length < 9) ? 'SĐT không hợp lệ' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Align(alignment: Alignment.centerLeft, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
                    // 👇 SỬ DỤNG LOGO TÙY CHỈNH (NHỎ HƠN XÍU)
                    const VocaBoomLogo(size: 100),
                    const SizedBox(height: 15),
                    const Text('Tạo tài khoản', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // FORM REGISTER
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name
                      TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Họ và tên', prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6C63FF)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: _validateName, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\u00C0-\u1EF9]"))]),
                      const SizedBox(height: 16),
                      // Email
                      TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6C63FF)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: _validateEmail),
                      const SizedBox(height: 16),
                      // Phone
                      TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'Số điện thoại', prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF6C63FF)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: _validatePhone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)]),
                      const SizedBox(height: 16),
                      // Pass
                      TextFormField(controller: _passwordController, obscureText: _obscurePassword, decoration: InputDecoration(labelText: 'Mật khẩu', prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6C63FF)), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => (v == null || v.length < 6) ? 'Mật khẩu quá ngắn' : null),
                      const SizedBox(height: 16),
                      // Confirm Pass
                      TextFormField(controller: _confirmPasswordController, obscureText: _obscureConfirmPassword, decoration: InputDecoration(labelText: 'Xác nhận mật khẩu', prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6C63FF)), suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey), onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => (v != _passwordController.text) ? 'Mật khẩu không khớp' : null),
                      const SizedBox(height: 16),
                      // Terms
                      Row(children: [Checkbox(value: _acceptTerms, onChanged: (v) => setState(() => _acceptTerms = v ?? false), activeColor: const Color(0xFF6C63FF)), const Expanded(child: Text('Tôi đồng ý với Điều khoản sử dụng'))]),
                      const SizedBox(height: 24),
                      // Register Button
                      Container(width: double.infinity, height: 50, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)]), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))]), child: ElevatedButton(onPressed: _isLoading ? null : _handleRegister, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))),
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