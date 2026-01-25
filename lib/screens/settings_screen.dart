import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/vocabulary_api_service.dart';
import 'LoginScreen.dart'; // Đảm bảo chỉ import, không được viết class LoginScreen ở dưới

class SettingsScreen extends StatefulWidget {
  final Function(int)? onHeartCountChanged;
  final Function(int)? onCoinCountChanged;
  final VoidCallback? onThemeChanged;

  const SettingsScreen({
    Key? key,
    this.onHeartCountChanged,
    this.onCoinCountChanged,
    this.onThemeChanged,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _soundEnabled = prefs.getBool('sound') ?? true;
      _darkMode = prefs.getBool('darkMode') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'vi';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _handleClearCache() {
    VocabularyApiService().clearCache();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa bộ nhớ đệm!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkMode ? const Color(0xFF1E1E1E) : Colors.grey[50],
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Thông báo'),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
              _saveSetting('notifications', val);
            },
          ),
          ListTile(
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}