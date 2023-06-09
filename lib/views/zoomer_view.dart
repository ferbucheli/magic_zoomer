import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:io' as io;

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:magic_zoomer/views/camera_zoomer_view.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/object_detector_painter.dart';

class ZoomerView extends StatefulWidget {
  const ZoomerView({super.key});

  @override
  State<ZoomerView> createState() => _ZoomerViewState();
}

class _ZoomerViewState extends State<ZoomerView> {
  late ObjectDetector _objectDetector;
  bool _canProcess = false;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  double _currentZoomLevel = 1.0;
  bool takePhoto = false;
  late XFile? picture = null;

  @override
  void initState() {
    super.initState();

    _initializeDetector(DetectionMode.stream);
  }

  @override
  void dispose() {
    _canProcess = false;
    _objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraZoomerView(
      title: 'Magic Zoomer',
      customPaint: _customPaint,
      text: _text,
      onImage: (inputImage, controller) {
        processImage(inputImage, controller);
      },
      onScreenModeChanged: _onScreenModeChanged,
      initialDirection: CameraLensDirection.back,
      takePhoto: takePhoto,
      capturedImage: picture,
    );
  }

  void _onScreenModeChanged(ScreenMode mode) {
    switch (mode) {
      case ScreenMode.gallery:
        _initializeDetector(DetectionMode.single);
        return;

      case ScreenMode.liveFeed:
        _initializeDetector(DetectionMode.stream);
        return;
    }
  }

  void _initializeDetector(DetectionMode mode) async {
    const path = 'assets/object_labeler.tflite';
    final modelPath = await _getModel(path);
    final options = LocalObjectDetectorOptions(
      mode: mode,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);

    _canProcess = true;
  }

  Future<void> processImage(
      InputImage inputImage, CameraController controller) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });

    final objects = await _objectDetector.processImage(inputImage);

    double maxObjectSize = 0;
    for (final object in objects) {
      final objectSize = object.boundingBox.width * object.boundingBox.height;
      if (objectSize > maxObjectSize) {
        maxObjectSize = objectSize * 3.5;
      }
    }

    final previewSize = controller.value.previewSize!;
    final maxPreviewSize = max(previewSize.width, previewSize.height);

    final zoomLevel = maxObjectSize / maxPreviewSize;
    final maxZoomLevel = await controller.getMaxZoomLevel();
    final zoomFactor = pow(2, zoomLevel).clamp(1.0, maxZoomLevel);

    await controller.setZoomLevel(zoomFactor as double);

    if (zoomFactor >= 2.0) {
      await controller.stopImageStream();
      takePhoto = true;
    }

    if (takePhoto) {
      final XFile? photo = await controller.takePicture();
      setState(() {
        picture = photo!;
      });

      // do something with the photo, e.g., display it in an image widget
    }

    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = ObjectDetectorPainter(
          objects,
          inputImage.inputImageData!.imageRotation,
          inputImage.inputImageData!.size);
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Objects found: ${objects.length}\n\n';
      for (final object in objects) {
        text +=
            'Object:  trackingId: ${object.trackingId} - ${object.labels.map((e) => e.text)}\n\n';
      }
      _text = text;
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<String> _getModel(String assetPath) async {
    if (io.Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }
}
