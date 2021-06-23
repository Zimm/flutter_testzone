import 'package:flutter/material.dart';
import 'package:flutter_ocr/splash_screen.dart';
import 'package:camera/camera.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(new MyApp(
    firstCamera: firstCamera,
  ));
}

class MyApp extends StatelessWidget {
  final CameraDescription firstCamera;
  MyApp({required this.firstCamera});
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData.dark(),
      home: Splash(
        camera: firstCamera,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
