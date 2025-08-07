import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:intl/intl.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({Key? key}) : super(key: key);

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  String? _ip;
  String? _status;
  bool _loading = false;
  bool _hasCheckedIn = false;
  bool _hasCheckedOut = false;
  String? _userId;
  String? _userEmail;

  final String companyIpPrefix = '172.16.1.';

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getIp();
  }

  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');

    if (_userId != null) {
      // Lấy email từ Firestore dựa trên userId
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId!)
            .get();

        if (userDoc.exists) {
          _userEmail = userDoc.data()?['email'];
        }
      } catch (e) {
        print('Error getting user data: $e');
      }
    }

    if (_userId != null) {
      _checkTodayStatus();
    }
  }

  Future<void> _getIp() async {
    final info = NetworkInfo();
    String? ip = await info.getWifiIP();
    setState(() {
      _ip = ip;
    });
  }

  Future<void> _checkTodayStatus() async {
    if (_userId == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final query = await FirebaseFirestore.instance
        .collection('checkins')
        .where('uid', isEqualTo: _userId)
        .where('date', isEqualTo: today)
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      if (data['type'] == 'checkin') {
        _hasCheckedIn = true;
      } else if (data['type'] == 'checkout') {
        _hasCheckedOut = true;
      }
    }

    setState(() {});
  }

  Future<void> _submitCheck(String type) async {
    if (_userId == null) {
      setState(() {
        _status = 'Lỗi: Không tìm thấy thông tin người dùng!';
      });
      return;
    }

    if (_ip == null || !_ip!.startsWith(companyIpPrefix)) {
      setState(() {
        _status = 'Bạn không kết nối đúng wifi công ty!';
      });
      return;
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (type == 'checkin' && _hasCheckedIn) {
      setState(() => _status = 'Bạn đã chấm công Check In hôm nay!');
      return;
    }

    if (type == 'checkout') {
      if (!_hasCheckedIn) {
        setState(() => _status = 'Bạn phải Check In trước khi Check Out!');
        return;
      }
      if (_hasCheckedOut) {
        setState(() => _status = 'Bạn đã Check Out hôm nay!');
        return;
      }
    }

    setState(() {
      _loading = true;
      _status = null;
    });

    try {
      await FirebaseFirestore.instance.collection('checkins').add({
        'uid': _userId,
        'email': _userEmail,
        'ip': _ip,
        'timestamp': FieldValue.serverTimestamp(),
        'type': type,
        'date': today,
      });

      // Thêm thông báo vào Firestore
      final message = (type == 'checkin')
          ? 'Thực hiện chấm công cho ngày $today thành công'
          : 'Thực hiện check out cho ngày $today thành công';

      await FirebaseFirestore.instance.collection('notifications').add({
        'uid': _userId,
        'type': 'checkin',
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _status = 'Chấm công $type thành công!';
        if (type == 'checkin') {
          _hasCheckedIn = true;
        } else {
          _hasCheckedOut = true;
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Lỗi khi chấm công!';
      });
      print('Error submitting check: $e');
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
              const Text('Địa chỉ IP hiện tại:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_ip ?? 'Đang lấy địa chỉ IP...'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (_loading || _hasCheckedIn) ? null : () => _submitCheck('checkin'),
                child: _loading && !_hasCheckedIn
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Check In'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_loading || !_hasCheckedIn || _hasCheckedOut)
                    ? null
                    : () => _submitCheck('checkout'),
                child: _loading && _hasCheckedIn && !_hasCheckedOut
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Check Out'),
              ),
              if (_status != null) ...[
                const SizedBox(height: 16),
                Text(_status!,
                    style: TextStyle(
                        color: _status!.contains('thành công')
                            ? Colors.green
                            : Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
