import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'LoginScreen.dart';
import 'main_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- 1. ẢNH NỀN ---
          Positioned.fill(
            child: Image.asset(
              'assets/images/logo3.png',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stackTrace) => Container(color: const Color(0xFF87CEEB)),
            ),
          ),

          // --- 2. LỚP PHỦ MỜ (GRADIENT) ---
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1), // Trên sáng
                    Colors.black.withOpacity(0.5), // Giữa vừa
                    Colors.black.withOpacity(0.9), // Dưới tối hẳn để nổi nút
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // --- 3. NỘI DUNG CHÍNH (CÓ HIỆU ỨNG TRƯỢT LÊN) ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) {
                  // Hiệu ứng: Mờ dần hiện rõ + Trượt từ dưới lên 50px
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // --- LOGO & SLOGAN ---
                    // Nếu bạn có file logo.png thì bỏ comment dòng dưới
                    // Image.asset('assets/images/logo.png', width: 120),
                    const SizedBox(height: 20),

                    const Text(
                      "VOCABOOM",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Học Tiếng Anh\nChưa Bao Giờ Vui Đến Thế!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 50), // Khoảng cách lớn trước khi đến nút

                    // --- NÚT 1: KHÁM PHÁ (Gradient Button) ---
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7E5F), Color(0xFFFEB47B)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF7E5F).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainScreen(userData: null)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text(
                          "Bắt đầu ngay 🚀",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- NÚT 2: ĐĂNG NHẬP (Glass Button) ---
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          backgroundColor: Colors.white.withOpacity(0.1), // Hiệu ứng kính nhẹ
                        ),
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- NÚT 3: ĐĂNG KÝ (Text Link) ---
                    GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(

                              builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'Bạn mới đến đây? ',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Đăng ký',
                              style: TextStyle(
                                color: Color(0xFFFEB47B), // Màu cam nhạt
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30), // Padding đáy
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}