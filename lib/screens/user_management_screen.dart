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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.red,
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
            SizedBox(width: 12),
            Text('ADMIN',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            Icon(Icons.keyboard_arrow_down, color: Colors.white),
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
          const SizedBox(height: 30),
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
                      offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text('Quản lý tài khoản',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('Không có người dùng.'));
                        }

                        final users = snapshot.data!.docs
                            .map((doc) => UserInfo.fromFirestore(doc))
                            .toList();

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: users.length,
                          separatorBuilder: (context, index) => Divider(
                              height: 1, color: Colors.grey[300]),
                          itemBuilder: (context, index) =>
                              _buildUserItem(users[index]),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
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
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5)
                            ],
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildUserItem(UserInfo user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(user.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500))),
          Expanded(
              flex: 1,
              child: Text(user.role, style: const TextStyle(fontSize: 14))),
          GestureDetector(
            onTap: () => _showUserActions(user),
            child: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
          ),
        ],
      ),
    );
  }

  void _addNewUser() {
    String name = '';
    String email = '';
    String password = '';
    String role = 'employee';
    String? departmentId;
    bool isLoading = false;
    String? errorText;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Thêm người dùng mới'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Tên người dùng'),
                      onChanged: (value) => name = value,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      onChanged: (value) => email = value,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Mật khẩu'),
                      onChanged: (value) => password = value,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(labelText: 'Vai trò'),
                      items: ['admin', 'manager', 'employee']
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (value) => setState(() {
                        role = value!;
                      }),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('departments').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('Không có phòng ban.');
                        }
                        final departments = snapshot.data!.docs.map((doc) => doc.id).toList();
                        return DropdownButtonFormField<String>(
                          value: departmentId,
                          hint: const Text('Chọn phòng ban'),
                          decoration: const InputDecoration(labelText: 'Phòng ban'),
                          items: departments.map((deptId) => DropdownMenuItem(
                            value: deptId,
                            child: FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('departments').doc(deptId).get(),
                              builder: (context, deptSnapshot) {
                                if (deptSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Text('Đang tải...');
                                }
                                final deptData = deptSnapshot.data!.data() as Map<String, dynamic>?;
                                return Text(deptData?['name'] ?? deptId);
                              },
                            ),
                          )).toList(),
                          onChanged: (value) => setState(() {
                            departmentId = value;
                          }),
                        );
                      },
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (name.isEmpty || email.isEmpty || password.isEmpty) {
                      setState(() {
                        errorText = 'Vui lòng điền đầy đủ thông tin';
                      });
                      return;
                    }
                    if (!emailRegex.hasMatch(email)) {
                      setState(() {
                        errorText = 'Email không hợp lệ';
                      });
                      return;
                    }

                    setState(() {
                      isLoading = true;
                      errorText = null;
                    });

                    try {
                      final check = await FirebaseFirestore.instance
                          .collection('users')
                          .where('email', isEqualTo: email)
                          .get();

                      if (check.docs.isNotEmpty) {
                        setState(() {
                          errorText = 'Email này đã tồn tại';
                          isLoading = false;
                        });
                        return;
                      }

                      await FirebaseFirestore.instance
                          .collection('users')
                          .add({
                        'name': name,
                        'role': role,
                        'email': email,
                        'password': password,
                        'departmentId': departmentId,
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã thêm người dùng mới!')),
                      );
                    } catch (e) {
                      setState(() {
                        errorText = 'Có lỗi xảy ra: $e';
                      });
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Thêm'),
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
              leading: const Icon(Icons.edit),
              title: const Text('Sửa thông tin'),
              onTap: () {
                Navigator.pop(context);
                _editUser(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Đổi quyền'),
              onTap: () {
                Navigator.pop(context);
                _changeUserRole(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteUser(user);
              },
            ),
          ],
        );
      },
    );
  }

  void _editUser(UserInfo user) {
    String name = user.name;
    String email = user.email;
    String password = user.password;
    String role = user.role;
    String? departmentId = user.departmentId;
    bool isLoading = false;
    String? errorText;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Sửa thông tin người dùng'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: TextEditingController(text: name),
                      decoration: const InputDecoration(labelText: 'Tên người dùng'),
                      onChanged: (value) => name = value,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(text: email),
                      decoration: const InputDecoration(labelText: 'Email'),
                      onChanged: (value) => email = value,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(text: password),
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Mật khẩu'),
                      onChanged: (value) => password = value,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(labelText: 'Vai trò'),
                      items: ['admin', 'manager', 'employee']
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (value) => setState(() {
                        role = value!;
                      }),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('departments').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('Không có phòng ban.');
                        }
                        final departments = snapshot.data!.docs.map((doc) => doc.id).toList();
                        return DropdownButtonFormField<String>(
                          value: departmentId,
                          hint: const Text('Chọn phòng ban'),
                          decoration: const InputDecoration(labelText: 'Phòng ban'),
                          items: departments.map((deptId) => DropdownMenuItem(
                            value: deptId,
                            child: FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('departments').doc(deptId).get(),
                              builder: (context, deptSnapshot) {
                                if (deptSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Text('Đang tải...');
                                }
                                final deptData = deptSnapshot.data!.data() as Map<String, dynamic>?;
                                return Text(deptData?['name'] ?? deptId);
                              },
                            ),
                          )).toList(),
                          onChanged: (value) => setState(() {
                            departmentId = value;
                          }),
                        );
                      },
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (name.isEmpty || email.isEmpty || password.isEmpty) {
                      setState(() {
                        errorText = 'Vui lòng điền đầy đủ thông tin';
                      });
                      return;
                    }
                    if (!emailRegex.hasMatch(email)) {
                      setState(() {
                        errorText = 'Email không hợp lệ';
                      });
                      return;
                    }

                    setState(() {
                      isLoading = true;
                      errorText = null;
                    });

                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.id)
                          .update({
                        'name': name,
                        'email': email,
                        'password': password,
                        'role': role,
                        'departmentId': departmentId,
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã cập nhật người dùng!')),
                      );
                    } catch (e) {
                      setState(() {
                        errorText = 'Có lỗi xảy ra: $e';
                      });
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteUser(UserInfo user) async {
    if (user.id.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa người dùng.')));
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
              title: const Text('Đổi quyền người dùng'),
              content: DropdownButtonFormField<String>(
                value: ['admin', 'manager', 'employee'].contains(newRole)
                    ? newRole
                    : null,
                items: ['admin', 'manager', 'employee']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (value) => setState(() {
                  newRole = value!;
                }),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    if (user.id.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.id)
                          .update({'role': newRole});
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Đã cập nhật quyền người dùng.')),
                      );
                    }
                  },
                  child: const Text('Cập nhật'),
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
  final String password;
  final String? departmentId;

  UserInfo({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.password,
    this.departmentId,
  });

  factory UserInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserInfo(
      id: doc.id,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      departmentId: data['departmentId'],
    );
  }
}