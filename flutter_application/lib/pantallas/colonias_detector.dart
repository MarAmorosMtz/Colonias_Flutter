import 'dart:io';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

final DynamicLibrary _nativeLib = () {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libcolonias_detector.so');
  } else if (Platform.isIOS) {
    return DynamicLibrary.process();
  }
  throw UnsupportedError('Plataforma no soportada');
}();

class DetectionResult {
  final int redCount;
  final int yellowCount;
  final int blueCount;
  final Uint8List? redImage;
  final Uint8List? yellowImage;
  final Uint8List? blueImage;

  DetectionResult({
    required this.redCount,
    required this.yellowCount,
    required this.blueCount,
    this.redImage,
    this.yellowImage,
    this.blueImage,
  });
}

class ColoniesDetector {
  static final _detectColonies = _nativeLib.lookupFunction<
      Pointer Function(Pointer<Utf8>),
      Pointer Function(Pointer<Utf8>)>('detect_colonies');

  static final _freeResult = _nativeLib.lookupFunction<
      Void Function(Pointer),
      void Function(Pointer)>('free_detection_result');

  static Future<DetectionResult> detect(String imagePath) async {
    try {
      final pathPtr = imagePath.toNativeUtf8();
      final resultPtr = _detectColonies(pathPtr);
      final result = resultPtr.ref;

      final detectionResult = DetectionResult(
        redCount: result.red_count,
        yellowCount: result.yellow_count,
        blueCount: result.blue_count,
        // Agregar procesamiento de imágenes aquí
      );

      _freeResult(resultPtr);
      malloc.free(pathPtr);

      return detectionResult;
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
      rethrow;
    }
  }
}