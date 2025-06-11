import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/pantallas/PantallaPreview.dart';
import 'package:flutter_application/Styles/styles.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});
  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

const double buttonWeight = 250;
const double buttonHeight = 70;
const space = SizedBox(height: 30);

class _PantallaInicioState extends State<PantallaInicio> with TickerProviderStateMixin {
  int _pressedIndex = -1;
  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _slideAnimations;
  late final List<Animation<double>> _fadeAnimations;

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

    _startStaggeredAnimations();
  }

  Future<void> _startStaggeredAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget buildAnimatedButton({
    required int index,
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    final bool isPressed = _pressedIndex == index;

    final button = GestureDetector(
      onTapDown: (_) => setState(() => _pressedIndex = index),
      onTapUp: (_) {
        setState(() => _pressedIndex = -1);
        HapticFeedback.lightImpact();
        onPressed();
      },
      onTapCancel: () => setState(() => _pressedIndex = -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: buttonWeight,
        height: isPressed ? buttonHeight * 0.95 : buttonHeight,
        decoration: BoxDecoration(
          color: isPressed ? darker.withOpacity(0.9) : darker,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: medium),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(color: medium, fontSize: 25),
            ),
          ],
        ),
      ),
    );

    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: button,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Bienvenido a E.Coli Scan',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: dark,
                    )),
              AnimatedTextKit(
                animatedTexts: [
                  FadeAnimatedText(
                    'Bienvenido a E.Coli Scan',
                    textStyle: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: dark,
                    ),
                    duration: const Duration(milliseconds: 1500),
                  ),
                ],
                totalRepeatCount: 1,
                isRepeatingAnimation: false,
                pause: const Duration(milliseconds: 500),
              ),
              space,
              buildAnimatedButton(
                index: 0,
                icon: Icons.camera_alt,
                text: "Cámara",
                onPressed: () {
                  getImageFromCamera();
                },
              ),
              space,
              buildAnimatedButton(
                index: 1,
                icon: Icons.photo_library,
                text: "Galería",
                onPressed: () {
                  getImageFromGallery();
                },
              ),
              space,
              buildAnimatedButton(
                index: 2,
                icon: Icons.info_outline,
                text: "Información",
                onPressed: () {
                  // Acción información
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getImageFromGallery() async{
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });

    if (image != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaPreview(image: File(image.path)),
      ),
    );
  }
  }

  Future getImageFromCamera() async{
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
    if (image != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaPreview(image: File(image.path)),
      ),
    );
    }
  }
}
