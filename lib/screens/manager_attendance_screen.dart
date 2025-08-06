import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerAttendanceScreen extends StatefulWidget {
  final String departmentId;

  const ManagerAttendanceScreen({required this.departmentId, super.key});

  @override
  State<ManagerAttendanceScreen> createState() => _ManagerAttendanceScreenState();
}

class _ManagerAttendanceScreenState extends State<ManagerAttendanceScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedCheckInTime;
  TimeOfDay? selectedCheckOutTime;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectCheckInTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedCheckInTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != selectedCheckInTime) {
      setState(() {
        selectedCheckInTime = pickedTime;
      });
    }
  }

  Future<void> _selectCheckOutTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedCheckOutTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != selectedCheckOutTime) {
      setState(() {
        selectedCheckOutTime = pickedTime;
      });
    }
  }

  Future<void> markCheckIn(String uid, String name, String email) async {
    try {
      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn ngày.')),
        );
        return;
      }

      final now = DateTime.now();
      if (selectedDate!.isAfter(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể Check In cho ngày tương lai.')),
        );
        return;
      }

      final dateStr = "${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.year}";

      final checkInDateTime = selectedCheckInTime == null
          ? now
          : DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedCheckInTime!.hour,
        selectedCheckInTime!.minute,
      );

      final existing = await FirebaseFirestore.instance
          .collection('checkins')
          .where('uid', isEqualTo: uid)
          .where('date', isEqualTo: dateStr)
          .where('type', isEqualTo: 'checkin')
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name đã Check In ngày này')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('checkins').add({
        'date': dateStr,
        'email': email,
        'status': 'manual',
        'timestamp': Timestamp.fromDate(checkInDateTime),
        'type': 'checkin',
        'uid': uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check In cho $name thành công')),
      );
      setState(() {
        selectedCheckInTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi Check In: $e')),
      );
    }
  }

  Future<void> markCheckOut(String uid, String name, String email) async {
    try {
      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn ngày.')),
        );
        return;
      }

      final now = DateTime.now();
      if (selectedDate!.isAfter(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể Check Out cho ngày tương lai.')),
        );
        return;
      }

      final dateStr = "${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.year}";

      final checkOutDateTime = selectedCheckOutTime == null
          ? now
          : DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedCheckOutTime!.hour,
        selectedCheckOutTime!.minute,
      );

      final existingCheckIn = await FirebaseFirestore.instance
          .collection('checkins')
          .where('uid', isEqualTo: uid)
          .where('date', isEqualTo: dateStr)
          .where('type', isEqualTo: 'checkin')
          .get();

      if (existingCheckIn.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name chưa Check In ngày này')),
        );
        return;
      }

      final existingCheckOut = await FirebaseFirestore.instance
          .collection('checkins')
          .where('uid', isEqualTo: uid)
          .where('date', isEqualTo: dateStr)
          .where('type', isEqualTo: 'checkout')
          .get();

      if (existingCheckOut.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name đã Check Out ngày này')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('checkins').add({
        'date': dateStr,
        'email': email,
        'status': 'manual',
        'timestamp': Timestamp.fromDate(checkOutDateTime),
        'type': 'checkout',
        'uid': uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check Out cho $name thành công')),
      );
      setState(() {
        selectedCheckOutTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi Check Out: $e')),
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
            onPressed: () => setState(() {}), // Refresh UI
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      selectedDate == null
                          ? 'Chọn ngày'
                          : 'Ngày: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectCheckInTime(context),
                    child: Text(
                      selectedCheckInTime == null
                          ? 'Chọn giờ vào'
                          : 'Vào: ${selectedCheckInTime!.format(context)}',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectCheckOutTime(context),
                    child: Text(
                      selectedCheckOutTime == null
                          ? 'Chọn giờ ra (tùy chọn)'
                          : 'Ra: ${selectedCheckOutTime!.format(context)}',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'employee')
                  .where('departmentId', isEqualTo: widget.departmentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
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
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
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
                  );
                }

                final employees = snapshot.data!.docs;
                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
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
                                      'Phòng ban: ${data['departmentId'] ?? 'Chưa xác định'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueGrey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => markCheckIn(
                                      employee.id,
                                      data['name'] ?? 'Tên không xác định',
                                      data['email'] ?? 'Email không xác định',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[600],
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 1,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.login, size: 16),
                                        SizedBox(width: 4),
                                        Text('Check In', style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => markCheckOut(
                                      employee.id,
                                      data['name'] ?? 'Tên không xác định',
                                      data['email'] ?? 'Email không xác định',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange[600],
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 1,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.logout, size: 16),
                                        SizedBox(width: 4),
                                        Text('Check Out', style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}