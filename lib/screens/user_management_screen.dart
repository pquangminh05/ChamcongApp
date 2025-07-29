import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
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
            Text('ADMIN', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.grid_3x3, color: Colors.white), onPressed: () {}),
          IconButton(icon: Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
          IconButton(icon: Icon(Icons.help_outline, color: Colors.white), onPressed: () {}),
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Text('Quản lý tài khoản', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('Không có người dùng.'));
                        }

                        final users = snapshot.data!.docs.map((doc) {
                          return UserInfo.fromFirestore(doc);
                        }).toList();

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: users.length,
                          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
                          itemBuilder: (context, index) => _buildUserItem(users[index]),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _addNewUser,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
                          ),
                          child: Icon(Icons.add, color: Colors.white, size: 24),
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

  Widget _buildUserItem(UserInfo user) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(user.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Expanded(flex: 1, child: Text(user.role, style: TextStyle(fontSize: 14))),
          GestureDetector(
            onTap: () => _showUserActions(user),
            child: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
          ),
        ],
      ),
    );
  }

  void _addNewUser() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String email = '';
        String role = 'Employee';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Thêm người dùng mới'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Tên người dùng'),
                    onChanged: (value) => name = value,
                  ),
                  SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(labelText: 'Email'),
                    onChanged: (value) => email = value,
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: InputDecoration(labelText: 'Vai trò'),
                    items: ['ADMIN', 'Manager', 'Employee']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (value) => setState(() {
                      role = value!;
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    if (name.isNotEmpty && email.isNotEmpty) {
                      await FirebaseFirestore.instance.collection('users').add({
                        'name': name,
                        'role': role,
                        'email': email,
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm người dùng mới!')));
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

  void _showUserActions(UserInfo user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Xóa', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteUser(user);
              },
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Đổi quyền'),
              onTap: () {
                Navigator.pop(context);
                _changeUserRole(user);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(UserInfo user) async {
    if (user.id.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(user.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa người dùng.')));
    }
  }

  void _changeUserRole(UserInfo user) {
    String newRole = user.role;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Đổi quyền người dùng'),
              content: DropdownButtonFormField<String>(
                value: ['admin', 'manager', 'employee'].contains(newRole) ? newRole : null,
                items: ['admin', 'manager', 'employee']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (value) => setState(() {
                  newRole = value!;
                }),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    if (user.id.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.id)
                          .update({'role': newRole});
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật quyền người dùng.')));
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
}

class UserInfo {
  final String id;
  final String name;
  final String role;
  final String email;

  UserInfo({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
  });

  factory UserInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserInfo(
      id: doc.id,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      email: data['email'] ?? '',
    );
  }
}
