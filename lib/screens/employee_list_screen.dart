import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeListScreen extends StatefulWidget {
  final String departmentId;

  const EmployeeListScreen({Key? key, required this.departmentId}) : super(key: key);

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    print('DEBUG: Received departmentId: ${widget.departmentId}');
    if (widget.departmentId.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('Vui lòng chọn phòng ban hợp lệ.'),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.blueGrey[600],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: const [
            CircleAvatar(
              backgroundColor: Colors.red,
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
            SizedBox(width: 12),
            Text(
              'Danh sách nhân viên',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.grid_3x3, color: Colors.white),
          SizedBox(width: 8),
          Icon(Icons.notifications_outlined, color: Colors.white),
          SizedBox(width: 8),
          Icon(Icons.help_outline, color: Colors.white),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nhân viên',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('role', isEqualTo: 'employee')
                          .where('departmentId', isEqualTo: widget.departmentId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          print('DEBUG: No data or empty for departmentId: ${widget.departmentId}');
                          print('DEBUG: Query snapshot data: ${snapshot.data?.docs.map((doc) => doc.data()).toList()}');
                          return const Center(
                              child: Text('Không có nhân viên nào.'));
                        }

                        final employees = snapshot.data!.docs
                            .map((doc) => EmployeeInfo.fromFirestore(doc))
                            .where((emp) =>
                        emp.name.toLowerCase().contains(searchQuery) ||
                            emp.email.toLowerCase().contains(searchQuery))
                            .toList();
                        print('DEBUG: Found ${employees.length} employees with departmentId: ${widget.departmentId}');

                        if (employees.isEmpty) {
                          return const Center(
                            child: Text('Không tìm thấy nhân viên phù hợp.'),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: employees.length,
                          itemBuilder: (context, index) =>
                              _buildEmployeeItem(employees[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmployeeItem(EmployeeInfo employee) {
    return GestureDetector(
      onTap: () => _showEmployeeDetail(employee),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              employee.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vị trí: ${employee.role}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            if (employee.email.isNotEmpty)
              Text(
                'Email: ${employee.email}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEmployeeDetail(EmployeeInfo employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(employee: employee),
      ),
    );
  }
}

class EmployeeInfo {
  final String id;
  final String name;
  final String role;
  final String email;
  final String? departmentId;

  EmployeeInfo({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.departmentId,
  });

  factory EmployeeInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    print('DEBUG: Document data: $data');
    return EmployeeInfo(
      id: doc.id,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      email: data['email'] ?? '',
      departmentId: data['departmentId'],
    );
  }
}

class EmployeeDetailScreen extends StatelessWidget {
  final EmployeeInfo employee;

  const EmployeeDetailScreen({Key? key, required this.employee})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[600],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: const [
            CircleAvatar(
              backgroundColor: Colors.red,
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
            SizedBox(width: 12),
            Text(
              'Chi tiết nhân viên',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.grid_3x3, color: Colors.white),
          SizedBox(width: 8),
          Icon(Icons.notifications_outlined, color: Colors.white),
          SizedBox(width: 8),
          Icon(Icons.help_outline, color: Colors.white),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vị trí: ${employee.role}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Email: ${employee.email}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('departments')
                                .doc(employee.departmentId)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text(
                                  'Phòng ban: Đang tải...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                );
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return Text(
                                  'Phòng ban: Không xác định',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                );
                              }
                              final deptData = snapshot.data!.data() as Map<String, dynamic>?;
                              return Text(
                                'Phòng ban: ${deptData?['name'] ?? employee.departmentId}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}