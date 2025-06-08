import 'package:flutter/material.dart';
import 'package:flutter_application/pantallas/PantallaCamara.dart';

class PantallaInicio extends StatefulWidget{
  const PantallaInicio({super.key});
  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

const light = Color.fromRGBO(223, 242, 235, 1);
const medium = Color.fromRGBO(185, 229, 232, 1);
const dark = Color.fromRGBO(122, 178, 211, 1);
const darker = Color.fromRGBO(74, 98, 138, 1);
const double button_weight = 200;
const double button_height = 70;
const space = SizedBox(height: 30);

class _PantallaInicioState extends State<PantallaInicio> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: light,
      body: Container(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text("Bienvenido", style: TextStyle(
                      color: dark,
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold
                    ),)
                  ),

                  space,

                  SizedBox(
                    width: button_weight,
                    height: button_height,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PantallaCamara(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: darker,
                        foregroundColor: medium,
                        textStyle: TextStyle(
                          fontSize: 25
                        )
                      ),
                      child: Text("Cámara"),
                    ),
                  ),

                  space,

                  SizedBox(
                    width: button_weight,
                    height: button_height,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: darker,
                        foregroundColor: medium,
                        textStyle: TextStyle(
                          fontSize: 25
                        )
                      ),
                      child: Text("Galería"),
                    ),
                  ),

                  space,

                  SizedBox(
                    width: button_weight,
                    height: button_height,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: darker,
                        foregroundColor: medium,
                        textStyle: TextStyle(
                          fontSize: 25
                        )
                      ),
                      child: Text("Información"),
                    ),
                  )
              ]
            )
          ],
        ),
      )
    );
  }
}