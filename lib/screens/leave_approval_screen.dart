import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveApprovalScreen extends StatelessWidget {
  const LeaveApprovalScreen({Key? key}) : super(key: key);

  Future<void> _updateStatus(
      String docId, String status, String userId, Timestamp startDate) async {
    // Cập nhật trạng thái đơn nghỉ
    await FirebaseFirestore.instance
        .collection('leave_requests')
        .doc(docId)
        .update({'status': status});

    // Định dạng ngày dd/mm/yy
    final date = startDate.toDate();
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';

    // Tạo nội dung thông báo
    String message = (status == 'approved')
        ? 'Đơn xin nghỉ cho ngày $formattedDate đã được chấp nhận.'
        : 'Đơn xin nghỉ cho ngày $formattedDate đã bị từ chối.';

    // Gửi thông báo
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'title': 'Trạng thái đơn nghỉ',
      'content': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _getUserName(String? userId) async {
    if (userId == null) return 'Không rõ tên';
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    return doc.data()?['name'] ?? 'Không rõ tên';
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

              String formatDate(Timestamp? timestamp) {
                if (timestamp == null) return 'Không rõ';
                final date = timestamp.toDate();
                return '${date.day}/${date.month}/${date.year}';
              }

              return FutureBuilder<String>(
                future: _getUserName(data['userId']),
                builder: (context, snapshotName) {
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(snapshotName.data ?? 'Đang tải tên...'),
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
                            onPressed: () => _updateStatus(
                              docId,
                              'approved',
                              data['userId'],
                              data['startDate'],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => _updateStatus(
                              docId,
                              'rejected',
                              data['userId'],
                              data['startDate'],
                            ),
                          ),
                        ],
                      )
                          : null,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
