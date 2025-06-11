import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/Styles/styles.dart';
import 'package:flutter_application/pantallas/PantallaAnalisis.dart';

class PantallaPreview extends StatelessWidget {
  final File image;

  const PantallaPreview({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light,
      appBar: AppBar(
        backgroundColor: light,
        title: const Text('Vista previa', style: TextStyle(
          color: darker
        ),),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(image),
            ),
          ),
          const SizedBox(height: 24), 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PantallaAnalisis(image:File(image.path)))
                      );
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

