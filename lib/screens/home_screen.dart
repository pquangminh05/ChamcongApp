import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
        title: Row(
          children: [
            Text(
              _getDisplayName(user),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.grid_3x3, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildNotificationSheet(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
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
            _buildBanner(),
            _buildSection1(context),
            SizedBox(height: 100),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[700],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(Icons.home, color: Colors.white, size: 30),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[900]!, Colors.green[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    bottomLeft: Radius.circular(60),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('iPhone 15', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Mua ngay', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 30,
              child: Text(
                'iPhone 15 Pro Max\nChính hãng VN/A',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 30,
              child: Container(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildColorOption(Colors.grey[800]!),
                    _buildColorOption(Colors.blue[900]!),
                    _buildColorOption(Colors.purple[400]!),
                    _buildColorOption(Colors.grey[400]!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection1(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Section 1', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[600]),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/checkin'),
                child: _buildMenuItem(icon: Icons.wifi, label: 'Chấm công\nbằng IP', color: Colors.blue),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/leave_request'),
                child: _buildMenuItem(icon: Icons.description, label: 'Đơn xin\nnghỉ', color: Colors.green),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/attendance_history'),
                child: _buildMenuItem(icon: Icons.search, label: 'Tra cứu\nchấm công', color: Colors.orange),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/employee_info'),
                child: _buildMenuItem(icon: Icons.person, label: 'Thông tin\nnhân viên', color: Colors.purple),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text('Mã ID: ', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              Text('BT123469', style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    return Container(
      width: 20,
      height: 20,
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String label, required Color color}) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.2)),
      ],
    );
  }

  Widget _buildNotificationSheet() {
    return Container(
      height: 400,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thông báo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('notifications').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Lỗi: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) return Text('Không có thông báo.');

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text(data['title'] ?? 'Không có tiêu đề'),
                      subtitle: Text(data['content'] ?? ''),
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

  String _getDisplayName(User? user) {
    if (user == null) return 'Người dùng';
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      String fullName = user.displayName!;
      return fullName.length > 10 ? '${fullName.substring(0, 8)}...' : fullName;
    }
    if (user.email != null && user.email!.isNotEmpty) {
      String emailName = user.email!.split('@')[0];
      String displayName = emailName[0].toUpperCase() + emailName.substring(1).toLowerCase();
      return displayName.length > 10 ? '${displayName.substring(0, 8)}...' : displayName;
    }
    return 'Người dùng';
  }
}
