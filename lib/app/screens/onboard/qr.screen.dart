// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/icon_data.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../meta/components/toast.dart';
import '../../../meta/extensions/logger.ext.dart';
import '../../../meta/models/freezed/qr.model.dart';
import '../../../meta/notifiers/new_user.notifier.dart';
import '../../../meta/notifiers/user_data.notifier.dart';
import '../../constants/assets.dart';
import '../../constants/page_route.dart';

// 📦 Package imports:
// import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({Key? key}) : super(key: key);

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  AppLogger qrLog = AppLogger('QR');
  bool flash = false;
  QrReaderViewController? controller;
  Future<void> onScan(String data, List<Offset> offsets) async {
    if (data.isNotEmpty) {
      await controller?.stopCamera();
      qrLog.info('QR Code: $data');

      context.read<UserData>().atOnboardingPreference.cramSecret =
          data.split(':')[1];
      context.read<NewUser>()
        ..newUserData['atSign'] = data.split(':')[0]
        ..newUserData['img'] =
            await AppServices.readLocalfilesAsBytes(Assets.getRandomAvatar())
        ..setQrData =
            QrModel(atSign: data.split(':')[0], cramSecret: data.split(':')[1]);
      await Navigator.pushNamed(context, PageRouteNames.activatingAtSign);
    }
    // controller?.stopCamera();
  }

  // void _onQRViewCreated(QrReaderViewController? qrController) {
  //   setState(() {
  //     controller = qrController;
  //   });
  // qrController?.scannedDataStream.listen((Barcode scanData) async {
  //   if (scanData.code != null) {
  //     qrController.dispose();
  //     qrLog.info('QR Code: ${scanData.code}');

  //     context.read<UserData>().atOnboardingPreference.cramSecret =
  //         scanData.code?.split(':')[1];
  //     context.read<NewUser>()
  //       ..newUserData['atSign'] = scanData.code?.split(':')[0]
  //       ..newUserData['img'] =
  //           await AppServices.readLocalfilesAsBytes(Assets.getRandomAvatar())
  //       ..setQrData = QrModel(
  //           atSign: scanData.code?.split(':')[0] ?? '',
  //           cramSecret: scanData.code?.split(':')[1] ?? '');
  //     await Navigator.pushNamed(context, PageRouteNames.activatingAtSign);
  //   }
  // });
  // }

  @override
  void dispose() {
    // controller?.stopCamera();
    super.dispose();
  }

  // @override
  // void reassemble() {
  //   super.reassemble();
  //   if (isAndroid) {
  //     controller!.pauseCamera();
  //   } else if (isIos) {
  //     controller!.resumeCamera();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: SizedBox(
              height: 300,
              width: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: QrReaderView(
                  key: qrKey,
                  // onQRViewCreated: _onQRViewCreated,
                  // overlay: QrScannerOverlayShape(
                  //   borderRadius: 10,
                  //   borderLength: 30,
                  //   borderWidth: 10,
                  //   cutOutSize: 300,
                  // ),
                  callback:
                      (QrReaderViewController qrReaderViewController) async {
                    controller = qrReaderViewController;
                    await controller?.startCamera(onScan);
                  },
                  height: 300, width: 300,
                  torchEnabled: flash,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(
                TablerIcons.photo,
                color: Colors.black,
              ),
              onPressed: () async {
                try {
                  await controller!.stopCamera();
                  Set<PlatformFile> _file =
                      await AppServices.uploadFile(FileType.image);
                  if (_file.isNotEmpty) {
                    bool _gotData = await AppServices.getQRData(
                      context,
                      _file.first.path,
                    );
                    if (_gotData) {
                      await Navigator.pushReplacementNamed(
                          context, PageRouteNames.activatingAtSign);
                    }
                  } else {
                    await controller!.startCamera(onScan);
                    showToast(context, 'No image picked', isError: true);
                  }
                } on Exception catch (e) {
                  await controller!.stopCamera();
                  qrLog.severe(e);
                  showToast(context, 'Failed to pick image', isError: true);
                }
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 10,
            child: IconButton(
              onPressed: () async {
                bool _flash = (await controller!.setFlashlight())!;
                setState(
                  () {
                    flash = _flash;
                  },
                );
              },
              splashRadius: 0.01,
              icon: Icon(
                flash ? const TablerIconData(0xea38) : TablerIcons.bolt_off,
                color: flash
                    ? Colors.black
                    : Theme.of(context).primaryColor.withOpacity(0.3),
                size: 30,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                TablerIcons.x,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
