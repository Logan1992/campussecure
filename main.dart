import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/student_qr_screen.dart';
import 'screens/teacher_scan_screen.dart';
import 'screens/register_student_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/register_user_screen.dart';
import 'screens/initial_screen.dart';
import 'screens/teacher_main_screen.dart';

/// Função principal do aplicativo que inicializa o Firebase e executa o app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const StudentEntranceApp());
}

/// [StudentEntranceApp] é a classe principal do aplicativo, responsável por
/// definir o tema e as rotas do aplicativo.
class StudentEntranceApp extends StatelessWidget {
  const StudentEntranceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Entrance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/initial',
      routes: {
        '/initial': (context) => const InitialScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterUserScreen(),
        '/register_student': (context) => const RegisterStudentScreen(),
        '/student_qr': (context) => const StudentQRScreen(),
        '/teacher_scan': (context) => const TeacherScanScreen(),
        '/attendance': (context) => const AttendanceScreen(),
        '/teacher_main': (context) => const TeacherMainScreen(),
      },
    );
  }
}
