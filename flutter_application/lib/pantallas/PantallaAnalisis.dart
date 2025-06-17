import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application/Styles/styles.dart';
import 'package:dio/dio.dart';
import 'RestAPI.dart';
import 'package:fl_chart/fl_chart.dart';

class PantallaAnalisis extends StatefulWidget {
  final File image;
  const PantallaAnalisis({Key? key, required this.image}) : super(key: key);

  @override
  _PantallaAnalisisState createState() => _PantallaAnalisisState();
}

class _PantallaAnalisisState extends State<PantallaAnalisis> {
  Uint8List? imagenBytes;
  late Dio dio;
  Map<String, dynamic>? analysisResults;

  @override
  void initState() {
    super.initState();
    dio = Dio();
    subirImagen(widget.image.path);
  }

  Future<void> subirImagen(String image) async {
    setState(() {
      analysisResults = null;
    });
    try {
      String filename = image.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image, filename: filename)
      });

      final response = await dio.post(
        host + analyze,
        data: formData,
        options: Options(responseType: ResponseType.json),
      );

      if (response.data != null && response.data is Map) {
        setState(() {
          analysisResults = response.data;
        });
        await cargarImagen(filename);
      } else {
        throw Exception('Formato de respuesta inválido');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> cargarImagen(String filename) async {
    try {
      final response = await dio.get(
        host + results + filename,
        options: Options(responseType: ResponseType.bytes),
      );

      setState(() {
        imagenBytes = Uint8List.fromList(response.data);
      });
    } catch (e) {
      print('Error al cargar imagen: $e');
    }
  }

  Widget _buildPieChart() {
  // Si no hay datos o todos los valores son cero, mostramos un mensaje
  if (analysisResults == null ||
      (analysisResults!['red_colonies'] == 0 &&
          analysisResults!['blue_colonies'] == 0 &&
          analysisResults!['brown_colonies'] == 0)) {
    return Center(
      child: Text('No hay datos suficientes para mostrar el gráfico',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  // Colores mejorados
  final redColor = Colors.red[300]!;
  final blueColor = Colors.blue[300]!;
  final brownColor = Colors.brown[300]!;
  final borderColor = Colors.white;
  final double radius_anchor = 40;
  return SizedBox(
    height: 180, // Altura reducida
    child: Stack(
      children: [
        PieChart(
          PieChartData(
            startDegreeOffset: -90, // Rotación para empezar desde arriba
            sectionsSpace: 2, // Pequeño espacio entre secciones
            centerSpaceRadius: 50, // Radio del espacio central
            sections: [
              PieChartSectionData(
                color: redColor,
                value: analysisResults!['red_colonies'].toDouble(),
                title: '${analysisResults!['red_colonies']}',
                radius: radius_anchor, // Radio más pequeño para hacerlo delgado
                titleStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                borderSide: BorderSide(
                  color: borderColor,
                  width: 2,
                ),
              ),
              PieChartSectionData(
                color: blueColor,
                value: analysisResults!['blue_colonies'].toDouble(),
                title: '${analysisResults!['blue_colonies']}',
                radius: radius_anchor,
                titleStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                borderSide: BorderSide(
                  color: borderColor,
                  width: 2,
                ),
              ),
              PieChartSectionData(
                color: brownColor,
                value: analysisResults!['brown_colonies'].toDouble(),
                title: '${analysisResults!['brown_colonies']}',
                radius: radius_anchor,
                titleStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                borderSide: BorderSide(
                  color: borderColor,
                  width: 2,
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                '${analysisResults?['total_colonies'] ?? 0}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Versión mejorada de la leyenda
Widget _buildLegend() {
  // Colores que coinciden con el gráfico
  final redColor = Colors.red[300]!;
  final blueColor = Colors.blue[300]!;
  final brownColor = Colors.brown[300]!;

  return Container(
    margin: EdgeInsets.only(top: 8),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem(redColor, 'Rojas'),
        _buildLegendItem(blueColor, 'Azules'),
        _buildLegendItem(brownColor, 'Marrones'),
      ],
    ),
  );
}

Widget _buildLegendItem(Color color, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      SizedBox(width: 6),

      Text(
        text,
        style: TextStyle(fontSize: 12),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Análisis'),
        backgroundColor: dark,
      ),
      body: SingleChildScrollView(  // Envolvemos todo el contenido en un SingleChildScrollView
        child: Column(
          children: [
            Center(
              child: imagenBytes != null
                  ? Image.memory(imagenBytes!)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Procesando imagen...')
                      ],
                    ),
            ),
            SizedBox(height: 16),
            _buildPieChart(),
            SizedBox(height: 8),
            _buildLegend(),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Total de colonias: ${analysisResults?['total_colonies'] ?? 0}'),
                  SizedBox(height: 16),
                  Text(
                    'Detalle de Colonias',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (analysisResults != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Colonias rojas: ${analysisResults!['red_colonies']}'),
                        Text('Colonias azules: ${analysisResults!['blue_colonies']}'),
                        Text('Colonias marrones: ${analysisResults!['brown_colonies']}'),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 60), // Espacio adicional al final para mejor desplazamiento
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text("Header"),
              decoration: BoxDecoration(color: dark),
            ),
            ListTile(
              title: Text("Total"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("item 2"),
              onTap: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    dio.close();
    super.dispose();
  }
}