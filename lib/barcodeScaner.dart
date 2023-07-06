import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  File? _imageFile;
  String _mlResult = '<no result>';
  final _picker = ImagePicker();

  Future<bool> _pickImage() async {
    setState(() => this._imageFile = null);
    final File? imageFile = await showDialog<File>(
      context: context,
      builder: (ctx) => SimpleDialog(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take picture'),
            onTap: () async {
              final XFile? pickedFile =
                  await _picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                Navigator.pop(ctx, File(pickedFile.path));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Pick from gallery'),
            onTap: () async {
              try {
                final XFile? pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  Navigator.pop(ctx, File(pickedFile.path));
                }
              } catch (e) {
                print(e);
                Navigator.pop(ctx, null);
              }
            },
          ),
        ],
      ),
    );

    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick one image first.')),
      );
      return false;
    }
    setState(() => this._imageFile = imageFile);
    print('picked image: ${this._imageFile}');
    return true;
  }

  Future<void> _barcodeScan() async {
    setState(() => this._mlResult = '<no result>');
    if (await _pickImage() == false) {
      return;
    }
    String result = '';
    final InputImage inputImage = InputImage.fromFile(this._imageFile!);
    final barcodeScanner = GoogleMlKit.vision.barcodeScanner();

    final List<Barcode> barcodes =
        await barcodeScanner.processImage(inputImage);
    result += 'Detected ${barcodes.length} barcodes.\n';
    for (final Barcode barcode in barcodes) {
      final Rect boundingBox = barcode.value.boundingBox!;
      final String rawValue = barcode.value.rawValue!;
      final valueType = barcode.type;
      result += 'rawValue=$rawValue';
    }
    if (result.isNotEmpty) {
      setState(() => this._mlResult = result);
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          if (this._imageFile == null)
            const Placeholder(
              fallbackHeight: 200.0,
            )
          else
            Text('data'),
          // FadeInImage(
          //   placeholder: MemoryImage(kTransparentImage),
          //   image: FileImage(this._imageFile!),
          //   // Image.file(, fit: BoxFit.contain),
          // ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ButtonBar(
              children: <Widget>[
                ElevatedButton(
                  onPressed: this._barcodeScan,
                  child: const Text('Barcode Scan'),
                ),
              ],
            ),
          ),
          const Divider(),
          Text('Result:', style: Theme.of(context).textTheme.subtitle2),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              this._mlResult,
            ),
          ),
        ],
      ),
    );
  }
}
