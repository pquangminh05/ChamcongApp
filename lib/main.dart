import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/employee_screen.dart';
import 'screens/attendance_history_screen.dart';
import 'screens/employee_info_screen.dart';
import 'screens/leave_request_screen.dart';
import 'screens/checkin_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/manager_screen.dart';
import 'screens/department_management_screen.dart';
import 'screens/employee_list_screen.dart';
import 'screens/leave_approval_screen.dart';
import 'screens/manager_attendance_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

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
          '/home': (_) => const HomeScreen(),
          '/attendance_history': (_) => const AttendanceHistoryScreen(),
          '/employee_info': (_) => const EmployeeInfoScreen(),
          '/leave_request': (_) => const LeaveRequestScreen(),
          '/checkin': (context) => CheckInScreen(),
          '/admin': (context) => const AdminScreen(),
          '/user_management': (context) => const UserManagementScreen(),
          '/manager': (context) => const ManagerScreen(),
          '/department_management': (context) => const DepartmentManagementScreen(),
          '/employee_list': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            final departmentId = args?['departmentId'] ?? '';
            return EmployeeListScreen(departmentId: departmentId);
          },
          '/leave_approval': (context) => const LeaveApprovalScreen(),
          '/manager_attendance':(context) => const ManagerAttendanceScreen(departmentId: '',),
        }

    );

  }


}
