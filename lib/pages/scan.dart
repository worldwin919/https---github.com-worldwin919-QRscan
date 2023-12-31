import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ins_scan/models/scans.dart';
import 'package:vibration/vibration.dart';

class ScanPage extends StatefulWidget {
  ScanPage({Key? key}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController controller = MobileScannerController();
  bool frozen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MassQR | Scan'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 5, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        child: IconButton(
                          color: Colors.white,
                          icon: ValueListenableBuilder(
                            valueListenable: controller.torchState,
                            builder: (context, state, child) {
                              switch (state as TorchState) {
                                case TorchState.off:
                                  return const Icon(Icons.flash_off);
                                case TorchState.on:
                                  return const Icon(Icons.flash_on);
                              }
                         //     return null;
                            },
                          ),
                          onPressed: () => controller.toggleTorch(),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(8),
                        child: IconButton(
                          color: Colors.white,
                          icon: ValueListenableBuilder(
                            valueListenable: controller.cameraFacingState,
                            builder: (context, state, child) {
                              switch (state as CameraFacing) {
                                case CameraFacing.front:
                                  return const Icon(Icons.camera_front);
                                case CameraFacing.back:
                                  return const Icon(Icons.camera_rear);
                              }
                    //          return null;
                            },
                          ),
                          onPressed: () => controller.switchCamera(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

 Widget _buildQrView(BuildContext context) {
    return MobileScanner(

       
        key: qrKey,
        controller: controller,
        onDetect: (barcode) async {
          if (barcode.raw  != null) {
            ScansModel scans = Provider.of<ScansModel>(context, listen: false);
            if (!scans.scans.contains(barcode.raw)) {
              scans.add(barcode.raw!);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 1),
                  content: Text('Added \'${barcode.raw}\'')));
             
           bool hasVibrator = await Vibration.hasVibrator() ?? false;

                 if (hasVibrator)
                Vibration.vibrate(duration: 50);
            } else {
                         bool hasVibrator = await Vibration.hasVibrator() ?? false;

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 1),
                  content: Text('Skipped duplicate entry')));
              if (hasVibrator) Vibration.vibrate();
            }
          }
        });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
