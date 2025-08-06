import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm import này

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Vui lòng nhập đầy đủ thông tin.';
        _isLoading = false;
      });
      return;
    }

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() {
          _error = 'Email không tồn tại.';
          _isLoading = false;
        });
        return;
      }

      final userDoc = query.docs.first; // Lấy document
      final userData = userDoc.data();
      final savedPassword = userData['password'];

      if (savedPassword != password) {
        setState(() {
          _error = 'Mật khẩu không đúng.';
          _isLoading = false;
        });
        return;
      }

      // LUU USERID VÀO SHAREDPREFERENCES
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userDoc.id); // Lưu document ID
      await prefs.setString('userName', userData['name'] ?? ''); // Lưu thêm name nếu muốn
      await prefs.setString('userRole', userData['role'] ?? ''); // Lưu thêm role nếu muốn

      print('DEBUG: Saved userId to SharedPreferences: ${userDoc.id}'); // Debug log

      // Điều hướng dựa trên role
      final role = userData['role'];
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (role == 'manager') {
        Navigator.pushReplacementNamed(context, '/manager');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('DEBUG: Login error: $e'); // Debug log
      setState(() {
        _error = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.3, 0.3, 0.7, 0.7],
                colors: [
                  Color(0xFF5C819C),
                  Color(0xFFD1D8DE),
                  Color(0xFFD1D8DE),
                  Color(0xFF5C819C),
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Vui lòng đăng nhập',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Tên tài khoản'),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF5C819C),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Mật khẩu'),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF5C819C),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    if (_error != null)
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C819C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                            : const Text('Xác nhận'),
                      ),
                    ),
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