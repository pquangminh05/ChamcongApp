import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveApprovalScreen extends StatelessWidget {
  const LeaveApprovalScreen({Key? key}) : super(key: key);

  // ✅ Cập nhật trạng thái và thêm thông báo
  Future<void> _updateStatus(String docId, String status, String userId) async {
    await FirebaseFirestore.instance
        .collection('leave_requests')
        .doc(docId)
        .update({'status': status});

    String message = (status == 'approved')
        ? 'Đơn xin nghỉ của bạn đã được chấp nhận.'
        : 'Đơn xin nghỉ của bạn đã bị từ chối.';

    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'title': 'Trạng thái đơn nghỉ',
      'content': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Duyệt đơn xin nghỉ'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leave_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Không có đơn xin nghỉ nào.'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              final docId = requests[index].id;
              final userId = data['userId']; // 👈 Phải có trong leave_requests

              // Xử lý thời gian an toàn
              String formatDate(Timestamp? timestamp) {
                if (timestamp == null) return 'Không rõ';
                final date = timestamp.toDate();
                return '${date.day}/${date.month}/${date.year}';
              }

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['displayName'] ?? 'Không rõ tên'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('Lý do: ${data['reason'] ?? 'Không rõ'}'),
                      Text('Từ: ${formatDate(data['startDate'])}'),
                      Text('Đến: ${formatDate(data['endDate'])}'),
                      Text('Trạng thái: ${data['status'] ?? 'pending'}'),
                    ],
                  ),
                  trailing: (data['status'] == 'pending')
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () =>
                            _updateStatus(docId, 'approved', userId),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () =>
                            _updateStatus(docId, 'rejected', userId),
                      ),
                    ],
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
