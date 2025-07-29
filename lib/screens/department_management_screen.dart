import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentManagementScreen extends StatefulWidget {
  const DepartmentManagementScreen({Key? key}) : super(key: key);

  @override
  _DepartmentManagementScreenState createState() => _DepartmentManagementScreenState();
}

class _DepartmentManagementScreenState extends State<DepartmentManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[600],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
              'ADMIN',
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
            onPressed: () {},
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
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Quản lý phòng ban',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('departments').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('Không có phòng ban nào.'));
                        }

                        final departments = snapshot.data!.docs.map((doc) {
                          return DepartmentInfo.fromFirestore(doc);
                        }).toList();

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: departments.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey[300],
                          ),
                          itemBuilder: (context, index) => _buildDepartmentItem(departments[index]),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _addNewDepartment,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDepartmentItem(DepartmentInfo department) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  department.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (department.manager.isNotEmpty)
                  Text(
                    'Trưởng phòng: ${department.manager}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${department.employeeCount} nhân viên',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: department.status == 'Hoạt động' ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              department.status,
              style: TextStyle(
                fontSize: 10,
                color: department.status == 'Hoạt động' ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showDepartmentActions(department),
            child: Icon(
              Icons.more_vert,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _addNewDepartment() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String manager = '';
        String status = 'Hoạt động';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Thêm phòng ban mới'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Tên phòng ban'),
                    onChanged: (value) => name = value,
                  ),
                  SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(labelText: 'Trưởng phòng'),
                    onChanged: (value) => manager = value,
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(labelText: 'Trạng thái'),
                    items: ['Hoạt động', 'Không hoạt động']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) => setState(() {
                      status = value!;
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (name.isNotEmpty) {
                      await FirebaseFirestore.instance.collection('departments').add({
                        'name': name,
                        'manager': manager,
                        'status': status,
                        'employeeCount': 0,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã thêm phòng ban mới!')),
                      );
                    }
                  },
                  child: Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDepartmentActions(DepartmentInfo department) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text('Chỉnh sửa'),
              onTap: () {
                Navigator.pop(context);
                _editDepartment(department);
              },
            ),
            ListTile(
              leading: Icon(Icons.people, color: Colors.green),
              title: Text('Xem nhân viên'),
              onTap: () {
                Navigator.pop(context);
                _viewDepartmentEmployees(department);
              },
            ),
            ListTile(
              leading: Icon(
                department.status == 'Hoạt động' ? Icons.pause : Icons.play_arrow,
                color: Colors.orange,
              ),
              title: Text(department.status == 'Hoạt động' ? 'Tạm dừng' : 'Kích hoạt'),
              onTap: () {
                Navigator.pop(context);
                _toggleDepartmentStatus(department);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Xóa', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteDepartment(department);
              },
            ),
          ],
        );
      },
    );
  }

  void _editDepartment(DepartmentInfo department) {
    String name = department.name;
    String manager = department.manager;
    String status = department.status;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Chỉnh sửa phòng ban'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Tên phòng ban'),
                    controller: TextEditingController(text: name),
                    onChanged: (value) => name = value,
                  ),
                  SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(labelText: 'Trưởng phòng'),
                    controller: TextEditingController(text: manager),
                    onChanged: (value) => manager = value,
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(labelText: 'Trạng thái'),
                    items: ['Hoạt động', 'Không hoạt động']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) => setState(() {
                      status = value!;
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (name.isNotEmpty && department.id.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('departments')
                          .doc(department.id)
                          .update({
                        'name': name,
                        'manager': manager,
                        'status': status,
                        'updatedAt': FieldValue.serverTimestamp(),
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã cập nhật thông tin phòng ban!')),
                      );
                    }
                  },
                  child: Text('Cập nhật'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _viewDepartmentEmployees(DepartmentInfo department) {
    // Chức năng xem danh sách nhân viên trong phòng ban
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Xem nhân viên phòng ${department.name}')),
    );
  }

  void _toggleDepartmentStatus(DepartmentInfo department) async {
    String newStatus = department.status == 'Hoạt động' ? 'Không hoạt động' : 'Hoạt động';

    if (department.id.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('departments')
          .doc(department.id)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã ${newStatus.toLowerCase()} phòng ban ${department.name}')),
      );
    }
  }

  void _deleteDepartment(DepartmentInfo department) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa phòng ban "${department.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (department.id.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('departments')
                      .doc(department.id)
                      .delete();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xóa phòng ban ${department.name}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class DepartmentInfo {
  final String id;
  final String name;
  final String manager;
  final String status;
  final int employeeCount;

  DepartmentInfo({
    required this.id,
    required this.name,
    required this.manager,
    required this.status,
    required this.employeeCount,
  });

  factory DepartmentInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DepartmentInfo(
      id: doc.id,
      name: data['name'] ?? '',
      manager: data['manager'] ?? '',
      status: data['status'] ?? 'Hoạt động',
      employeeCount: data['employeeCount'] ?? 0,
    );
  }
}