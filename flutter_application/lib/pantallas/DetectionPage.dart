import 'package:flutter/material.dart';
import 'package:flutter_application/pantallas/colonias_detector.dart';

class DetectionPage extends StatefulWidget {
  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  Future<DetectionResult>? _detectionFuture;

  void _detectColonies() {
    setState(() {
      _detectionFuture = ColoniesDetector.detect("D:/RosaWoo/fuente/HCL001R.jpg");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detector de Colonias')),
      body: FutureBuilder<DetectionResult>(
        future: _detectionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final result = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Text('Rojas: ${result.redCount}'),
                  Text('Amarillas: ${result.yellowCount}'),
                  Text('Azules: ${result.blueCount}'),
                  if (result.redImage != null) 
                    Image.memory(result.redImage!),
                  // Mostrar otras imágenes si es necesario
                ],
              ),
            );
          }
          return Center(child: Text('Selecciona una imagen para analizar'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickImage(),
        child: Icon(Icons.add_photo_alternate),
      ),
    );
  }

  void _pickImage() async {
    _detectColonies();
  }
}