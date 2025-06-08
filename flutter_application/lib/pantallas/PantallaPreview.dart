import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/Styles/styles.dart';
//import 'package:gallery_saver/gallery_saver.dart';
//import 'package:flutter/services.dart'; // Para mostrar SnackBar

class PantallaPreview extends StatelessWidget {
  final String imagePath;

  const PantallaPreview({super.key, required this.imagePath});

  Future<void> _guardarImagen(String path, BuildContext context) async {
    /*try {
      bool? success = await GallerySaver.saveImage(path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success == true ? 'Imagen guardada en galería' : 'Error al guardar imagen'),
          backgroundColor: success == true ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista previa'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(File(imagePath)),
            ),
          ),
          const SizedBox(height: 24), 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _guardarImagen(imagePath, context),
                    icon: const Icon(Icons.save_alt, size: 28, color: medium,),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Guardar',
                        style: TextStyle(fontSize: 18, color: medium),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darker,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Acción para analizar
                      print('Analizando imagen en $imagePath');
                      // Aquí puedes agregar navegación o lógica de análisis
                    },
                    icon: const Icon(Icons.analytics, size: 28, color: medium,),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Analizar',
                        style: TextStyle(fontSize: 18, color: medium),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darker,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32), // Espacio al final
        ],
      ),
    );
  }
}

