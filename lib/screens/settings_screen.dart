import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final Function(int)? onHeartCountChanged;
  final Function(int)? onCoinCountChanged;

  const SettingsScreen({
    Key? key,
    this.onHeartCountChanged,
    this.onCoinCountChanged,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Thông báo'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('Âm thanh'),
            trailing: Switch(
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Chế độ tối'),
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Ngôn ngữ'),
            trailing: const Text('Tiếng Việt'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Ngôn ngữ'),
                  content: const Text('Chọn ngôn ngữ cho ứng dụng.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Dung lượng'),
            subtitle: const Text('Xóa bộ nhớ cache'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xóa cache'),
                  content: const Text('Xóa dữ liệu tạm thời để giải phóng bộ nhớ.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Đặt lại tiến độ'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Đặt lại tiến độ'),
                  content: const Text('Bạn có chắc chắn muốn đặt lại tất cả tiến độ học tập?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onHeartCountChanged?.call(5);
                        widget.onCoinCountChanged?.call(0);
                        Navigator.pop(context);
                      },
                      child: const Text('Đặt lại'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}