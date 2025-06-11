import 'package:flutter/material.dart';
import 'package:flutter_application/pantallas/PantallaInicio.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: const PantallaInicio(),
    );
  }
}