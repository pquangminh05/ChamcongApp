import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:network_info_plus/network_info_plus.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({Key? key}) : super(key: key);

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  String? _ip;
  String? _status;
  bool _loading = false;

  final String companyIpPrefix = '192.168.1.';

  @override
  void initState() {
    super.initState();
    _getIp();
  }

  Future<void> _getIp() async {
    final info = NetworkInfo();
    String? ip = await info.getWifiIP();
    setState(() {
      _ip = ip;
    });
  }

  Future<void> _checkIn() async {
    if (_ip == null || !_ip!.startsWith(companyIpPrefix)) {
      setState(() {
        _status = 'Bạn không kết nối đúng wifi công ty!';
      });
      return;
    }
    setState(() {
      _loading = true;
      _status = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('checkins').add({
        'uid': user?.uid,
        'email': user?.email,
        'ip': _ip,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _status = 'Chấm công thành công!';
      });
    } catch (e) {
      setState(() {
        _status = 'Lỗi khi chấm công!';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chấm công bằng địa chỉ IP')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Địa chỉ IP hiện tại:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(_ip ?? 'Đang lấy địa chỉ IP...'),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _checkIn,
                child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Chấm công'),
              ),
              if (_status != null) ...[
                SizedBox(height: 16),
                Text(_status!, style: TextStyle(color: _status == 'Chấm công thành công!' ? Colors.green : Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

