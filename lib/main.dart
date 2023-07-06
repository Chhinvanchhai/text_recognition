import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

import 'barcodeScaner.dart';
import 'details.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Recognition',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Text Recognition'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _text = '';
  PickedFile? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              _image != null
                  ? Image.file(
                      File(_image!.path),
                      fit: BoxFit.fitWidth,
                    )
                  : Container(),
              TextButton(
                child: Text('Go Scan'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BarcodeScannerScreen()),
                  );
                },
              )
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        child: Icon(Icons.add_a_photo),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future scanText() async {
    showDialog(
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ),
        context: context);
    final textDetector = GoogleMlKit.vision.textDetector();
    final inputImage = InputImage.fromFile(File(_image!.path));
    final RecognisedText recognisedText =
        await textDetector.processImage(inputImage);

    // final FirebaseVisionImage visionImage =
    //     FirebaseVisionImage.fromFile();
    // final TextRecognizer textRecognizer =
    //     FirebaseVision.instance.textRecognizer();
    // final VisionText visionText =
    //     await textRecognizer.processImage(visionImage);
    // for (TextBlock block in RecognisedText.blocks) {
    //   for (TextLine line in block.lines) {
    //     _text += line.text + '\n';
    //   }
    // }
    String text = recognisedText.text;
    for (TextBlock block in recognisedText.blocks) {
      final Rect rect = block.rect;
      final List<Offset> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;
      print('langeuage=== $rect');
      print('cornerPoints=== $List');
      print('block text=== $text');
      print('langeuage=== $languages');

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement element in line.elements) {
          _text += element.text + '\n';
        }
      }
    }

    Navigator.of(context).pop();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Details(_text)));
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
        scanText();
      } else {
        print('No image selected');
      }
    });
  }
}
