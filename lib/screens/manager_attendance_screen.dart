import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerAttendanceScreen extends StatefulWidget {
  final String managerId;

  const ManagerAttendanceScreen({required this.managerId, super.key});

  @override
  State<ManagerAttendanceScreen> createState() => _ManagerAttendanceScreenState();
}

class _ManagerAttendanceScreenState extends State<ManagerAttendanceScreen> {
  List<DocumentSnapshot> employees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      setState(() {
        isLoading = true;
      });

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('managerId', isEqualTo: widget.managerId)
          .get();

      setState(() {
        employees = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  Future<void> markAttendance(String uid, String name) async {
    try {
      final today = DateTime.now();
      final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // Kiểm tra xem đã chấm công hôm nay chưa
      final existingAttendance = await FirebaseFirestore.instance
          .collection('attendances')
          .where('uid', isEqualTo: uid)
          .where('date', isEqualTo: dateStr)
          .get();

      if (existingAttendance.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name đã được chấm công hôm nay')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('attendances').add({
        'uid': uid,
        'employeeName': name,
        'checkIn': Timestamp.fromDate(today),
        'date': dateStr,
        'status': 'present',
        'markedBy': widget.managerId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chấm công cho $name thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chấm công: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text(
          'Chấm công nhân viên',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blueGrey[700],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchEmployees,
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey[700]!),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải danh sách nhân viên...',
              style: TextStyle(
                color: Colors.blueGrey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : employees.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.blueGrey[300],
            ),
            SizedBox(height: 16),
            Text(
              'Không có nhân viên nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueGrey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Chưa có nhân viên được phân công cho bạn',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey[400],
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchEmployees,
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final employee = employees[index];
            final data = employee.data() as Map<String, dynamic>;

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blueGrey[200],
                      radius: 25,
                      child: Icon(
                        Icons.person,
                        color: Colors.blueGrey[700],
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? 'Tên không xác định',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            data['email'] ?? 'Email không xác định',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey[600],
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Phòng ban: ${data['department'] ?? 'Chưa xác định'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => markAttendance(
                        employee.id,
                        data['name'] ?? 'Tên không xác định',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 1,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Chấm công',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}