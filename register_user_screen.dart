import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// [RegisterUserScreen] é um widget stateful que permite que usuários
/// se registrem no sistema como alunos ou professores, dependendo do
/// código de registro fornecido.
class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  _RegisterUserScreenState createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController matriculaController = TextEditingController();
  final TextEditingController turmaController = TextEditingController();
  final TextEditingController turnoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();
  String userRole = '';

  /// [registerUser] é uma função assíncrona que cria uma nova conta de usuário
  /// usando Firebase Authentication e salva os dados do usuário no Firestore.
  /// O tipo de usuário (aluno ou professor) é determinado pelo código de
  /// registro fornecido.
  Future<void> registerUser() async {
    if (codigoController.text == 'cs-aluno') {
      userRole = 'aluno';
    } else if (codigoController.text == 'cs-professor') {
      userRole = 'professor';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código inválido')),
      );
      return;
    }

    try {
      // Cria um novo usuário com email e senha
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: senhaController.text,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Salva os dados do usuário no Firestore
        CollectionReference users = FirebaseFirestore.instance.collection('users');
        await users.doc(user.uid).set({
          'nome': nomeController.text,
          'email': emailController.text,
          'userId': user.uid,
          'role': userRole,
          if (userRole == 'aluno') 'matricula': matriculaController.text,
          if (userRole == 'aluno') 'turma': turmaController.text,
          if (userRole == 'aluno') 'turno': turnoController.text,
        });

        // Mostra uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário registrado com sucesso')),
        );

        // Limpa os campos de texto
        nomeController.clear();
        matriculaController.clear();
        turmaController.clear();
        turnoController.clear();
        emailController.clear();
        senhaController.clear();
        codigoController.clear();
      }
    } catch (e) {
      // Mostra uma mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar usuário: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de texto para o nome do usuário
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            if (userRole == 'aluno')
            // Campo de texto para a matrícula do aluno (se o usuário for aluno)
              TextField(
                controller: matriculaController,
                decoration: const InputDecoration(labelText: 'Matrícula'),
              ),
            if (userRole == 'aluno')
            // Campo de texto para a turma do aluno (se o usuário for aluno)
              TextField(
                controller: turmaController,
                decoration: const InputDecoration(labelText: 'Turma'),
              ),
            if (userRole == 'aluno')
            // Campo de texto para o turno do aluno (se o usuário for aluno)
              TextField(
                controller: turnoController,
                decoration: const InputDecoration(labelText: 'Turno'),
              ),
            // Campo de texto para o email do usuário
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            // Campo de texto para a senha do usuário
            TextField(
              controller: senhaController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            // Campo de texto para o código de registro
            TextField(
              controller: codigoController,
              decoration: const InputDecoration(labelText: 'Código de Registro'),
            ),
            const SizedBox(height: 20),
            // Botão para registrar o usuário
            ElevatedButton(
              onPressed: registerUser,
              child: const Text('Registrar Usuário'),
            ),
          ],
        ),
      ),
    );
  }
}
