import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// [TeacherMainScreen] é um widget stateless que serve como a tela principal
/// para professores, fornecendo opções para consultar registros de presença,
/// registrar novos alunos e registrar entradas/saídas de alunos.
class TeacherMainScreen extends StatelessWidget {
  const TeacherMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Principal do Professor'),
        actions: [
          // Botão de logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C6FB), Color(0xFF005BEA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botão para a tela de consulta de presença
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/attendance');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Consulta'),
              ),
              const SizedBox(height: 20),
              // Botão para a tela de registro de novos alunos
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register_student');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Registrar Aluno'),
              ),
              const SizedBox(height: 20),
              // Botão para a tela de registro de entrada/saída de alunos
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/teacher_scan');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Registrar Entrada/Saída'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
