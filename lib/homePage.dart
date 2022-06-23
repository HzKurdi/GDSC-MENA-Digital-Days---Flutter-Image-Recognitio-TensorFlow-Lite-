import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imagePath;
  final _pickeImage = ImagePicker();

  late List _result;
  late String _Confid = "";
  String _name = '';
  String _number = '';

  @override
  void InitState() {
    super.initState();
    loadImageModel();
  }

  picImageCamera() async {
    final XFile? image =
        await _pickeImage.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        imagePath = File(image.path);
      });
    }
  }

  picImagegallery() async {
    final XFile? image =
        await _pickeImage.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        imagePath = File(image.path);
      });
    }
  }

  loadImageModel() async {
    var result = await Tflite.loadModel(
        labels: "assets/labels.txt", model: "assets/model_unquant.tflite");

    print("Result is $result");
  }

  applyImageModel(File file) async {
    var res = await Tflite.runModelOnImage(
        path: file.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      _result = res!;

      String str = _result[0]["label"];
      _name = str.substring(2);
      _Confid = _result != null
          ? (_result[0]['confidence'] * 100.0).toString().substring(0, 2) + '%'
          : "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Recognition'),
      ),
      body: Container(
        child: imagePath == null
            ? Text("there is no image")
            : Column(
                children: [
                  Image.file(File(imagePath!.path)),
                  Text("Name : $_name \n Confid : $_Confid"),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              picImageCamera();
            },
            child: Icon(Icons.camera_alt_outlined),
          ),
          SizedBox(
            height: 20,
          ),
          FloatingActionButton(
            onPressed: () {
              picImagegallery();
            },
            child: Icon(Icons.browse_gallery_outlined),
          ),
        ],
      ),
    );
  }
}
