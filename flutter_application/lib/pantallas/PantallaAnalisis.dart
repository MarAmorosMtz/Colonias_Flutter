import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application/Styles/styles.dart';
import 'package:dio/dio.dart';
import 'RestAPI.dart';
import 'package:fl_chart/fl_chart.dart';

class PantallaAnalisis extends StatefulWidget{

  final File image;
  const PantallaAnalisis({Key? key, required this.image}) : super(key: key);

  @override
  _PantallaAnalisisState createState() => _PantallaAnalisisState();
  
}

class _PantallaAnalisisState extends State<PantallaAnalisis>{
  Uint8List? imagenBytes;
  late Dio dio;
  Map<String, dynamic>? analysisResults;
  @override
  void initState() {
    super.initState();
    dio =  Dio();
    subirImagen(widget.image.path);
  }

  Future<void> subirImagen(String image) async {
    setState(() {
      analysisResults = null;
    });
    try {
      String filename = image.split('/').last;
      FormData formData = new FormData.fromMap({
        'file' : await MultipartFile.fromFile(
          image, filename: filename
        )
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
        host+results+filename,
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
        child: Text('No hay datos suficientes para mostrar el gráfico'),
      );
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: Colors.red,
              value: analysisResults!['red_colonies'].toDouble(),
              title: '${analysisResults!['red_colonies']}',
              radius: 60,
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.blue,
              value: analysisResults!['blue_colonies'].toDouble(),
              title: '${analysisResults!['blue_colonies']}',
              radius: 60,
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.brown,
              value: analysisResults!['brown_colonies'].toDouble(),
              title: '${analysisResults!['brown_colonies']}',
              radius: 60,
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.red, 'Rojas'),
        SizedBox(width: 16),
        _buildLegendItem(Colors.blue, 'Azules'),
        SizedBox(width: 16),
        _buildLegendItem(Colors.brown, 'Marrones'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 4),
        Text(text),
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
      body: Column(
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
          SizedBox(height: 8),
                    _buildPieChart(),
                    _buildLegend(),
                    SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Resumen', style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                            SizedBox(height: 8),
                            Text('Total de colonias: ${analysisResults?['total_colonies'] ?? 0}'),
                            SizedBox(height: 16),
                            Text('Detalle de Colonias', style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                          ],
                        )
                      )
                    )
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

  @override
  void dispose() {
    dio.close();
    super.dispose();
  }

}