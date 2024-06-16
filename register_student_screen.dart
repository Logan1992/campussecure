import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// [RegisterStudentScreen] é um widget stateful que permite que professores
/// registrem novos alunos no sistema, incluindo seus dados pessoais e
/// credenciais de login.
class RegisterStudentScreen extends StatefulWidget {
  const RegisterStudentScreen({super.key});

  @override
  _RegisterStudentScreenState createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController matriculaController = TextEditingController();
  final TextEditingController turmaController = TextEditingController();
  final TextEditingController turnoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  /// [registerStudent] é uma função assíncrona que cria uma nova conta de aluno
  /// usando Firebase Authentication e salva os dados do aluno no Firestore.
  Future<void> registerStudent() async {
    try {
      // Cria um novo usuário com email e senha
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: senhaController.text,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Salva os dados do aluno no Firestore
        CollectionReference users = FirebaseFirestore.instance.collection('users');
        await users.doc(user.uid).set({
          'nome': nomeController.text,
          'email': emailController.text,
          'matricula': matriculaController.text,
          'turma': turmaController.text,
          'turno': turnoController.text,
          'userId': user.uid,
          'role': 'aluno',
        });

        // Mostra uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aluno registrado com sucesso')),
        );

        // Limpa os campos de texto
        nomeController.clear();
        matriculaController.clear();
        turmaController.clear();
        turnoController.clear();
        emailController.clear();
        senhaController.clear();
      }
    } catch (e) {
      // Mostra uma mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar aluno: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Aluno'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C6FB), Color(0xFF005BEA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/student_icon.png',
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 40),
              _buildTextField(
                controller: nomeController,
                hintText: 'Nome',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: matriculaController,
                hintText: 'Matrícula',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: turmaController,
                hintText: 'Turma',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: turnoController,
                hintText: 'Turno',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: emailController,
                hintText: 'E-mail',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: senhaController,
                hintText: 'Senha',
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registerStudent,
                child: const Text('Registrar Aluno'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// [_buildTextField] é uma função auxiliar que cria e retorna um [TextField]
  /// personalizado com um texto de dica.
  ///
  /// Parâmetros:
  /// - [controller]: Controlador de texto para o campo de texto.
  /// - [hintText]: Texto de dica a ser exibido dentro do campo de texto.
  /// - [obscureText]: Indica se o campo de texto deve obscurecer o texto digitado (como em campos de senha).
  Widget _buildTextField({
    required TextEditingController controller,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }
}
