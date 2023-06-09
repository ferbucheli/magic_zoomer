import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:magic_zoomer/views/zoomer_view.dart';
import 'package:magic_zoomer/widgets/custom_card.dart';
import 'package:magic_zoomer/views/object_detector_view.dart';
import 'package:rive/rive.dart';

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
      body: SafeArea(
        child: Stack(children: [
          RiveAnimation.asset('assets/shapes.riv'),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 20,
                sigmaY: 10,
              ),
              child: SizedBox(),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(
                      width: 500,
                      height: 300,
                      child: RiveAnimation.asset(
                        'assets/title.riv',
                        artboard: 'Main',
                      )),
                  ExpansionTile(
                    title: const Text(
                      'Tools',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
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
        ]),
      ),
    );
  }
}
