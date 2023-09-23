import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final qrDataController = TextEditingController();
  String qrData = '';
  final qrKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          qrData = '';
          qrDataController.clear();
          setState(() {});
        },
        child: const Text(' CLear '),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: TextField(
          controller: qrDataController,
          onChanged: (x) {
            qrData = qrDataController.text.trim().toString();
            setState(() {});
          },
          // onSubmitted: (x) {
          //   qrData = qrDataController.text.toString();
          //   setState(() {});
          // },
          decoration: const InputDecoration(
            hintText: 'Type...',
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
      ),
      body: Column(
        children: [
          qrData != ''
              ? Align(
                  alignment: const Alignment(0, -.7),
                  child: RepaintBoundary(
                    key: qrKey,
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: MediaQuery.of(context).size.width * .5,
                    ),
                  ))
              : const SizedBox(),
         if(qrData!='') ElevatedButton(onPressed: takeScreenShot, child: Text('take Screenshot')),
        ],
      ),
    );
  }
  void takeScreenShot() async {
    PermissionStatus res;
    res = await Permission.storage.request();
    if (res.isGranted) {
      final boundary =
      qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // We can increse the size of QR using pixel ratio
      final image = await boundary.toImage(pixelRatio: 5.0);
      final byteData = await (image.toByteData(format: ui.ImageByteFormat.png));
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        // getting directory of our phone
        final directory = (await getApplicationDocumentsDirectory()).path;
        final imgFile = File(
          '$directory/${DateTime.now()}${qrData}.png',
        );
        imgFile.writeAsBytes(pngBytes);
        GallerySaver.saveImage(imgFile.path).then((success) async {
          //In here you can show snackbar or do something in the backend at successfull download
          print('phoenixxxxxxxx');
        });
      }
    }
  }
}
