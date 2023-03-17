import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:magic_zoomer/views/zoomer_view.dart';
import 'package:magic_zoomer/widgets/custom_card.dart';
import 'package:magic_zoomer/views/object_detector_view.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magic Zoomer'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ExpansionTile(
                    title: const Text('Tools'),
                    children: [
                      const CustomCard(
                        'Magic Zoomer',
                        ZoomerView(),
                        icon: Icons.camera_alt,
                      ),
                      CustomCard(
                        'Object Detection',
                        ObjectDetectorView(),
                        icon: Icons.auto_awesome_mosaic,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
