import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// [StudentQRScreen] é um widget stateless que exibe um QR code gerado
/// a partir da matrícula do aluno, juntamente com seu nome e matrícula.
class StudentQRScreen extends StatelessWidget {
  const StudentQRScreen({super.key});

  /// [_getStudentInfo] é uma função assíncrona que recupera as informações
  /// do aluno autenticado a partir do Firestore. Retorna um mapa contendo
  /// o nome e a matrícula do aluno.
  Future<Map<String, String>> _getStudentInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return {'nome': 'No Name', 'matricula': 'No Matricula'};

    DocumentSnapshot studentDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (studentDoc.exists) {
      Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;
      return {
        'nome': studentData['nome'] ?? 'No Name',
        'matricula': studentData['matricula'] ?? 'No Matricula',
      };
    }
    return {'nome': 'No Name', 'matricula': 'No Matricula'};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<Map<String, String>>(
          future: _getStudentInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error fetching student info');
            } else if (!snapshot.hasData || snapshot.data!['matricula'] == 'No Matricula') {
              return const Text('No Matricula');
            } else {
              Map<String, String> studentInfo = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: studentInfo['matricula']!,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nome: ${studentInfo['nome']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Matrícula: ${studentInfo['matricula']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
