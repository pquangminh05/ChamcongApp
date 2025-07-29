import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/attendance_history_screen.dart';
import 'screens/employee_info_screen.dart';
import 'screens/leave_request_screen.dart';
import 'screens/checkin_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/manager_screen.dart';
import 'screens/department_management_screen.dart';
import 'screens/employee_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/attendance_history': (_) => const AttendanceHistoryScreen(),
        '/employee_info': (_) => const EmployeeInfoScreen(),
        '/leave_request': (_) => const LeaveRequestScreen(),
        '/checkin': (context) => CheckInScreen(),
        '/admin': (context) => const AdminScreen(),
        '/user_management': (context) => const UserManagementScreen(),
        '/manager': (context) => const ManagerScreen(),
        '/department_management': (context) => const DepartmentManagementScreen(),
        '/employee_list': (context) => const EmployeeListScreen(),
      }
    );
  }
}
