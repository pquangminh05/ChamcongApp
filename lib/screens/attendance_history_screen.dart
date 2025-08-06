import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({Key? key}) : super(key: key);

  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.red,
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Text(
              _getDisplayName(user),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_3x3, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
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
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Lịch sử chấm công:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('checkins')
                        .where('email', isEqualTo: user?.email) // lọc theo email người dùng
                        .orderBy('timestamp', descending: true) // sắp xếp mới nhất trước
                        .limit(20) // giới hạn 20 bản ghi mới nhất
                        .snapshots(),

                    builder: (context, snapshot) {
                      print('Current UID: ${user?.uid}');
                      print('Docs count: ${snapshot.data?.docs.length}');
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Lỗi khi tải dữ liệu: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có dữ liệu chấm công',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Hãy bắt đầu chấm công để xem lịch sử',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      // sắp xếp mới nhất trước
                      docs.sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;
                        final bData = b.data() as Map<String, dynamic>;

                        if (aData['timestamp'] == null && bData['timestamp'] == null) return 0;
                        if (aData['timestamp'] == null) return 1;
                        if (bData['timestamp'] == null) return -1;

                        Timestamp aTime = aData['timestamp'] as Timestamp;
                        Timestamp bTime = bData['timestamp'] as Timestamp;
                        return bTime.compareTo(aTime);
                      });

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.grey[300],
                          indent: 20,
                          endIndent: 20,
                        ),
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return _buildAttendanceItem(data);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 100),
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
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceItem(Map<String, dynamic> data) {
    String formattedCheckIn = 'Chưa có';
    String formattedDate = data['date'] ?? 'Chưa có';
    String type = data['type'] ?? 'unknown';
    String email = data['email'] ?? '';

    if (data['timestamp'] != null) {
      try {
        Timestamp checkInTimestamp = data['timestamp'] as Timestamp;
        DateTime checkInTime = checkInTimestamp.toDate();
        formattedCheckIn = DateFormat('HH:mm:ss').format(checkInTime);
        if (formattedDate == 'Chưa có') {
          formattedDate = DateFormat('dd/MM/yyyy').format(checkInTime);
        }
      } catch (e) {
        formattedCheckIn = 'Lỗi format';
      }
    }

    Color statusColor = Colors.green;
    String statusText = 'Check-in';
    IconData statusIcon = Icons.login;

    switch (type.toLowerCase()) {
      case 'checkin':
        statusColor = Colors.green;
        statusText = 'Check-in';
        statusIcon = Icons.login;
        break;
      case 'checkout':
        statusColor = Colors.blue;
        statusText = 'Check-out';
        statusIcon = Icons.logout;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Không xác định';
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ngày $formattedDate',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 10, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Thời gian: $formattedCheckIn',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.email, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Email: $email',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
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
