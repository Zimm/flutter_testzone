import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:postgres/postgres.dart';
import 'package:camera/camera.dart';

class OCRPage extends StatefulWidget {
  final CameraDescription camera;
  OCRPage({required this.camera});

  @override
  _OCRPageState createState() => _OCRPageState(camera);
}

class _OCRPageState extends State<OCRPage> {
  int _ocrCamera = FlutterMobileVision.CAMERA_BACK;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<Text> _texts = [];
  var connection;

  _OCRPageState(camera);
  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('OCR In Flutter'),
          centerTitle: true,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          width: double.infinity,
          child: FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _read,
                          child: Text(
                            'Scanning',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => {_send2DB(_texts)},
                          child: Text(
                            'Send To DB',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => {_send2DB(_texts)},
                          child: Text(
                            'Preview Image',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      color: Colors.grey,
                      alignment: Alignment.center,
                      height: 300,
                      child: ListView(
                        children: _texts,
                        scrollDirection: Axis.vertical,
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Future<Null> _read() async {
    return;
    List<OcrText> texts = <OcrText>[];
    try {
      texts = await FlutterMobileVision.read(
        camera: _ocrCamera,
        multiple: true,
        waitTap: true,
        fps: 5.0,
        showText: false,
      );

      List<Text> texts2 = <Text>[];
      for (int i = 0; i < texts.length; ++i) {
        texts2.add(Text(
          texts[i].value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ));
      }

      setState(() {
        _texts = texts2;
      });
    } on Exception {
      texts.add(OcrText('Failed to recognize text'));
    }
  }

  Future<Null> _send2DB(List<Text> texts) async {
    connection = PostgreSQLConnection("10.0.1.114", 5432, "testbase",
        username: "postgres", password: "12345");

    await connection.open();
    print("opened");

    List<List<dynamic>> results = await connection.query(
        "INSERT INTO table_name (column1, column2) VALUES (@aValue, @bValue)",
        substitutionValues: {"aValue": 3, "bValue": texts[0].data});

    await connection.close();
  }
}
