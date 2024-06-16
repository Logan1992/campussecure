import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// [LoginScreen] é um widget stateful que permite aos usuários fazer login
/// no aplicativo usando suas credenciais de email e senha. Dependendo do
/// papel do usuário (professor ou aluno), ele será redirecionado para a
/// tela apropriada.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// [login] é uma função assíncrona que tenta autenticar o usuário com
  /// Firebase Authentication usando email e senha. Após a autenticação,
  /// o usuário é redirecionado para a tela apropriada com base em seu papel.
  Future<void> login() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String role = userDoc['role'];
          if (role == 'professor') {
            Navigator.pushReplacementNamed(context, '/teacher_main');
          } else if (role == 'aluno') {
            Navigator.pushReplacementNamed(context, '/student_qr');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário não encontrado')),
          );
        }
      }
    } catch (e) {
      print('Erro ao fazer login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao fazer login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C6FB), Color(0xFF005BEA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    'assets/logo.png',
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: emailController,
                    icon: FontAwesomeIcons.user,
                    hintText: 'Email',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: passwordController,
                    icon: FontAwesomeIcons.lock,
                    hintText: 'Senha',
                    obscureText: true,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(
                      FontAwesomeIcons.arrowRight,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// [_buildTextField] é um helper function que cria e retorna um [TextField]
  /// personalizado com um ícone de prefixo.
  ///
  /// Parâmetros:
  /// - [controller]: Controlador de texto para o campo de texto.
  /// - [icon]: Ícone a ser exibido dentro do campo de texto.
  /// - [hintText]: Texto de dica a ser exibido dentro do campo de texto.
  /// - [obscureText]: Indica se o campo de texto deve obscurecer o texto digitado (como em campos de senha).
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
