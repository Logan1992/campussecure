import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

/// [TeacherScanScreen] é um widget stateful que permite aos professores
/// escanear códigos QR dos alunos para registrar a presença deles.
class TeacherScanScreen extends StatefulWidget {
  const TeacherScanScreen({super.key});

  @override
  _TeacherScanScreenState createState() => _TeacherScanScreenState();
}

class _TeacherScanScreenState extends State<TeacherScanScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true; // Variável para evitar múltiplas leituras

  /// [_barcodeDetected] é chamado quando um código de barras é detectado.
  /// Ele processa o primeiro código de barras detectado e chama [_handleQRCodeScanned].
  void _barcodeDetected(BarcodeCapture barcodeCapture) {
    final List<Barcode> barcodes = barcodeCapture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && _isScanning) {
        _isScanning = false; // Evita leituras múltiplas
        final String qrCode = barcode.rawValue!;
        _handleQRCodeScanned(qrCode);
        break; // Processa apenas o primeiro código de barras detectado
      }
    }
  }

  /// [_handleQRCodeScanned] é uma função assíncrona que processa o código QR escaneado.
  /// Ele verifica a matrícula do aluno no Firestore e registra a presença do aluno.
  ///
  /// Parâmetros:
  /// - [qrCode]: O valor do código QR escaneado.
  void _handleQRCodeScanned(String qrCode) async {
    try {
      QuerySnapshot studentQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('matricula', isEqualTo: qrCode)
          .limit(1)
          .get();

      if (studentQuery.docs.isNotEmpty) {
        DocumentSnapshot studentDoc = studentQuery.docs.first;
        Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;
        String userId = studentDoc.id;
        DateTime now = DateTime.now();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('attendance')
            .add({'timestamp': now});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR Code de ${studentData['nome']} escaneado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aluno não encontrado')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao escanear QR Code: $e')),
      );
    }

    // Delay para evitar múltiplas leituras
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isScanning = true; // Reativa a leitura
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR Code'),
        actions: [
          // Botão para ligar/desligar o flash
          IconButton(
            icon: const Icon(Icons.flash_on),
            color: Colors.white,
            onPressed: () => cameraController.toggleTorch(),
          ),
          // Botão para alternar entre câmeras
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            color: Colors.white,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: _barcodeDetected,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/register_student');
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
