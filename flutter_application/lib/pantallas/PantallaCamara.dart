import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class PantallaCamara extends StatefulWidget {
  const PantallaCamara({super.key});

  @override
  State<PantallaCamara> createState() => _PantallaCamaraState();
}

class _PantallaCamaraState extends State<PantallaCamara> {
  late List<CameraDescription> _cameras;
  late CameraController _cameraController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _inicializarCamara();
  }

  Future<void> _inicializarCamara() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);

    try {
      await _cameraController.initialize();
      if (!mounted) return;
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      if (e is CameraException) {
        if (e.code == 'CameraAccessDenied') {
          // Maneja permisos aquí
        } else {
          // Otros errores
        }
      }
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CameraPreview(_cameraController),
    );
  }
}
