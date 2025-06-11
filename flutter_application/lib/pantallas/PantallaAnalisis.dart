import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/Styles/styles.dart';
//import 'package:graphic/graphic.dart' as graphic;

class PantallaAnalisis extends StatelessWidget{
  final File image;

  const PantallaAnalisis({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Análisis'),
        backgroundColor: dark,
      ),
      body: Column(
        children: [
          Center(
            child: Image.file(image),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text("Header"),
              decoration: BoxDecoration(
                color: dark
              ),
            ),
            ListTile(
              title: Text("Total"),
              onTap: (){
                Navigator.pop(context);
                //Analizar(Image.file(image));
              },
            ),
            ListTile(
              title: Text("item 2"),
              onTap: (){
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}