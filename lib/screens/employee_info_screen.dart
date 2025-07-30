import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeInfoScreen extends StatefulWidget {
  const EmployeeInfoScreen({Key? key}) : super(key: key);

  @override
  _EmployeeInfoScreenState createState() => _EmployeeInfoScreenState();
}

class _EmployeeInfoScreenState extends State<EmployeeInfoScreen> {
  // Dữ liệu mẫu thông tin nhân viên
  final Map<String, String> employeeInfo = {
    'id': 'BT123469',
    'name': 'Phạm Quang Anh',
    'phone': '0123456789',
    'email': 'phamanh@company.com',
    'department': 'Phòng IT',
    'position': 'Lập trình viên',
  };

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.red,
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
            SizedBox(width: 12),
            Text(
              _getDisplayName(user),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.grid_3x3, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            // Container chính chứa thông tin nhân viên
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tiêu đề
                  Text(
                    'Thông tin Nhân viên',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Các trường thông tin
                  _buildInfoField('Mã:', employeeInfo['id']!),
                  SizedBox(height: 12),
                  _buildInfoField('Họ và tên:', employeeInfo['name']!),
                  SizedBox(height: 12),
                  _buildInfoField('Số điện thoại:', employeeInfo['phone']!),
                  SizedBox(height: 12),
                  _buildInfoField('Email:', employeeInfo['email']!),
                  SizedBox(height: 12),
                  _buildInfoField('Phòng ban:', employeeInfo['department']!),
                  SizedBox(height: 12),
                  _buildInfoField('Chức vụ:', employeeInfo['position']!),
                  SizedBox(height: 12),

                  // Trường trống cuối cung
                  _buildInfoField('', ''),

                  SizedBox(height: 20),


                ],
              ),
            ),

            SizedBox(height: 100),

            // FAB Button ở cuối (giống HomeScreen)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.blueGrey[600],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }



  String _getDisplayName(User? user) {
    if (user == null) return 'Người dùng';

    if (user.displayName != null && user.displayName!.isNotEmpty) {
      String fullName = user.displayName!;
      if (fullName.length > 10) {
        return '${fullName.substring(0, 8)}...';
      }
      return fullName;
    }

    if (user.email != null && user.email!.isNotEmpty) {
      String emailName = user.email!.split('@')[0];
      if (emailName.isNotEmpty) {
        String displayName = emailName[0].toUpperCase() + emailName.substring(1).toLowerCase();
        if (displayName.length > 10) {
          return '${displayName.substring(0, 8)}...';
        }
        return displayName;
      }
    }

    return 'Người dùng';
  }
}