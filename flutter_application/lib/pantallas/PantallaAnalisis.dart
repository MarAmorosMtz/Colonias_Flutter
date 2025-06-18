import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application/Styles/styles.dart';
import 'package:dio/dio.dart';
import 'RestAPI.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';

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
  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    dio = Dio();
    subirImagen(widget.image.path);
    //PermissionUtil.requestAll();
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

  final redColor = Colors.red[300]!;
  final blueColor = Colors.blue[300]!;
  final brownColor = Colors.brown[300]!;
  final borderColor = Colors.white;
  final double radius_anchor = 40;
  return SizedBox(
    height: 180,
    child: Stack(
      children: [
        PieChart(
          PieChartData(
            startDegreeOffset: -90,
            sectionsSpace: 2,
            centerSpaceRadius: 50,
            sections: [
              PieChartSectionData(
                color: redColor,
                value: analysisResults!['red_colonies'].toDouble(),
                title: '${analysisResults!['red_colonies']}',
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


Widget _buildLegend() {
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
      backgroundColor: light,
      appBar: AppBar(
        title: Text('Análisis', style: TextStyle(
          color: darker
        ),),
        backgroundColor: light,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            RepaintBoundary(
              key: _globalKey,
              child: Center(
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
                  Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () async {
                      _saveLocalImage();
                    },
                    child: Text('Guardar Imagen'),
                  ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Future<void> _saveLocalImage() async {
    // Verificar versión de Android
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final isAndroid13OrHigher = androidInfo.version.sdkInt >= 33;

    // Solicitar permiso según versión
    PermissionStatus status;
    if (isAndroid13OrHigher) {
      status = await Permission.photos.request(); // Para Android 13+
    } else {
      status = await Permission.storage.request(); // Para Android <13
    }
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso denegado para guardar imagen')),
      );
      return;
    }

    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final result = await ImageGallerySaverPlus.saveImage(
          byteData.buffer.asUint8List(),
          quality: 100,
          name: "colonia_analisis_${DateTime.now().millisecondsSinceEpoch}",
        );
        print("Imagen guardada: $result");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen guardada exitosamente')),
        );
      }
    } catch (e) {
      print("Error al guardar imagen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar imagen')),
      );
    }
  }

  @override
  void dispose() {
    dio.close();
    super.dispose();
  }
}