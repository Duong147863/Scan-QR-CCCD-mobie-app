import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class ScanCCCDScreen extends StatefulWidget {
  @override
  _ScanCCCDScreenState createState() => _ScanCCCDScreenState();
}

class _ScanCCCDScreenState extends State<ScanCCCDScreen> {
  File? _image;
  String? _qrText;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _qrText = null;
      });
      _scanQRCode(_image!);
    }
  }

  Future<void> _scanQRCode(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    // ignore: deprecated_member_use
    final barcodeScanner = GoogleMlKit.vision.barcodeScanner();

    try {
      final barcodes = await barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty) {
        setState(() {
          _qrText = _formatCCCDData(barcodes.first.displayValue!);
        });
      } else {
        setState(() {
          _qrText = "Không tìm thấy mã QR";
        });
      }
    } catch (e) {
      setState(() {
        _qrText = "Lỗi khi quét QR: $e";
      });
    } finally {
      barcodeScanner.close();
    }
  }

  String _formatCCCDData(String rawData) {
    List<String> parts = rawData.split('|');
    if (parts.length < 5) return "Dữ liệu không hợp lệ";

    return '''
CCCD: ${parts[0]}
Họ và Tên: ${parts[2]}
Ngày sinh: ${parts[3]}
Giới tính: ${parts[4]}
Nơi thường chú: ${parts[5]}
Ngày cấp CCCD: ${parts[6]}
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quét CCCD & Mã QR')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_image != null) Image.file(_image!, height: 250),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Chụp ảnh CCCD'),
          ),
          SizedBox(height: 20),
          _qrText != null
              ? Text(
                  _qrText!,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  textAlign: TextAlign.left,
                )
              : Container(),
        ],
      ),
    );
  }
}
