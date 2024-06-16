import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// [AttendanceScreen] é um widget stateful que permite consultar registros de
/// presença de alunos usando suas matrículas. A consulta é realizada no
/// Firestore, e os resultados são exibidos em uma tabela.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _matriculaController = TextEditingController();
  List<Map<String, dynamic>> _attendanceRecords = [];

  /// [_getAttendanceRecords] busca os registros de presença de um aluno com
  /// base na matrícula fornecida. Os dados são recuperados do Firestore.
  ///
  /// Parâmetros:
  /// - [matricula]: A matrícula do aluno cujos registros de presença devem ser
  /// consultados.
  Future<void> _getAttendanceRecords(String matricula) async {
    try {
      // Consulta os dados do aluno usando a matrícula
      QuerySnapshot studentQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('matricula', isEqualTo: matricula)
          .get();

      if (studentQuery.docs.isNotEmpty) {
        DocumentSnapshot studentDoc = studentQuery.docs.first;
        var studentData = studentDoc.data() as Map<String, dynamic>;
        var attendanceQuery = await FirebaseFirestore.instance
            .collection('users')
            .doc(studentDoc.id)
            .collection('attendance')
            .orderBy('timestamp', descending: true)
            .get();

        // Constrói a lista de registros de presença
        List<Map<String, dynamic>> records = attendanceQuery.docs.map((doc) {
          var data = doc.data();
          return {
            'nome': studentData['nome'],
            'matricula': studentData['matricula'],
            'turma': studentData['turma'],
            'dia': (data['timestamp'] as Timestamp).toDate(),
            'entrada': data['timestamp'].toDate(),
            'saida': data.containsKey('saida') ? (data['saida'] as Timestamp).toDate() : null,
          };
        }).toList();

        setState(() {
          _attendanceRecords = records;
        });
      } else {
        // Mostra uma mensagem caso a matrícula não seja encontrada
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Matrícula não encontrada')),
        );
        setState(() {
          _attendanceRecords = [];
        });
      }
    } catch (e) {
      // Mostra uma mensagem de erro caso ocorra um problema na consulta
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar registros de presença: $e')),
      );
      setState(() {
        _attendanceRecords = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros de Presença'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C6FB), Color(0xFF005BEA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Campo de texto para inserir a matrícula do aluno
              TextField(
                controller: _matriculaController,
                decoration: InputDecoration(
                  labelText: 'Matrícula do Aluno',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Botão para realizar a consulta de presença
              ElevatedButton(
                onPressed: () {
                  String matricula = _matriculaController.text.trim();
                  if (matricula.isNotEmpty) {
                    _getAttendanceRecords(matricula);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, insira a matrícula')),
                    );
                  }
                },
                child: const Text('Consultar'),
              ),
              const SizedBox(height: 20),
              // Tabela para exibir os registros de presença
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Aluno')),
                      DataColumn(label: Text('Matrícula')),
                      DataColumn(label: Text('Turma')),
                      DataColumn(label: Text('Dia')),
                      DataColumn(label: Text('Horário de Entrada')),
                      DataColumn(label: Text('Horário de Saída')),
                    ],
                    rows: _attendanceRecords.map((record) {
                      return DataRow(cells: [
                        DataCell(Text(record['nome'] ?? '')),
                        DataCell(Text(record['matricula'] ?? '')),
                        DataCell(Text(record['turma'] ?? '')),
                        DataCell(Text(record['dia'].toString())),
                        DataCell(Text(record['entrada'].toString())),
                        DataCell(Text(record['saida'] != null ? record['saida'].toString() : '')),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
