import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/Styles/styles.dart';
import 'package:flutter_application/pantallas/PantallaPreview.dart';

class PantallaCamara extends StatefulWidget {
  const PantallaCamara({super.key});

  @override
  State<PantallaCamara> createState() => _PantallaCamaraState();
}

class _PantallaCamaraState extends State<PantallaCamara> with WidgetsBindingObserver {
  late List<CameraDescription> _cameras;
  late CameraController _cameraController;
  bool _initialized = false;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _inicializarCamara();
  }

  Future<void> _inicializarCamara() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(
        _cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
      );

      await _cameraController.initialize();
      if (!mounted) return;

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      print("Error al inicializar la cámara: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _inicializarCamara();
    }
  }

  Future<void> _tomarFoto() async {
    if (_isTakingPicture) return;
    setState(() => _isTakingPicture = true);

    try {
      HapticFeedback.lightImpact();
      final XFile foto = await _cameraController.takePicture();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PantallaPreview(imagePath: foto.path),
        ),
      );
    } catch (e) {
      print("Error al tomar la foto: $e");
    } finally {
      setState(() => _isTakingPicture = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: light,
      body: Stack(
        children: [
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CameraPreview(_cameraController),
              ),
            ),
          ),

          // Botón de disparo
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _tomarFoto,
                child: AnimatedScale(
                  scale: _isTakingPicture ? 0.9 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt, size: 36, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),

          // Botón de regreso
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
