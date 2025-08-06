import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'manager_attendance_screen.dart';

class ManagerScreen extends StatelessWidget {
  const ManagerScreen({Key? key}) : super(key: key);

  Future<String?> _getDepartmentId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId'); // Lấy userId từ SharedPreferences
    if (userId == null) {
      print('DEBUG: No userId found in SharedPreferences.');
      return null;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!doc.exists) {
        print('DEBUG: User document does not exist for UID: $userId');
        return null;
      }
      final departmentId = doc.data()?['departmentId'] as String?;
      print('DEBUG: Fetched departmentId: $departmentId');
      return departmentId;
    } catch (e) {
      print('DEBUG: Error fetching departmentId: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[600],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        elevation: 0,
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          radius: 16,
          child: Icon(Icons.person, color: Colors.white, size: 16),
        ),
        title: Row(
          children: [
            SizedBox(width: 12),
            Text(
              'MANAGER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.grid_3x3, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => _buildLeaveRequestNotificationSheet(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 30),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildManagementMenuItem(
                        icon: Icons.group,
                        label: 'Danh sách\nnhân viên',
                        onTap: () async {
                          final departmentId = await _getDepartmentId();
                          if (departmentId == null || departmentId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Không tìm thấy phòng ban. Vui lòng kiểm tra dữ liệu.')),
                            );
                            return;
                          }
                          Navigator.pushNamed(
                            context,
                            '/employee_list',
                            arguments: {'departmentId': departmentId},
                          );
                        },
                      ),
                      _buildManagementMenuItem(
                        icon: Icons.schedule,
                        label: 'Chấm công',
                        onTap: () => _navigateToAttendance(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildManagementMenuItem(
                        icon: Icons.assignment_turned_in,
                        label: 'Duyệt nghỉ phép',
                        onTap: () => _navigateToLeaveApproval(context),
                      ),
                    ],
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Đăng xuất',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildManagementMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 28,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAttendance(BuildContext context) {
    Navigator.pushNamed(context, '/manager_attendance');
  }

  void _navigateToLeaveApproval(BuildContext context) {
    Navigator.pushNamed(context, '/leave_approval');
  }

  Widget _buildLeaveRequestNotificationSheet() {
    return Container(
      height: 400,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông báo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('leave_requests')
                  .where('status', isEqualTo: 'pending')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Text('Lỗi: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) return Text('Không có đơn nào đang chờ duyệt.');

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.mail_outline),
                        title: Text(data['email'] ?? 'Không rõ người gửi'),
                        subtitle: Text(
                          'Lý do: ${data['reason'] ?? ''}\n'
                              'Từ: ${data['fromDate']} → Đến: ${data['toDate']}',
                        ),
                        isThreeLine: true,
                        trailing: Icon(Icons.pending_actions),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}